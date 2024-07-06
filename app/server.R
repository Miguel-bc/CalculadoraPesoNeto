
library(shiny)
library(DT)
library(openxlsx)

# Carga archivo de datos

archivo <- "Pesos.xlsx"
camino <- file.path("..", "data", archivo)
hoja <- "Pesos"    
pesos <- readxl::read_excel(camino, hoja)
pesos$Formato <- "Sin Formato"


# Cargar Tabla Formatos

archivo <- "Formatos.xlsx"
camino <- file.path("..", "data", archivo)
hoja <- "Formatos"    
formatos <- readxl::read_excel(camino, hoja)

# Define logica servidor

function(input, output, session) {
  
  # Renderizar tabla de pesos
  
  output$TablaPesos <- DT::renderDT({
    datatable(pesos, 
              options = list(
                pageLength = -1, # Para mostrar todas las filas
                scrollY = "calc(100vh - 150px)", 
                scrollCollapse = TRUE,
                paging = FALSE # Desactiva la paginación
              ),
              rownames = FALSE)
  })
  
  # Renderizar tabla formatos
  
  output$TablaFormatos<- renderDT({
    datatable(formatos, editable = TRUE, rownames = FALSE, options = list(dom = 't'))
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
    formatos <<- nueva_tabla_formatos()
    output$TablaFormatos <- renderDT({
      datatable(formatos, editable = TRUE, rownames = FALSE, options = list(dom = 't'))
    })
  })
  
  # Observar eventos de edición en la tabla de formatos
  
  observeEvent(input$TablaFormatos_cell_edit, {
    info <- input$TablaFormatos_cell_edit
    row <- info$row 
    col <- info$col + 1  # Sumar 1 porque DT maneja índices base 0
    value <- info$value
    formatos[row, col] <<- DT::coerceValue(value, formatos[row, col])
    # Actualizar la tabla renderizada
    output$TablaFormatos <- renderDT({
      datatable(formatos, editable = TRUE, rownames = FALSE, options = list(dom = 't'))
    })
  })
  
  # Observar enventos del botón guardar tabla
  
  observeEvent(input$saveTbl,{
    archivo <- "Formatos.xlsx"
    camino <- file.path("..", "data", archivo)
    hoja <- "Formatos"    
    write.xlsx(formatos, file = camino, sheetName = hoja, rowNames = FALSE)
  })
  
}