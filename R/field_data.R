#' Importer les données terrain (CSV ou shapefile)
#' @param path Chemin vers le fichier CSV ou shapefile
#' @param type "csv" ou "shapefile"
#' @return Objet sf avec les données terrain
#' @export
import_field_data <- function(path, type = c("csv", "shapefile")) {
  type <- match.arg(type)
  if (type == "csv") {
    df  <- read.csv(path)
    data <- sf::st_as_sf(df, coords = c("lon", "lat"), crs = 4326)
  } else {
    data <- sf::st_read(path, quiet = TRUE)
  }
  return(data)
}
