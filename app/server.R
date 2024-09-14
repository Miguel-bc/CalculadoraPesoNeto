library(shiny)
library(DT)
library(openxlsx)
library(ggplot2)
library(tidyverse)
library(shinyalert)

# Función para determinar en qué rango se encuentra un peso
calculo_formato <- function(peso, tabla_formatos){
  for(i in 1:nrow(tabla_formatos)){
    if(peso >= tabla_formatos$Minimo[i] & peso <= tabla_formatos$Maximo[i]){
      return(tabla_formatos$Formato[i])
    }
  }
  return("Sin Formato")
}

# Función para calcular orden de presentación
calculo_orden <- function(peso, tabla_formatos){
  for(i in 1:nrow(tabla_formatos)){
    if(peso >= tabla_formatos$Minimo[i] & peso <= tabla_formatos$Maximo[i]){
      return(tabla_formatos$Orden[i])
    }
  }
  return(0)
}

# Funcion para eliminar outliers
eliminar_outliers <- function(df, columna) {
  # Agrupar por Orden y Formato

df_filtrado <- df %>%
  group_by(Orden, Formato) %>%
  filter({
    # Calcular Q1, Q3 e IQR para cada grupo
    Q1 <- quantile(.data[[columna]], 0.25, na.rm = TRUE)
    Q3 <- quantile(.data[[columna]], 0.75, na.rm = TRUE)
    IQR <- Q3 - Q1
    
    # Filtrar datos dentro del rango ajustado por el coeficiente
    .data[[columna]] >= (Q1 - 1.5 * IQR) & .data[[columna]] <= (Q3 + 0.5 * IQR)
  }) %>%
  ungroup()

return(df_filtrado)
}

# Carga archivo de datos
archivo <- "Pesos.xlsx"
camino <- file.path("..", "data", archivo)
hoja <- "Pesos"    
pesos <- readxl::read_excel(camino, hoja)
pesos$Formato <- "Sin Formato"
pesos$Orden <- "0"

# Cargar Tabla Formatos
archivo <- "Formatos.xlsx"
camino <- file.path("..", "data", archivo)
hoja <- "Formatos"    
formatos <- readxl::read_excel(camino, hoja)

# Define lógica del servidor
server <- function(input, output, session) {
  
  # Hacer reactivas las tablas capturadas
  
  reactive_pesos <- reactiveValues(data = pesos)
  reactive_formatos <- reactiveValues(data = formatos)
  
  # Funcion Reactiva para el filtrado de la tabla pesos
  
  reactive_pesos_datos_filtrados <- reactive({
    
    datos <- reactive_pesos$data

    if (input$eliminar_outliers) {
      datos <- eliminar_outliers(datos, "Bruto")
    } 
    
    print(input$partida_select)
    
    if (input$partida_select != "Todas"){
      datos <- datos %>% 
        filter(Partida == input$partida_select)
    }
    
    # Calcular el formato basado en el peso neto
    datos$Formato <- sapply(datos$Neto, function(peso_neto) {
      calculo_formato(peso_neto, tabla_formatos = reactive_formatos$data)
    })
    
    # Calcular el orden basado en el peso neto 
    datos$Orden <- sapply(datos$Neto, function(peso_neto) {
      calculo_orden(peso_neto, tabla_formatos = reactive_formatos$data)
    })
    
    return(datos)
  })
  
  # Función Reactiva para crear la receta
  
  reactive_receta <- reactive({
    receta <- reactive_pesos_datos_filtrados() %>% 
      select(Orden, Formato, Bruto) %>% 
      group_by(Formato) %>% 
      mutate(Minimo_Bruto = min(Bruto, na.rm = TRUE), 
             Maximo_Bruto = max(Bruto, na.rm = TRUE)) %>% 
      arrange(Minimo_Bruto) %>% 
      select(Formato, Minimo_Bruto, Maximo_Bruto) %>% 
      distinct()
    
    return(receta) 
  })
  
  # Funcion reactiva para reinicializar la tabla formatos
  
  nueva_tabla_formatos <- reactive({
    data.frame(
      Formato = rep("Nuevo Formato", input$Salidas),
      Minimo = rep(0, input$Salidas),
      Maximo = rep(0, input$Salidas),
      stringsAsFactors = FALSE
    )
  })
  
  # Eventos Observados
  
  # Actualizar el selectInput con los valores únicos de la columna "Partida"
  
  observe({
    partidas <- unique(reactive_pesos$data$Partida) 
    updateSelectInput(session, "partida_select", choices = c("Todas",partidas))
    updateSliderInput(session, "Salidas", value = nrow(formatos))
  })
  
  # Observar evento del boton reset tabla para reinicializar
  
  observeEvent(input$resetTbl, {
    reactive_formatos$data <- nueva_tabla_formatos()
    output$TablaFormatos <- renderDT({
      datatable(reactive_formatos$data, editable = TRUE, rownames = FALSE, 
                options = list(
                  pageLength = 10,
                  lengthMenu = c(10, 25, 50, "Todos"),
                  scrollY = "calc(100vh - 150px)",
                  scrollCollapse = TRUE
                ))
    })
  })
  
  # Observar eventos de edición en la tabla de formatos
  
  observeEvent(input$TablaFormatos_cell_edit, {
    info <- input$TablaFormatos_cell_edit
    row <- info$row 
    col <- info$col + 1  # Sumar 1 porque DT maneja índices base 0
    value <- info$value
    reactive_formatos$data[row, col] <- DT::coerceValue(value, reactive_formatos$data[row, col])
    
    # Actualizar la tabla renderizada
    output$TablaFormatos <- renderDT({
      datatable(reactive_formatos$data, editable = TRUE, rownames = FALSE, options = list(dom = 't'))
    })
  })
  
  # Observar eventos del botón guardar tabla
  observeEvent(input$saveTbl, {
    camino_formatos <- file.path("..", "data", "Formatos.xlsx")
    write.xlsx(reactive_formatos$data, file = camino_formatos, sheetName = "Formatos", rowNames = FALSE)
  })
  
  # Funciones de renderizacion
  
  # Renderizar la tabla de pesos
  
  output$TablaPesos <- renderDT({
    datatable(reactive_pesos_datos_filtrados(), 
              options = list(
                pageLength = 10,
                scrollY = "calc(100vh - 150px)",
                scrollCollapse = TRUE,
                paging = TRUE
              ),
              rownames = FALSE)
  })
  
  # Renderizar tabla formatos
  
  output$TablaFormatos <- renderDT({
    datatable(reactive_formatos$data, editable = TRUE, rownames = FALSE, 
              options = list(
                pageLength = 10,
                lengthMenu = c(10, 25, 50, "Todos"),
                scrollY = "calc(100vh - 150px)",
                scrollCollapse = TRUE
              ))
  })
  
  # Renderizar tabla receta
  
  output$Receta <- DT::renderDT({
    datatable(reactive_receta() %>% arrange(Minimo_Bruto), 
              options = list(
                pageLength = -1, # Para mostrar todas las filas
                scrollY = "calc(100vh - 150px)", 
                scrollCollapse = TRUE,
                paging = FALSE # Desactiva la paginación
              ),
              rownames = FALSE)
  })
   
  # Renderizar graficos
  
  # Histograma
  
  output$HistPesosFormato <- renderPlot({
    
    # Calcular el porcentaje del peso neto total por formato
    pesos_agrupados <- reactive_pesos_datos_filtrados() %>%
      group_by(Formato) %>%
      summarise(Total_Neto = sum(Neto, na.rm = TRUE)) %>%
      mutate(Porcentaje = Total_Neto / sum(Total_Neto) * 100) 
    
    # Crear el gráfico de barras mostrando el porcentaje
    ggplot(data = pesos_agrupados, aes(x = Formato, y = Porcentaje, fill = Formato)) +
      geom_bar(stat = "identity") +
      theme_minimal() +
      labs(title = "Porcentaje del Peso Neto Total por Formato", 
           x = "Formato", 
           y = "Porcentaje del Peso Neto Total") +
      scale_y_continuous(labels = scales::percent_format(scale = 1)) +
      geom_text(aes(label = sprintf("%d%%", round(Porcentaje))), 
                vjust = -0.5, 
                size = 4) +
      scale_fill_brewer(palette = "Set3") +
      theme(legend.position = "none")
  })
  
  # box-plot
  
  output$BoxplotPesosBrutos <- renderPlot({
    
    ggplot(data = reactive_pesos_datos_filtrados(), aes(x = Formato, y = Bruto, fill = Formato)) +
      geom_boxplot() +
      theme_minimal() +
      labs(title = "Boxplot de Pesos Brutos por Formato",
           x = "Formato",
           y = "Peso Bruto") +
      scale_fill_brewer(palette = "Set3") +
      theme(legend.position = "none")
  })
  
}