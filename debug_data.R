#!/usr/bin/env Rscript

# Script para debuggear estructura de datos JSON

library(jsonlite)

# Cargar datos JSON
cat("Cargando datos JSON...\n")
json_data <- fromJSON("nov/merida_completo_20251029_112334.json")

# Explorar estructura del primer registro
cat("Estructura del primer registro:\n")
print(names(json_data))

cat("\nPrimer registro coordinates:\n")
print(str(json_data$coordinates[1]))

cat("\nPrimer registro price:\n")
print(str(json_data$price[1]))

cat("\nPrimer registro rating:\n")
print(str(json_data$rating[1]))

# Verificar algunos valores específicos
cat("\nValores específicos del primer registro:\n")
cat("ID:", json_data$room_id[1], "\n")
if (!is.null(json_data$coordinates[1])) {
  coords <- json_data$coordinates[[1]]
  cat("Latitude:", coords$latitude, "\n")
  cat("Longitude:", coords$longitude, "\n")
}