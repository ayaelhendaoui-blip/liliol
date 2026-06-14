# data-raw/soil_data_real.R
# Données réelles téléchargées depuis SoilGrids ISRIC
# Date : 2024

library(agroSAR)

points <- data.frame(
  id  = 1:5,
  lon = c(-5.0, -5.2, -5.4, -5.1, -5.3),
  lat = c(33.9, 33.7, 33.5, 33.8, 33.6)
)

resultats <- lapply(1:nrow(points), function(i) {
  get_soilgrids_point(
    lon      = points$lon[i],
    lat      = points$lat[i],
    depth    = "0-5cm",
    property = "wv0033"
  )
})

soil_data_real <- do.call(rbind, resultats)
soil_data_real$id      <- points$id
soil_data_real$culture <- c("blé", "maïs", "orge", "jachère", "blé")

usethis::use_data(soil_data_real, overwrite = TRUE)
