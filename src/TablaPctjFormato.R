
# Librerias Necesarias ----------------------------------------------------

library(tidyverse)
library(janitor)

# Codigo Fuente Necesario -------------------------------------------------

source("src\\CargaStockBrocoli.R")

# Generar Tabla resumen con total kilos por formato

tabla <- CargaStock()

stock <- tabla %>% 
  group_by(Formato) %>% 
  summarise(Bruto = sum(BrutoFormato)) %>% 
  group_by(Total = sum(Bruto)) %>% 
  ungroup() %>% 
  mutate(Pctj = round(Bruto / Total, 2))
  
