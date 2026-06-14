#' Analyser l'évolution temporelle du signal SAR
#' @param ts_data Data frame avec colonnes date, VV, VH, culture
#' @return Liste avec statistiques et tendances
#' @export
analyze_sar_timeseries <- function(ts_data) {
  stats <- ts_data |>
    dplyr::group_by(culture) |>
    dplyr::summarise(
      VV_mean = mean(VV, na.rm = TRUE),
      VH_mean = mean(VH, na.rm = TRUE),
      VV_sd   = sd(VV, na.rm = TRUE),
      VH_sd   = sd(VH, na.rm = TRUE),
      n_dates = dplyr::n()
    )
  trend_VV <- lm(VV ~ as.numeric(date), data = ts_data)
  trend_VH <- lm(VH ~ as.numeric(date), data = ts_data)
  return(list(
    statistiques = stats,
    tendance_VV  = summary(trend_VV),
    tendance_VH  = summary(trend_VH)
  ))
}
