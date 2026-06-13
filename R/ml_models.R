# R/ml_models.R

#' Estimer l'humidité du sol par régression ou Random Forest
#' @param sar_features Data frame avec colonnes VV, VH, ratio_VV_VH
#' @param field_data Data frame terrain avec colonne soil_moisture
#' @param method "lm" ou "rf"
#' @return Modèle entraîné (lm ou randomForest)
#' @export
estimate_soil_moisture <- function(sar_features, field_data,
                                   method = c("lm", "rf")) {
  method <- match.arg(method)
  df <- merge(sar_features, field_data, by = "id")

  if (method == "lm") {
    model <- lm(soil_moisture ~ VV + VH + ratio_VV_VH, data = df)
  } else {
    model <- randomForest::randomForest(
      soil_moisture ~ VV + VH + ratio_VV_VH,
      data  = df,
      ntree = 300,
      importance = TRUE
    )
  }
  return(model)
}

#' Classifier les stades de croissance des cultures
#' @param sar_features Data frame avec colonnes VV, VH, RVI, ratio_VV_VH
#' @param labels Vecteur de stades observés ("début", "développement", "maturité")
#' @param method "rf" ou "svm"
#' @return Modèle de classification entraîné
#' @export
classify_crop_stage <- function(sar_features, labels,
                                method = c("rf", "svm")) {
  method <- match.arg(method)
  df <- cbind(sar_features, stage = as.factor(labels))

  if (method == "rf") {
    model <- randomForest::randomForest(
      stage ~ VV + VH + RVI + ratio_VV_VH,
      data      = df,
      ntree     = 300,
      importance = TRUE
    )
  } else {
    if (!requireNamespace("e1071", quietly = TRUE))
      stop("Installez e1071 pour utiliser SVM")
    model <- e1071::svm(
      stage ~ VV + VH + RVI + ratio_VV_VH,
      data   = df,
      kernel = "radial"
    )
  }
  return(model)
}

#' Évaluer les performances d'un modèle
#' @param model Modèle entraîné
#' @param test_data Data frame de test
#' @param type "regression" ou "classification"
#' @return Liste avec métriques et graphiques
#' @export
evaluate_model <- function(model, test_data, type = c("regression", "classification")) {
  type <- match.arg(type)

  if (type == "regression") {
    pred <- predict(model, test_data)
    obs  <- test_data$soil_moisture
    rmse <- sqrt(mean((pred - obs)^2, na.rm = TRUE))
    r2   <- cor(pred, obs, use = "complete.obs")^2
    return(list(RMSE = rmse, R2 = r2,
                predictions = data.frame(observed = obs, predicted = pred)))
  } else {
    pred <- predict(model, test_data)
    obs  <- test_data$stage
    cm   <- table(Observed = obs, Predicted = pred)
    acc  <- sum(diag(cm)) / sum(cm)
    return(list(accuracy = acc, confusion_matrix = cm))
  }
}
