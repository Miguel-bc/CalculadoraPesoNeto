
library(shiny)
library(shinythemes)
library(readxl)

# Carga archivo de datos
archivo <- "Pesos.xlsx"
camino <- file.path("..", "data", archivo)
hoja <- "Pesos"    
pesos <- readxl::read_excel(camino, hoja)
pesos$Formato <- "Sin Formato"
pesos$Orden <- "0"

# Define UI for application that draws a histogram

fluidPage(

  theme = shinytheme("cerulean"),
  
  tags$head(
    tags$title("Calculadora Rango Pesos")
  ),
  
  sidebarLayout(
    sidebarPanel(
      sliderInput("Salidas", "Rangos Programados", 
                  min = 1, max = 20, value = 1),
      selectInput(
        inputId = "partida_select",
        label = "Selecciona Número de Partida:",
        choices = "Todas",  # Se actualizará dinámicamente
        selected = "Todas",
        multiple = TRUE
      ),
      checkboxInput("eliminar_outliers", "Eliminar outliers", FALSE),
      sliderInput("Rigidez", "Rigidez", 
                  min = 1, max = 1.5, value = 1.5),
      fluidRow(
        column(6,actionButton("resetTbl", "Nueva Tabla Formatos")),
        column(6,actionButton("saveTbl", "Guardar Tabla Formatos"))
      ),
      checkboxInput("seleccion_pesos_real", "Pesos Reales", TRUE)
      
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Estadísticas", 
                 fluidRow(
                   column(6,plotOutput("HistPesosFormato")),
                   column(6,plotOutput("BoxplotPesosBrutos"))
                 ),
                 fluidRow(
                   column(12,DT::DTOutput("Receta"))
                 )
                ),
        tabPanel("Formatos", 
                 fluidRow(
                   column(12,DT::DTOutput("TablaFormatos"))
                 ),
                 style = "height: calc(100vh - 100px); overflow-y: auto;"),
        tabPanel("Pesos Partida",
                 fluidRow(
                   column(12,DT::DTOutput("TablaPesos"))
                 ),
                 style = "height: calc(100vh - 100px); overflow-y: auto;")
      )
    )
  )
)
