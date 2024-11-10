
# Librerias Necesarias ----------------------------------------------------

library(tidyverse)
library(janitor)

# Codigo Fuente Necesario -------------------------------------------------

source("src\\CargaStockBrocoli.R")

# Generar Tabla resumen con total kilos por formato

tabla <- CargaStock()

stock <- tabla %>% 
  pivot_wider(names_from = Formato, values_from = "BrutoFormato") %>% 
  clean_names() 

stock[is.na(stock)] <- 0

totales <- colSums(stock, na.rm = TRUE)

stock <- rbind(stock, Total = totales)

# Redondear y luego aplicar el formato a todas las columnas numéricas

stock[] <- lapply(stock, function(x) {
  if (is.numeric(x)) {
    # Redondear los números
    format(round(x, 2), big.mark = ".", scientific = FALSE, trim = TRUE)
    # Aplicar el formato con separador de miles
    format(x, big.mark = ".", decimal.mark = ",", scientific = FALSE, trim = TRUE)
  } else {
    x
  }
})
