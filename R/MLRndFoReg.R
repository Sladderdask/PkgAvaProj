#' MLRndFoReg
#'
#' Takes in dependent variables y and independent variables X and creates a predictive model and gives the stats for the predictions.
#' @param X A vector of vectors which contain values of independent variables.
#' @param y A vector of dependent variables corresponding to the dependent.
#'
#' @returns The model with all of its parameters
#'
#' @export
mlfun <- function(X, y) {
  # Load reticulate
  library(reticulate)

  # Ensure numpy and sklearn are available
  np <- import("numpy")
  sklearn <- import("sklearn")
  train_test_split <- sklearn$model_selection$train_test_split
  metrics <- sklearn$metrics
  RandomForestRegressor <- sklearn$ensemble$RandomForestRegressor

  # Convert R data frames to numpy arrays (if needed)
  X_np <- r_to_py(as.matrix(X))
  y_np <- r_to_py(as.numeric(y))

  # Split data
  split1 <- train_test_split(X_np, y_np, test_size = 0.2, random_state = 42)
  X_train <- split1[[1]]
  X_test  <- split1[[2]]
  y_train <- split1[[3]]
  y_test  <- split1[[4]]

  split2 <- train_test_split(X_train, y_train, test_size = 0.2, random_state = 42)
  X_train_final <- split2[[1]]
  X_val <- split2[[2]]
  y_train_final <- split2[[3]]
  y_val <- split2[[4]]

  # Model
  model <- RandomForestRegressor(criterion = "squared_error", random_state = 42)
  model$fit(X_train_final, y_train_final)

  # Predictions
  pred <- model$predict(X_val)

  # Metrics
  mae <- metrics$mean_absolute_error(y_val, pred)
  mse <- metrics$mean_squared_error(y_val, pred)
  rmse <- np$sqrt(mse)
  r2 <- metrics$r2_score(y_val, pred)

  # Print metrics
  cat("MAE:", mae, "\n")
  cat("MSE:", mse, "\n")
  cat("RMSE:", rmse, "\n")
  cat("R-squared:", r2, "\n")

  return(model)
}

