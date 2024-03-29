library(data.table)
library(purrr)
library(vars)
library(svars)
library(fevdid)

data <-
  fread(here::here("./data/vfciBC_data.csv")) |>
  _[date <= as.Date("2017-01-01")]

data <-
  data[, .(
    date,
    output,
    investment,
    consumption,
    hours_worked,
    unemployment,
    labor_share,
    interest,
    inflation,
    productivity,
    TFP,
    vfci = vfci_fgr10gdpc1
  )]

var_variables <- names(data)[-1]
lags <- 2

## Fit the VAR
v <- VAR(data[, -"date"], p = lags, type = "const")

## Function to Fit Cholesky to Target Variable
x <- "unemployment"
chol_fun <- function(x) {
  chol_data <- data[, c("date", x, var_variables[var_variables != x]), with = FALSE]
  vc <- VAR(chol_data[, -"date"], p = lags, type = "const")
  c <- id.chol(vc)
  class(c) <- c("fevdvar", "svars")
  c$B <- c$B * -1
  return(c)
}

## Target Each Variable, store as list
cv_l <-
  var_variables |>
  set_names() |>
  map(chol_fun)

## Compute the IRFs
cv_irf_dt <-
  var_variables |>
  map(function(x) {
    print(x)
    res <- irf(cv_l[[x]], n.ahead = 40)$irf
    res$target_variable <- x
    res$response <- as.character(res$response)
    res
  }) |>
  list_rbind() |>
  setDT()

## Compute the Shocks
## Compute the FEVD in Frequency Domain
cv_fevdfd_dt <-
  var_variables |>
  map(function(x) {
    res <- fevdfd(cv_l[[x]])$fevdfd
    res$target_variable <- x
    res$response <- as.character(res$response)
    res
  }) |>
  list_rbind() |>
  setDT()

## Compute the Shocks
cv_shock_dt <-
  var_variables |>
  map(function(x) {
    res <- hs(cv_l[[x]])$hs
    res$target_variable <- x
    res$date <- rep(data[-c(1:lags), "date"][[1]], length(var_variables))
    res
  }) |>
  list_rbind() |>
  setDT()

## Compute the Contribution of the Shocks
cv_contr_dt <-
  var_variables |>
  map(function(x) {
    res <- hd(cv_l[[x]])$hd
    res$target_variable <- x
    res$date <- rep(data[-c(1:lags), "date"][[1]], length(var_variables))
    res$response <- as.character(res$response)
    res
  }) |>
  list_rbind() |>
  setDT()
