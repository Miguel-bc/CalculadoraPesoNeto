# Calculadora Rango Pesos

## Descripción

**Calculadora Rango Pesos** es una aplicación interactiva desarrollada en **Shiny** para analizar y gestionar datos relacionados con pesos de productos. Esta herramienta permite visualizar estadísticas, ajustar formatos y gestionar datos de manera dinámica, proporcionando una interfaz intuitiva para el análisis y la edición de datos.

## Funcionalidades

### Interfaz de Usuario

La aplicación cuenta con una interfaz organizada en los siguientes componentes:

- **Panel de Control (Sidebar)**
  - **Rangos Programados (`sliderInput`)**: Selección del número de rangos para los formatos.
  - **Número de Partida (`selectInput`)**: Selección para filtrar los datos según el número de partida.
  - **Eliminar Outliers (`checkboxInput`)**: Activar o desactivar la eliminación de valores atípicos.
  - **Botones (`actionButton`)**:
    - **Nueva Tabla Formatos**: Reinicia la tabla de formatos.
    - **Guardar Tabla Formatos**: Guarda los cambios realizados en la tabla de formatos.

- **Panel Principal (Main Panel)**
  - **Estadísticas**: 
    - Histograma del porcentaje del peso neto total por formato.
    - Boxplot de pesos brutos por formato.
  - **Formatos**: 
    - Visualización y edición de la tabla de formatos.
  - **Pesos Partida**: 
    - Datos de pesos filtrados según la selección de partida.

### Lógica del Servidor

La aplicación maneja la lógica del servidor para procesar y actualizar los datos en función de las interacciones del usuario:

- **Filtrado de Datos**: Los datos se filtran por partida y se eliminan los outliers si se selecciona la opción correspondiente.
- **Cálculo de Formatos y Orden**: Se calculan formatos y órdenes para cada peso neto basado en los rangos definidos en la tabla de formatos.
- **Actualización Dinámica**: Actualización automática de la lista de partidas y el número de rangos.
- **Reinicio y Guardado de Tablas**: Funcionalidad para reiniciar o guardar los cambios en la tabla de formatos.

### Gráficos y Tablas

- **Histograma del Peso Neto por Formato**: Muestra la distribución del peso neto total por formato en forma de barras.
- **Boxplot de Pesos Brutos**: Visualiza la distribución de los pesos brutos por formato.
- **Tabla de Formatos**: Permite visualizar y editar la tabla de formatos.
- **Tabla de Pesos**: Muestra los datos de pesos filtrados.
- **Tabla Receta**: Resume los rangos de peso bruto para cada formato.

## Instalación

Para ejecutar la aplicación, asegúrate de tener instaladas las siguientes bibliotecas de R:

```r
install.packages(c("shiny", "shinythemes", "readxl", "DT", "openxlsx", "ggplot2", "tidyverse", "shinyalert"))
```
### Licencia
Este proyecto está bajo la licencia MIT. Consulta el archivo LICENSE para más detalles.


