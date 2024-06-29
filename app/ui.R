

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
      actionButton("resetTbl", "Nueva Tabla"),
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Pestaña 1", 
                 h4("Contenido de la pestaña 1"),
                 textOutput("output1")),
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
