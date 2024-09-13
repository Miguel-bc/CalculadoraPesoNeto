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
    .data[[columna]] >= (Q1 - 1.5 * IQR) & .data[[columna]] <= (Q3 + 1.5 * IQR)
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

print(colnames(formatos))

# Define lógica del servidor
server <- function(input, output, session) {
  
  # Hacer que la tabla de pesos y formatos sean reactivas
  reactive_pesos <- reactiveValues(data = pesos)
  reactive_formatos <- reactiveValues(data = formatos)
  reactive_pesos$datos_filtrados <- reactive_pesos
  
  # Actualizar el selectInput con las distintas partidas disponibles
  observe({
    
    partidas <- unique(reactive_pesos$data$Partida)
    
    # Agregamos una opción para "Mostrar todas las partidas"
    updateSelectInput(session, "partida_select",
                      choices = c("Todas", partidas))
  })
  
  # Renderizar tabla de pesos
  
  output$TablaPesos <- DT::renderDT({
    datatable(reactive_pesos$datos_filtrados, 
              options = list(
                pageLength = -1, # Para mostrar todas las filas
                scrollY = "calc(100vh - 150px)", 
                scrollCollapse = TRUE,
                paging = FALSE # Desactiva la paginación
              ),
              rownames = FALSE)
  })
  
  # Datos reactivos con o sin outliers según la selección del usuario
  
  datos_filtrados <- reactive({
    if (input$eliminar_outliers) {
      eliminar_outliers(reactive_pesos$data, "Bruto")
    } else {
      reactive_pesos$data
    }
  })
  
  # Renderizar tabla formatos
  
  output$TablaFormatos <- renderDT({
    datatable(reactive_formatos$data, editable = TRUE, rownames = FALSE, options = list(dom = 't'))
  })
  
  # Crear receta con formatos únicos y columnas para mínimo y máximo bruto
  
  reactive_receta <- reactive({
    receta <- reactive_pesos$datos_filtrados %>% 
      select(Orden, Formato) %>% 
      distinct() %>%
      group_by(Formato) %>% 
      mutate(Minimo_Bruto = NA, 
             Maximo_Bruto = NA)
    
    for (i in 1:nrow(receta)) {
      formato <- receta$Formato[i]
      min_max_bruto <- datos_filtrados() %>%
        filter(Formato == formato) %>%
        summarise(Minimo_Bruto = min(Bruto, na.rm = TRUE),
                  Maximo_Bruto = max(Bruto, na.rm = TRUE))
      
      receta$Minimo_Bruto[i] <- min_max_bruto$Minimo_Bruto
      receta$Maximo_Bruto[i] <- min_max_bruto$Maximo_Bruto
    }
    
    receta <- receta %>% arrange(Minimo_Bruto)
    
    return(receta) 
    
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
  
  # Generar dataframe en blanco
  nueva_tabla_formatos <- reactive({
    data.frame(
      Formato = rep("Nuevo Formato", input$Salidas),
      Minimo = rep(0, input$Salidas),
      Maximo = rep(0, input$Salidas),
      stringsAsFactors = FALSE
    )
  })
  
  # Observar eventos del botón y sustituir formatos
  observeEvent(input$resetTbl, {
    reactive_formatos$data <- nueva_tabla_formatos()
    output$TablaFormatos <- renderDT({
      datatable(reactive_formatos$data, editable = TRUE, rownames = FALSE, options = list(dom = 't'))
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
  
  # Observar eventos del botón calcula formato
  observeEvent(input$calcFormato, {
    reactive_pesos$data$Formato <- sapply(reactive_pesos$data$Neto, function(x) {
      calculo_formato(x, reactive_formatos$data)
    })
    
    
    reactive_pesos$data$Orden <- sapply(reactive_pesos$data$Neto, function(x) {
      calculo_orden(x, reactive_formatos$data)
      
    })
    
    # Actualizar tabla de pesos
    output$TablaPesos <- DT::renderDT({
      datatable(reactive_pesos$data, 
                options = list(
                  pageLength = -1, 
                  scrollY = "calc(100vh - 150px)", 
                  scrollCollapse = TRUE,
                  paging = FALSE 
                ),
                rownames = FALSE)
    })
  })
  
  
  # Observar enventos cuando cambie la partida
  observeEvent(input$partida_select, {
    #  # Si se selecciona "Mostrar todas las partidas", mostramos todos los datos
    if (input$partida_select == "Todas") {
      reactive_pesos$datos_filtrados <- datos_filtrados()
    } else {
      # Filtrar los datos según la partida seleccionada
      reactive_pesos$datos_filtrados <- datos_filtrados() %>%
        filter(Partida == input$partida_select)
    }
    
    # Actualizar la tabla de pesos en la interfaz con los datos filtrados
    output$TablaPesos <- DT::renderDT({
      datatable(reactive_pesos$datos_filtrados, 
                options = list(
                  pageLength = -1, 
                  scrollY = "calc(100vh - 150px)", 
                  scrollCollapse = TRUE,
                  paging = FALSE 
                ),
                rownames = FALSE)
    })
  })

  # Renderizar histograma de pesos por formato
  output$HistPesosFormato <- renderPlot({
    
    # Calcular el porcentaje del peso neto total por formato
    pesos_agrupados <- reactive_pesos$datos_filtrados %>%
      group_by(Formato) %>%
      summarise(Total_Neto = sum(Neto, na.rm = TRUE)) %>%
      mutate(Porcentaje = Total_Neto / sum(Total_Neto) * 100) 
    
    eliminar_outliers
    
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
  

  # Renderizar box 
  
  output$BoxplotPesosBrutos <- renderPlot({
    
    ggplot(data = reactive_pesos$datos_filtrados, aes(x = Formato, y = Bruto, fill = Formato)) +
      geom_boxplot() +
      theme_minimal() +
      labs(title = "Boxplot de Pesos Brutos por Formato",
           x = "Formato",
           y = "Peso Bruto") +
      scale_fill_brewer(palette = "Set3") +
      theme(legend.position = "none")
  })
}