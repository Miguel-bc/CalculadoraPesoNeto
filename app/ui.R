# Carga archivo de datos
archivo <- "Pesos.xlsx"
camino <- file.path("..", "data", archivo)
hoja <- "Pesos"    
pesos <- readxl::read_excel(camino, hoja)
pesos$Formato <- "Sin Formato"
pesos$Orden <- "0"

library(shiny)
library(shinythemes)
library(readxl)

# Define UI for application that draws a histogram

fluidPage(

  theme = shinytheme("cerulean"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("SalidasDiscriminador", "Salidas Discriminador", 
                  min = 6, max = 10, value = 8),
      sliderInput("Salidas", "Rangos Programados", 
                  min = 1, max = 20, value = 1),
      selectInput(
        inputId = "partida_select",
        label = "Selecciona Número de Partida:",
        choices = "Todas",  # Se actualizará dinámicamente
        selected = "Todas"  
        
      ),
      checkboxInput("eliminar_outliers", "Eliminar outliers", FALSE),
      fluidRow(
        column(4,actionButton("resetTbl", "Nueva Tabla")),
        column(4,actionButton("saveTbl", "Guardar Tabla")),
        column(4,actionButton("calcFormato","Calcula Formatos"))
      )
      
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
