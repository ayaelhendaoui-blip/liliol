#' Extraire les features SAR par parcelle agricole
#' @param sar_raster SpatRaster avec bandes VV/VH
#' @param parcelles Objet sf des parcelles
#' @return Data frame avec VV, VH, RVI moyens par parcelle
#' @export
extract_sar_features <- function(sar_raster, parcelles) {
  parcelles_vect <- terra::vect(parcelles)
  extracted <- terra::extract(sar_raster, parcelles_vect, fun = mean, na.rm = TRUE)
  result <- cbind(
    id      = parcelles$id,
    culture = parcelles$culture,
    extracted[, -1]
  )
  return(as.data.frame(result))
}
