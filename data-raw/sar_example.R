
set.seed(42)
n <- 50
sar_example <- data.frame(
  id      = 1:n,
  date    = rep(seq(as.Date("2024-01-01"), by = "12 days", length.out = 10), 5),
  VV      = rnorm(n, mean = -12, sd = 2),
  VH      = rnorm(n, mean = -18, sd = 2),
  culture = sample(c("blé", "maïs", "jachère"), n, replace = TRUE),
  soil_moisture = runif(n, 15, 40)
)
usethis::use_data(sar_example, overwrite = TRUE)
