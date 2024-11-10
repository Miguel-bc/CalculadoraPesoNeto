
# Librerias Necesarias ----------------------------------------------------

library(readxl)
library(tidyverse)

# Carga de archivo --------------------------------------------------------

CargaPesosReales <- function(){
  
  Pesos_Real <- read_excel("C:/Users/mblaya/OneDrive - VERDIMED, SA/R/CalculadoraPesoNeto/data/Registros clasificado brócoli.xlsm", sheet = "REGISTROS")
  
  Pesos_Real <- Pesos_Real %>% 
    select(PARTIDA, `PESO BRUTO`,`PESO NETO`) %>% 
    rename(Partida = PARTIDA, Bruto = `PESO BRUTO`, Neto = `PESO NETO`) %>% 
    mutate(id = as.double(row_number()), 
           Formato = "Sin Formato",
           Orden = "0") %>% 
    select(id, everything()) %>% 
    filter(Bruto != 0)
  }

