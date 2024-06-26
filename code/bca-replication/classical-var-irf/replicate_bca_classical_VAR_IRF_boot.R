library(data.table)
library(vars)
library(svars)
library(fevdid)

## Pull the correct vintage of the BCA data
bcadata <- fread("./data-raw/bca_replication_data.csv") |>
  _[date <= as.Date("2017-01-01")]
x <- bcadata[, -"date"]

## Load the original BCA IRFs
bca_irf_df <- fread("./data-raw/bca_original_var_results.csv")

## Target the BC frequency and umemployment variable
bc_freqs <- c(2 * pi / 32, 2 * pi / 6)
target_var <- "unemployment"

## Fit the VAR
v <- VAR(x, p = 2, type = "const")

## Identify the shock
mv <- id_fevdfd(v, target = target_var, freqs = bc_freqs)

## Get the IRF
mv_irf <- vars::irf(mv, impulse = "Main", n.ahead = 40)$irf

## Bootstraps
boots <-
  bootstrap(
    mv, id_fevdfd, nboot = 1000, n_ahead = 40,
    method = "resample", design = "recursive", bias_adjust = TRUE,
    target = "unemployment", freqs = bc_freqs
  )

boot_df_resample_ba <-
  boots$IRF_df |>
  as.data.table() |>
  _[impulse == "Main"] |>
  _[, model := "classical_fd"] |>
  _[, version := "Replication"]

## Calculate the FEVD
fevdfd_df <-
  purrr::map(purrr::set_names(1:1000, 1:1000), function(i) {
    temp <- boots$VAR
    temp$B <- boots$B_boots[, , i]
    fevfd_df <- fevfd(temp)$fevfd
    fevfd_df
  }) |>
  purrr::list_rbind(names_to = "i") |>
  setDT()

fevdfd_df[, total := sum(fevfd), by = .(i, f, response)]
fevdfd_df[, fevdfd := fevfd / total]

boot_summ <-
  fevd_df |>
  _[impulse == "Main"] |>
  _[f %between% bc_freqs] |>
  _[, .(
    avg_fevdfd = mean(fevdfd),
    med_fevdfd = median(fevdfd),
    wavg_fevdfd = weighted.mean(fevdfd, total)
  ), by = .(
    i,
    impulse,
    response
  )]

boot_summ[, .(
  lower_wavg = quantile(wavg_fevdfd, 0.16),
  med_wavg = median(wavg_fevdfd),
  upper_wavg = quantile(wavg_fevdfd, 0.84)
), by = .(
  impulse,
  response
)]

## Some data wrangling to get a clean dataframe
## with original and replicated IRFs
bca_irf_df <- bca_irf_df |>
  _[, model := "classical_fd"] |>
  _[, version := "Original BCA"] |>
  setnames(c("pctl_16", "pctl_84"), c("lower", "upper"))

## Merge on VAR irf and bootstrap IRFs
irf_df <-
  merge(boot_df_resample_ba, mv_irf, by = c("h", "impulse", "response"))

comb_df <- rbindlist(list(
  bca_irf_df,
  irf_df
), use.names = TRUE, fill = TRUE)

fwrite(comb_df, "./data/bca-replication/replicated_bca_classical_VAR_IRF_boot.csv")
