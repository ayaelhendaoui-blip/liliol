# R/visualize.R

#' Cartographier les bandes SAR ou l'humidité du sol
#' @param raster SpatRaster à visualiser
#' @param band Nom de la bande à afficher ("VV_dB", "VH_dB", "RVI", etc.)
#' @param title Titre de la carte
#' @param output_path Chemin d'export PNG/PDF (optionnel)
#' @return Objet tmap
#' @export
plot_sar_map <- function(raster, band = "VV_dB",
                         title = "Carte SAR",
                         output_path = NULL) {
  r <- raster[[band]]
  map <- tmap::tm_shape(r) +
    tmap::tm_raster(
      palette  = "RdYlGn",
      title    = band,
      midpoint = NA
    ) +
    tmap::tm_layout(
      title      = title,
      legend.outside = TRUE
    ) +
    tmap::tm_scale_bar() +
    tmap::tm_compass(position = c("right", "top"))

  if (!is.null(output_path)) {
    tmap::tmap_save(map, output_path)
    message("Carte enregistrée : ", output_path)
  }
  return(map)
}

#' Tracer l'évolution temporelle des signaux SAR
#' @param ts_data Data frame avec colonnes : date, VV, VH, culture
#' @param interactive Si TRUE, retourne un graphique plotly interactif
#' @return Graphique ggplot2 ou plotly
#' @export
plot_sar_timeseries <- function(ts_data, interactive = TRUE) {
  ts_long <- tidyr::pivot_longer(ts_data,
                                 cols     = c("VV", "VH"),
                                 names_to = "bande",
                                 values_to = "backscatter_dB")

  p <- ggplot2::ggplot(ts_long,
                       ggplot2::aes(x = date, y = backscatter_dB,
                                    color = bande, linetype = culture)) +
    ggplot2::geom_line(linewidth = 0.8) +
    ggplot2::geom_point(size = 2) +
    ggplot2::scale_color_manual(values = c(VV = "#2166AC", VH = "#D6604D")) +
    ggplot2::labs(
      title    = "Évolution temporelle du backscatter SAR",
      x        = "Date",
      y        = "Backscatter (dB)",
      color    = "Bande",
      linetype = "Culture"
    ) +
    ggplot2::theme_minimal(base_size = 13)

  if (interactive) return(plotly::ggplotly(p))
  return(p)
}

#' Carte leaflet interactive de l'humidité du sol
#' @param soil_raster SpatRaster d'humidité (ou data frame avec lon/lat/value)
#' @param parcelles Objet sf des parcelles agricoles (optionnel)
#' @return Carte leaflet interactive
#' @export
plot_soil_moisture_map <- function(soil_raster, parcelles = NULL) {
  pal <- leaflet::colorNumeric(
    palette = "RdYlBu",
    domain  = terra::values(soil_raster),
    reverse = TRUE,
    na.color = "transparent"
  )

  map <- leaflet::leaflet() |>
    leaflet::addProviderTiles("Esri.WorldImagery") |>
    leaflet::addRasterImage(
      x      = raster::raster(soil_raster),  # compatibilité leaflet
      colors = pal,
      opacity = 0.7
    ) |>
    leaflet::addLegend(
      pal    = pal,
      values = terra::values(soil_raster),
      title  = "Humidité sol (%vol.)",
      position = "bottomright"
    )

  if (!is.null(parcelles)) {
    map <- map |>
      leaflet::addPolygons(
        data   = parcelles,
        color  = "white",
        weight = 1.5,
        fillOpacity = 0,
        popup  = ~as.character(culture)
      )
  }
  return(map)
}

#' Graphique de validation : observé vs prédit
#' @param eval_result Résultat de evaluate_model()
#' @return Graphique ggplot2
#' @export
plot_model_validation <- function(eval_result) {
  df <- eval_result$predictions
  ggplot2::ggplot(df, ggplot2::aes(x = observed, y = predicted)) +
    ggplot2::geom_point(alpha = 0.6, color = "#2166AC", size = 2.5) +
    ggplot2::geom_abline(slope = 1, intercept = 0,
                         color = "red", linetype = "dashed") +
    ggplot2::geom_smooth(method = "lm", se = TRUE, color = "#4DAF4A") +
    ggplot2::labs(
      title    = "Validation du modèle : Observé vs Prédit",
      subtitle = paste0("RMSE = ", round(eval_result$RMSE, 2),
                        " | R² = ", round(eval_result$R2, 3)),
      x = "Humidité observée (%vol.)",
      y = "Humidité prédite (%vol.)"
    ) +
    ggplot2::theme_minimal(base_size = 13)
}
