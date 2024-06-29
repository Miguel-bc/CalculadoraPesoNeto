
library(shiny)
library(DT)

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
    nuevos_formatos <- nueva_tabla_formatos()
    output$TablaFormatos <- renderDT({
      datatable(nuevos_formatos, 
                editable = TRUE, 
                rownames = FALSE, 
                options = list(
                  dom = 't',
                  scrollY = "500px",  # Ajusta según el espacio que quieras ocupar
                  scrollCollapse = TRUE,
                  paging = FALSE
                ))
    })
  })
  
}