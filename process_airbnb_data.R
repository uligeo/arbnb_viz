#!/usr/bin/env Rscript

# Script para procesar datos de Airbnb de formato JSON a GeoJSON
# Procesa datos crudos y genera archivo para dashboard de hexágonos H3

library(jsonlite)
library(sf)
library(dplyr)

# Crear directorio outputs si no existe
if (!dir.exists("outputs")) {
  dir.create("outputs")
}

# Cargar datos JSON
cat("Cargando datos JSON...\n")
json_data <- fromJSON("nov/merida_completo_20251029_112334.json")

# Extraer información relevante y crear dataframe
cat("Procesando datos...\n")

processed_data <- data.frame(
  id = json_data$room_id,
  latitude = json_data$coordinates$latitude,
  longitude = json_data$coordinates$longitud,
  precio_total = json_data$price$unit$amount,
  price_per_night = json_data$price$unit$amount,  # Por simplicidad
  calificacion = json_data$rating$value,
  num_reseñas = as.numeric(ifelse(is.na(json_data$rating$reviewCount), 0, json_data$rating$reviewCount)),
  stringsAsFactors = FALSE
) %>%
  # Filtrar registros válidos
  filter(
    !is.na(latitude),
    !is.na(longitude),
    !is.na(precio_total),
    precio_total > 0,  # Precio válido
    latitude > 20.5, latitude < 21.5,  # Rango válido para Mérida
    longitude > -90.5, longitude < -89.0  # Rango válido para Mérida
  )

cat(sprintf("Registros procesados: %d\n", nrow(processed_data)))

# Convertir a objeto espacial sf
cat("Convirtiendo a formato espacial...\n")
listings_sf <- st_as_sf(
  processed_data,
  coords = c("longitude", "latitude"),
  crs = 4326  # WGS84
)

# Guardar como GeoJSON
output_file <- "outputs/01_listings_core.geojson"
cat(sprintf("Guardando en %s...\n", output_file))

st_write(
  listings_sf,
  output_file,
  driver = "GeoJSON",
  delete_dsn = TRUE  # Sobrescribir si existe
)

# Mostrar estadísticas básicas
cat("\n=== RESUMEN DE DATOS PROCESADOS ===\n")
cat(sprintf("Total propiedades: %d\n", nrow(listings_sf)))
cat(sprintf("Precio promedio: $%.0f MXN\n", mean(listings_sf$precio_total, na.rm = TRUE)))
cat(sprintf("Precio mediano: $%.0f MXN\n", median(listings_sf$precio_total, na.rm = TRUE)))
cat(sprintf("Rango de precios: $%.0f - $%.0f MXN\n",
           min(listings_sf$precio_total, na.rm = TRUE),
           max(listings_sf$precio_total, na.rm = TRUE)))

# Estadísticas de calificación
valid_ratings <- sum(!is.na(listings_sf$calificacion) & listings_sf$calificacion > 0)
if (valid_ratings > 0) {
  cat(sprintf("Propiedades con calificación: %d (%.1f%%)\n",
             valid_ratings,
             valid_ratings / nrow(listings_sf) * 100))
  cat(sprintf("Calificación promedio: %.2f/5.0\n",
             mean(listings_sf$calificacion[listings_sf$calificacion > 0], na.rm = TRUE)))
}

cat("\nArchivo GeoJSON generado exitosamente!\n")