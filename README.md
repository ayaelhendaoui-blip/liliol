
# agroSAR

[![R-CMD-check](https://github.com/ayaelhendaoui-blip/agroSAR/workflows/R-CMD-check/badge.svg)]()
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)]()

Package R pour le suivi agricole par radar Sentinel-1.

## Installation

``` r
devtools::install_github("ayaelhendaoui-blip/agroSAR")
```

## Utilisation rapide

``` r
library(agroSAR)

# 1. Télécharger Sentinel-1
fichiers <- download_sentinel1(
  bbox       = c(-5.5, 33.5, -5.0, 34.0),
  date_start = "2024-03-01",
  date_end   = "2024-03-31",
  output_dir = "data-raw/"
)

# 2. Importer + prétraiter
sar    <- import_sar_data(fichiers["VV"], fichiers["VH"])
sar_db <- convert_to_db(clean_sar_data(sar))

# 3. Humidité du sol SoilGrids
sol <- get_soilgrids_point(lon = -5.2, lat = 33.7)

# 4. Carte interactive
plot_sar_map(sar_db, band = "VV_dB", title = "Sentinel-1 VV — Mars 2024")
```

## Fonctions principales

| Fonction                   | Description                               |
|----------------------------|-------------------------------------------|
| `download_sentinel1()`     | Télécharge les images Sentinel-1 via STAC |
| `import_sar_data()`        | Importe et recadre les rasters VV/VH      |
| `convert_to_db()`          | Convertit en décibels                     |
| `clean_sar_data()`         | Filtre le bruit speckle                   |
| `calculate_sar_indices()`  | Calcule RVI et ratio VV/VH                |
| `get_soilgrids_point()`    | Récupère l’humidité sol depuis SoilGrids  |
| `estimate_soil_moisture()` | Modèle ML d’estimation humidité           |
| `classify_crop_stage()`    | Classification des stades culturaux       |
| `plot_sar_map()`           | Carte radar agricole                      |
| `plot_sar_timeseries()`    | Série temporelle SAR interactive          |
