# R/import_sar_data.R

#' Importer des données Sentinel-1 réelles
#'
#' Télécharge et importe des images SAR Sentinel-1 via l'API STAC Copernicus
#' ou depuis des fichiers GeoTIFF locaux.
#'
#' @param vv_path Chemin vers le fichier GeoTIFF de la bande VV
#' @param vh_path Chemin vers le fichier GeoTIFF de la bande VH
#' @param aoi Objet sf ou SpatVector définissant la zone d'étude (optionnel)
#' @param crs Système de coordonnées cible, défaut "EPSG:4326"
#' @return Un SpatRaster avec les bandes VV et VH
#' @examples
#' \dontrun{
#' # Télécharger d'abord via rstac (voir download_sentinel1())
#' sar <- import_sar_data("vv.tif", "vh.tif", aoi = ma_zone)
#' }
#' @export
import_sar_data <- function(vv_path, vh_path, aoi = NULL, crs = "EPSG:4326") {
  vv <- terra::rast(vv_path)
  vh <- terra::rast(vh_path)
  sar <- c(vv, vh)
  names(sar) <- c("VV", "VH")
  if (!is.null(aoi)) {
    aoi_vect <- if (inherits(aoi, "sf")) terra::vect(aoi) else aoi
    sar <- terra::crop(sar, aoi_vect)
  }
  sar <- terra::project(sar, crs)
  return(sar)
}

#' Télécharger des images Sentinel-1 via l'API STAC Copernicus
#'
#' @param bbox Vecteur numérique c(xmin, ymin, xmax, ymax) en WGS84
#' @param date_start Date de début "YYYY-MM-DD"
#' @param date_end Date de fin "YYYY-MM-DD"
#' @param output_dir Répertoire de sortie
#' @return Chemins vers les fichiers téléchargés
#' @export
download_sentinel1 <- function(bbox, date_start, date_end, output_dir = "data-raw/") {
  if (!requireNamespace("rstac", quietly = TRUE))
    stop("Le package rstac est requis. Installez-le avec install.packages('rstac')")

  stac_obj <- rstac::stac("https://earth-search.aws.element84.com/v1")

  items <- stac_obj |>
    rstac::stac_search(
      collections = "sentinel-1-grd",
      bbox        = bbox,
      datetime    = paste0(date_start, "/", date_end)
    ) |>
    rstac::get_request()

  message("Nombre d'images trouvées : ", length(items$features))

  dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

  rstac::assets_download(
    items,
    asset_names = c("VV", "VH"),
    output_dir  = output_dir
  )

  return(list.files(output_dir, pattern = "\\.tif$", full.names = TRUE))
}
