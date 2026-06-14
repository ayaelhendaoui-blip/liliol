#' Données réelles d'humidité du sol — SoilGrids ISRIC
#'
#' Données d'humidité volumétrique du sol téléchargées depuis
#' l'API SoilGrids (ISRIC) pour 5 points agricoles au Maroc.
#'
#' @format Un data frame avec 5 lignes et 6 variables :
#' \describe{
#'   \item{id}{Identifiant du point}
#'   \item{lon}{Longitude (WGS84)}
#'   \item{lat}{Latitude (WGS84)}
#'   \item{depth}{Profondeur du sol (0-5cm)}
#'   \item{value}{Humidité volumétrique (\%vol)}
#'   \item{culture}{Type de culture observée}
#' }
#' @source ISRIC SoilGrids \url{https://soilgrids.org}
"soil_data_real"
