
# Librerias Necesarias ----------------------------------------------------

library(readxl)
library(tidyverse)

# Codigo fuente necesario

source("src\\CargaFormatos.R")
source("src\\CargaPesosReales.R")

# Carga Stock Coliflor ----------------------------------------------------

CargaStock <-function(){
  
  tabla_pesos <- CargaPesosReales()
  formatos <- CargaFormatos()
  
  Stock_Real <- read_excel("C:\\Users\\mblaya\\VERDIMED, SA\\Intranet de Verdimed - ALMACEN\\00 General\\00001 Datos\\3.0\\StockBrocoli.xlsx", sheet = "Sheet1")
  
  Stock_Real_Agrupado <- Stock_Real %>% 
    mutate(BrutoFormato = CantidadTotalPartida*(CantidadTotalClasificada/TotalEntradaInicial)) %>% 
    group_by(NumeroPartida) %>% 
    summarise(StockBruto = sum(BrutoFormato),
              Rdto = 1- mean(Destrio)) %>% 
    mutate(StockNeto = StockBruto * Rdto)
  
  # Calcular el formato basado en el peso neto
  
  tabla_pesos$Formato <- sapply(tabla_pesos$Neto, function(peso_neto) {
    calculo_formato(peso_neto, tabla_formatos = formatos)
  })
  
  # Agrupar tabla_pesos por partida y formato
  
  tabla_pesos_agrupada <- tabla_pesos %>% 
    group_by(Partida, Formato) %>% 
    summarise(PesoBruto = sum(Bruto)) %>%  
    group_by(Partida) %>% 
    mutate(PesoTotalPartida = sum(PesoBruto)) %>% 
    ungroup() %>% 
    mutate(PctjFormato = PesoBruto / PesoTotalPartida) %>% 
    select(Partida, Formato, PctjFormato) %>% 
    rename(NumeroPartida = Partida)
  
  distribucion_pesos_promedio <- tabla_pesos %>%
    group_by(Formato) %>%
    summarise(Bruto = sum(Bruto, na.rm = TRUE)) %>% 
    mutate(PctjFormato = Bruto / sum(Bruto),
           NumeroPartidaProvisional = 1) %>% 
    select(NumeroPartidaProvisional, Formato, PctjFormato)
  
  Stock_Formato <- Stock_Real_Agrupado %>% 
    left_join(tabla_pesos_agrupada, by = "NumeroPartida") 
  
  Completos <- Stock_Formato %>% 
    filter(!is.na(Formato))
  
  Faltantes <- Stock_Formato %>% 
    filter(is.na(Formato)) %>% 
    mutate(NumeroPartidaProvisional = 1) %>% 
    left_join(distribucion_pesos_promedio, by = "NumeroPartidaProvisional") %>% 
    select(NumeroPartida, StockBruto, Rdto, StockNeto, Formato = Formato.y, PctjFormato = PctjFormato.y)
  
  Stock_Formato_Final <- rbind(Completos, Faltantes) %>% 
    mutate(BrutoFormato = StockBruto * PctjFormato,
            NetoFormato = StockNeto * PctjFormato) %>% 
    select(NumeroPartida, Formato, BrutoFormato, NetoFormato)
  
  return(Stock_Formato_Final)
}

# Función para determinar en qué rango se encuentra un peso

calculo_formato <- function(peso, tabla_formatos){
  for(i in 1:nrow(tabla_formatos)){
    if(peso >= tabla_formatos$Minimo[i] & peso <= tabla_formatos$Maximo[i]){
      return(tabla_formatos$Formato[i])
    }
  }
  return("Sin Formato")
}



