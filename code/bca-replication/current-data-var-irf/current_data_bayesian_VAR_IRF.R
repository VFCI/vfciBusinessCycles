##
##  Uses the package `bvartools` to create a Bayesian VAR
##  Then identify the main shock with the `fevdid` package
##
require(data.table)
require(bcadata)
require(bvartools)
require(vars)
require(fevdid)
library(vfciBCHelpers)

## Business cycle frequency
bc_freqs <- c(2 * pi / 32, 2 * pi / 6)
tv <- "unemployment"

## Load data
bcadata <- fread("./data-raw/bca_current_data.csv")
data <- ts(bcadata[, -"date"], start = year(bcadata[[1, "date"]]), frequency = 4)

## Read in original variance priors
priors  <- bca_mn_priors(data, lags = 2, 0.2, 0.5, 2, 10^5)

## Fit frequentist VAR
v <- bvartools::gen_var(data, p = 2, deterministic = "const")

## Fit Replication
## BCA uses 49000 for burnin, but 1000 much faster and very close
bv_rep <- estimate_bvartools(v, priors, burnin = 5000)

mbv_rep_fd <- id_fevdfd(bv_rep, tv, bc_freqs, 1000)
mbv_rep_td4 <- id_fevdtd(bv_rep, tv, 4)
mbv_rep_td632 <- id_fevdtd(bv_rep, tv, 6:32)

irf_df_rep_fd <- vars::irf(mbv_rep_fd, n.ahead = 40) |> setDT()
irf_df_rep_td4 <- vars::irf(mbv_rep_td4, n.ahead = 40) |> setDT()
irf_df_rep_td632 <- vars::irf(mbv_rep_td632, n.ahead = 40) |> setDT()

irf_df_rep_fd[, version := "current"][, model := "bayesian_fd"]
irf_df_rep_td4[, version := "current"][, model := "bayesian_td4"]
irf_df_rep_td632[, version := "current"][, model := "bayesian_td632"]

## Combind data.frames
df <- rbindlist(list(
  irf_df_rep_fd[impulse == "Main"],
  irf_df_rep_td4[impulse == "Main"],
  irf_df_rep_td632[impulse == "Main"]
), use.names = TRUE, fill = TRUE)

fwrite(df, "./data//bca-replication/current_data/current_bca_bayesian_VAR_IRF.csv")
