library(testthat)
library(terra)

test_that("convert_to_db retourne des valeurs négatives", {
  r <- terra::rast(nrows = 3, ncols = 3, vals = rep(0.05, 9))
  names(r) <- "VV"
  res <- convert_to_db(r)
  expect_true(all(terra::values(res) < 0, na.rm = TRUE))
  expect_equal(names(res), "VV_dB")
})

test_that("calculate_sar_indices retourne RVI entre 0 et 1", {
  vv <- terra::rast(nrows = 3, ncols = 3, vals = rep(-12, 9))
  vh <- terra::rast(nrows = 3, ncols = 3, vals = rep(-18, 9))
  r  <- c(vv, vh)
  names(r) <- c("VV_dB", "VH_dB")
  indices  <- calculate_sar_indices(r)
  rvi_vals <- terra::values(indices[["RVI"]])
  expect_true(all(rvi_vals >= 0 & rvi_vals <= 1, na.rm = TRUE))
})

test_that("get_soilgrids_point retourne un data frame", {
  skip_if_offline()
  res <- get_soilgrids_point(lon = -5.0, lat = 33.9)
  expect_s3_class(res, "data.frame")
  expect_true("value" %in% names(res))
})
