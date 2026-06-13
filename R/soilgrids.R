# R/soilgrids.R

#' Récupérer l'humidité du sol via l'API SoilGrids (ISRIC)
#'
#' @param lon Longitude du point
#' @param lat Latitude du point
#' @param depth Profondeur : "0-5cm", "5-15cm", "15-30cm"
#' @param property Propriété : "wv0033" (humidité vol.), "clay", "sand", "silt"
#' @return Data frame avec les valeurs de la propriété
#' @export
get_soilgrids_point <- function(lon, lat,
                                depth    = "0-5cm",
                                property = "wv0033") {
  url <- paste0(
    "https://rest.isric.org/soilgrids/v2.0/properties/query",
    "?lon=", lon,
    "&lat=", lat,
    "&property=", property,
    "&depth=", depth,
    "&value=mean"
  )
  resp <- httr2::request(url) |>
    httr2::req_timeout(30) |>
    httr2::req_perform()

  data <- httr2::resp_body_json(resp)

  val <- data$properties$layers[[1]]$depths[[1]]$values$mean
  unit <- data$properties$layers[[1]]$unit_measure$mapped_units

  return(data.frame(
    lon      = lon,
    lat      = lat,
    depth    = depth,
    property = property,
    value    = val,
    unit     = unit
  ))
}

#' Télécharger un raster d'humidité du sol depuis SoilGrids (WCS)
#'
#' @param bbox Vecteur c(xmin, ymin, xmax, ymax) en WGS84
#' @param output_path Chemin de sortie pour le GeoTIFF
#' @param property "wv0033" (défaut), "clay", "sand"
#' @param depth "0-5cm" (défaut)
#' @return Chemin du fichier téléchargé
#' @export
download_soilgrids_raster <- function(bbox,
                                      output_path = "data-raw/soilgrids.tif",
                                      property    = "wv0033",
                                      depth       = "0-5cm") {
  depth_code <- gsub("-", "_", gsub("cm", "", depth))
  layer_id   <- paste0(property, "_", depth_code, "cm_mean")

  url <- paste0(
    "https://maps.isric.org/mapserv?map=/map/", property, ".map",
    "&SERVICE=WCS&VERSION=2.0.1&REQUEST=GetCoverage",
    "&COVERAGEID=", layer_id,
    "&CRS=EPSG:4326",
    "&BBOX=", paste(bbox, collapse = ","),
    "&RESX=0.002&RESY=0.002",
    "&FORMAT=image/tiff"
  )

  dir.create(dirname(output_path), showWarnings = FALSE, recursive = TRUE)
  httr2::request(url) |>
    httr2::req_timeout(120) |>
    httr2::req_perform() |>
    httr2::resp_body_raw() |>
    writeBin(output_path)

  message("Raster SoilGrids enregistré : ", output_path)
  return(output_path)
}
