#' Générer un rapport HTML ou PDF du projet agroSAR
#'
#' @param output_format "html" ou "pdf"
#' @param output_file Nom du fichier de sortie (optionnel)
#' @param sar_data Data frame avec les données SAR (optionnel)
#' @param soil_data Data frame avec les données SoilGrids (optionnel)
#' @param eval_result Résultat de evaluate_model() (optionnel)
#' @param ts_data Data frame série temporelle SAR (optionnel)
#' @param output_dir Dossier de sortie du rapport
#' @return Chemin vers le rapport généré
#' @export
generate_report <- function(output_format = c("html", "pdf"),
                            output_file   = NULL,
                            sar_data      = NULL,
                            soil_data     = NULL,
                            eval_result   = NULL,
                            ts_data       = NULL,
                            output_dir    = "output/") {

  output_format <- match.arg(output_format)

  # Créer le dossier de sortie
  dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

  # Nom du fichier automatique
  if (is.null(output_file)) {
    output_file <- paste0("rapport_agroSAR_",
                          format(Sys.Date(), "%Y%m%d"),
                          ifelse(output_format == "pdf", ".pdf", ".html"))
  }

  # Chercher le template — mode développement en priorité
  template <- file.path("inst", "rmd", "rapport_agroSAR.Rmd")

  if (!file.exists(template)) {
    # Sinon chercher dans le package installé
    template <- system.file("rmd", "rapport_agroSAR.Rmd", package = "agroSAR")
  }

  if (!file.exists(template) || !nzchar(template)) {
    stop(
      "Template introuvable.\n",
      "Vérifiez que le fichier existe : inst/rmd/rapport_agroSAR.Rmd\n",
      "Chemin actuel : ", getwd()
    )
  }

  message("📄 Template trouvé : ", template)

  rmarkdown::render(
    input         = template,
    output_format = if (output_format == "pdf") "pdf_document" else "html_document",
    output_file   = output_file,
    output_dir    = output_dir,
    params = list(
      sar_data    = sar_data,
      soil_data   = soil_data,
      eval_result = eval_result,
      ts_data     = ts_data
    ),
    quiet = FALSE
  )

  message("✅ Rapport généré : ", file.path(output_dir, output_file))
  return(invisible(file.path(output_dir, output_file)))
}
