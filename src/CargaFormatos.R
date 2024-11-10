
# Librerias Necesarias ----------------------------------------------------

library(readxl)
library(tidyverse)

# Carga de archivo --------------------------------------------------------

CargaFormatos <- function(){
  
  Formatos <- read_excel("C:/Users/mblaya/OneDrive - VERDIMED, SA/R/CalculadoraPesoNeto/data/Formatos.xlsx", sheet = "Formatos")
  
  
}

