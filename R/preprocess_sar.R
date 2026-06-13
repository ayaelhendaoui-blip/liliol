# R/preprocess_sar.R

#' Convertir les valeurs SAR en décibels
#' @param sar_raster SpatRaster avec bandes VV et/ou VH (valeurs linéaires)
#' @return SpatRaster en dB
#' @export
convert_to_db <- function(sar_raster) {
  db <- 10 * log10(sar_raster)
  names(db) <- paste0(names(sar_raster), "_dB")
  return(db)
}

#' Nettoyer les données SAR (filtre anti-speckle + valeurs aberrantes)
#' @param sar_raster SpatRaster
#' @param filter_size Taille du filtre médian (défaut : 3)
#' @return SpatRaster nettoyé
#' @export
clean_sar_data <- function(sar_raster, filter_size = 3) {
  cleaned <- terra::focal(sar_raster,
                          w   = filter_size,
                          fun = median,
                          na.rm = TRUE)
  cleaned <- terra::clamp(cleaned, lower = -35, upper = 5, values = NA)
  names(cleaned) <- names(sar_raster)
  return(cleaned)
}

#' Calculer les indices radar SAR
#' @param sar_raster SpatRaster avec bandes VV et VH (en dB)
#' @return SpatRaster avec ratio VV/VH et RVI
#' @export
calculate_sar_indices <- function(sar_raster) {
  VV <- sar_raster[["VV_dB"]]
  VH <- sar_raster[["VH_dB"]]

  # Repasser en linéaire pour le RVI
  VV_lin <- 10^(VV / 10)
  VH_lin <- 10^(VH / 10)

  ratio <- VV / VH                            # ratio dB
  rvi   <- (4 * VH_lin) / (VV_lin + VH_lin)  # RVI [0-1]

  indices <- c(ratio, rvi)
  names(indices) <- c("ratio_VV_VH", "RVI")
  return(indices)
}
