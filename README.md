# Proyecto Analizador de Peso de Brócoli

## Descripción
Este proyecto contiene ejemplos y demostraciones de análisis de peso de piezas de brócoli, extrapolando datos para determinar el peso neto de las piezas después de cortar el tronco. El objetivo es identificar el peso mínimo y máximo utilizado y aplicar esta información para predecir el peso de otras piezas en diferentes partidas.

## Estructura del Proyecto
- `/data`: Contiene los archivos de datos de las partidas de brócoli.
- `/src/r`: Scripts en R para el análisis de datos, incluyendo funciones, modelos y visualizaciones.
- `/src/scripts`: Scripts de automatización y configuración.
- `/docs`: Documentación del proyecto, incluyendo diagramas, guías y análisis.

## Requisitos Previos
- R (versión 4.0 o superior)
- RStudio (opcional, pero recomendado)
- Git

## Cómo Configurar el Proyecto

### 1. Clonar el Repositorio
Clona el repositorio:
```sh
git clone https://github.com/Miguel-bc/CalculadoraPesoNeto.git
cd analizador-peso-brocoli
```

### 2. Instalar Dependencias
Abre R o RStudio y ejecuta el siguiente comando para instalar las dependencias necesarias:

install.packages(c("dplyr", "ggplot2", "readr"))

### 3. Descargar los Archivos de Datos
Coloca tus archivos de datos de las partidas de brócoli en la carpeta /data. Si tienes archivos de ejemplo, puedes descargarlos y colocarlos aquí.

### 4. Ejecutar los Scripts de Análisis
Ejecuta los scripts en /src/r para realizar el análisis. Abre R o RStudio y ejecuta los scripts en el siguiente orden:

01_cargar_datos.R - Carga los datos desde los archivos en /data.
02_analizar_peso.R - Realiza el análisis de peso y genera visualizaciones.
03_extrapolar_peso.R - Extrapola los datos para predecir pesos en nuevas partidas.
Por ejemplo, para ejecutar 01_cargar_datos.R:

source("src/r/01_cargar_datos.R")

### 5. Consultar Documentación Adicional
Consulta la documentación adicional en /docs para más detalles sobre el uso y la estructura del proyecto.

### Recursos Adicionales
Documentación de R
Introducción a dplyr
Guía de ggplot2

### Licencia
Este proyecto está bajo la licencia MIT. Consulta el archivo LICENSE para más detalles.


