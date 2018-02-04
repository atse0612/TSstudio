#'  Visualize of the Fitted and the Forecasted vs the Actual Values
#' @export fortest_ly test_forecast
#' @aliases fortest_ly
#' @param actual The full time series object (support "ts", "zoo" and "xts" formats)
#' @param forecast.obj The forecast output of the training set with horizon 
#' align to the length of the testing (support forecasted objects from the “forecast” package)
#' @param train Training partition, a subset of the first n observation in the series (not requiredthed)
#' @param test The testing (hold-out) partition 
#' @param Ygrid Logic,show the Y axis grid if set to TRUE
#' @param Xgrid Logic,show the X axis grid if set to TRUE
#' @param hover If TRUE add tooltip with information about the model accuracy
#' @description Visualize the fitted values of the training set and the forecast values of the testing set against the actual values of the series
#' @examples
#' \dontrun{
#' library(forecast)
#' data(USgas)
#' 
#' # Set the horizon of the forecast
#' h <- 12
#' 
#' # split to training/testing partition
#' split_ts <- ts_split(USgas, sample.out  = h)
#' train <- split_ts$train
#' test <- split_ts$test
#'
#' # Create forecast object
#' fc <- forecast(auto.arima(train, lambda = BoxCox.lambda(train)), h = h)
#'
#' # Plot the fitted and forecasted vs the actual values
#' test_forecast(actual = USgas, forecast.obj = fc, test = test)
#'}


test_forecast <- function(actual, forecast.obj,
                          train = NULL, test, 
                          Ygrid = FALSE, Xgrid = FALSE,
                          hover = TRUE) {
  `%>%` <- magrittr::`%>%`
  # Error handling
  if (!forecast::is.forecast(forecast.obj)) {
    stop("The class of theforecast object is not \"forecast\"")
  }
  if (base::length(forecast.obj$x) + base::length(test) != base::length(actual)) {
    stop("The length of the train and test sets are different from the length of the actual set")
  }
  if (!base::is.logical(Ygrid)) {
    warning("The value of \"Ygrid\" is not boolean, using the default option (FALSE)")
    Ygrid <- FALSE
  }
  
  if (!base::is.logical(Xgrid)) {
    warning("The value of 'Xgrid' is not boolean, using the default option (FALSE)")
    Xgrid <- FALSE
  }
  
  if(!base::is.logical(hover)) {
    warning("The value of 'hover' is not boolean, using the default option (TRUE)")
    hover <- TRUE
  }
  
  time_actual <- obj.name <- NULL
  
  obj.name <- base::deparse(base::substitute(actual))
  
  if (stats::is.ts(actual)) {
    time_actual <- stats::time(actual)
  } else if (zoo::is.zoo(actual) | xts::is.xts(actual)) {
    time_actual <- zoo::index(actual)
  }
  model_accuracy <- forecast::accuracy(forecast.obj, test)
  if(hover){
    text_fit <- base::paste("Model: ", forecast.obj$method,
                            "<br> Actual: ", round(actual,2),
                            "<br> Fitted Value: ", c(round(forecast.obj$fitted, 2), 
                                                     rep(NA, base::length(actual) - 
                                                           base::length(forecast.obj$x))),
                            "<br> Training Set",
                            "<br> MAPE: ",  round(model_accuracy[9], 2),
                            "<br> RMSE: ",  round(model_accuracy[3], 2),
                            "<br> Testing Set",
                            "<br> MAPE: ",  round(model_accuracy[10], 2),
                            "<br> RMSE: ",  round(model_accuracy[4], 2)
                            
    )
    
    text_forecast <- base::paste("Model: ", forecast.obj$method,
                                 "<br> Actual: ", round(actual,2),
                                 "<br> Forecasted Value: ", c(rep(NA, 
                                                                  base::length(actual) - 
                                                                    base::length(test)), 
                                                              round(forecast.obj$mean,2)),
                                 "<br> Training Set",
                                 "<br> MAPE: ",  round(model_accuracy[9], 2),
                                 "<br> RMSE: ",  round(model_accuracy[3], 2),
                                 "<br> Testing Set",
                                 "<br> MAPE: ",  round(model_accuracy[10], 2),
                                 "<br> RMSE: ",  round(model_accuracy[4], 2)
                                 
    )
    text_hover <- "text"
  } else {
    text_fit <- " "
    text_forecast <- " "
    text_hover <- "y"
  }
  p <- plotly::plot_ly() %>% 
    plotly::add_trace(x = time_actual, 
                      y = as.numeric(actual), 
                      mode = "lines+markers", 
                      name = "Actual", 
                      type = "scatter",
                      hoverinfo = "y"
    ) %>% 
    plotly::add_trace(x = time_actual, 
                      y = c(forecast.obj$fitted, 
                            rep(NA, base::length(actual) - 
                                  base::length(forecast.obj$x))), 
                      mode = "lines+markers", 
                      name = "Fitted", 
                      type = "scatter", 
                      line = list(color = "red"),
                      hoverinfo = ifelse(hover, "text", "y"),
                      text = text_fit
    ) %>% 
    plotly::add_trace(x = time_actual, 
                      y = c(rep(NA, 
                                base::length(actual) - 
                                  base::length(test)), 
                            forecast.obj$mean), 
                      mode = "lines+markers", 
                      name = "Forecasted", 
                      type = "scatter",
                      hoverinfo = ifelse(hover, "text", "y"),
                      text = text_forecast
    ) %>% 
    plotly::layout(title = base::paste(obj.name, " - Actual vs Forecasted and Fitted", sep = ""), 
                   xaxis = list(title = forecast.obj$method, showgrid = Xgrid), 
                   yaxis = list(title = obj.name, showgrid = Ygrid))
  
  return(p)
}

fortest_ly <- function(actual, forecast.obj,train = NULL, test, 
                       Ygrid = FALSE, Xgrid = FALSE,
                       hover = TRUE) {
  .Deprecated("test_forecast")
  test_forecast(actual= actual, forecast.obj = forecast.obj,
                train = train, test = test, 
                Ygrid = Ygrid, Xgrid = Xgrid,
                hover = hover)
}