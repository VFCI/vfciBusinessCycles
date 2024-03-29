##
##  Script to call all other scripts in the project
##

## Reinstantiate Renv Environment
## (this should happen automatically when opening the project)
renv::restore()

## Data Cleaning
source("./code/clean-data-raw/bca_original_var_results.R")
source("./code/clean-data-raw/bca_replication_data.R")
source("./code/clean-data-raw/bca_current_data.R")

source("./code/clean-data-raw/vfci_data.R")
source("./code/clean-data-raw/vfciBC_data.R")

## BCA Replication
source("./code/bca-replication/classical-var-irf/replicate_bca_classical_VAR_IRF.R")
source("./code/bca-replication/classical-var-irf/replicate_bca_classical_VAR_IRF_boot.R")
source("./code/bca-replication/bayesian-var-irf/replicate_bca_bayesian_VAR_IRF_BVAR.R")
source("./code/bca-replication/bayesian-var-irf/replicate_bca_bayesian_VAR_IRF_bvartools.R")

## Rereun BCA with Current Data
source("./code/bca-replication/current-data-var-irf/current_data_classical_VAR_IRF.R")
source("./code/bca-replication/current-data-var-irf/current_data_bayesian_VAR_IRF.R")

## Build BCA Replication Reports
## Don't put spaces in document names
rmarkdown::render("./code/reports/classical_VAR_IRF_replication.RMD", "pdf_document", "ClassicalVARIRFReplication.pdf", "./reports/")
rmarkdown::render("./code/reports/classical_VAR_IRF_boot_replication.RMD", "pdf_document", "ClassicalVARIRFbootReplication.pdf", "./reports/")
rmarkdown::render("./code/reports/bayesian_VAR_IRF_replication.RMD", "pdf_document", "BayesianVARIRFReplication.pdf", "./reports/")
rmarkdown::render("./code/reports/compare_FD_TD_targetting.RMD", "pdf_document", "CompareFDTDTargetting.pdf", "./reports/")
rmarkdown::render("./code/reports/current_VAR_IRF.RMD", "pdf_document", "CurrentDataVARIRFs.pdf", "./reports/")


## VFCI Business Cycle
source("./code/vfci-bc/classical_vfcibc_VAR_IRF.R")

## VFCI BC reports
rmarkdown::render("./code/reports/vfciBC_data_summary.RMD", "pdf_document", "VFCIBusinessCycleDataSummary.pdf", "./reports/")
rmarkdown::render("./code/reports/vfciBC_classical_VAR_IRF.RMD", "pdf_document", "VFCIBusinessCycleVARIRFs.pdf", "./reports/")
rmarkdown::render("./code/reports/historical_shocks_decomposition.RMD", "pdf_document", "HistoricalShocksAndDecompositions.pdf", "./reports/")
rmarkdown::render("./code/reports/vfciBC_fgrXX.RMD", "pdf_document", "VFCIVariations.pdf", "./reports")
rmarkdown::render("./code/reports/compare_FD_TD_spacing.RMD", "pdf_document", "CompareFDTDSpacing.pdf", "./reports")
rmarkdown::render("./code/reports/vfciBC_allVARcharts.RMD", "pdf_document", "AllVARcharts.pdf", "./reports")

rmarkdown::render("./code/reports/business_cycle_frequencies.RMD", "pdf_document", "BusinessCycleFrequencies.pdf", "./reports")
rmarkdown::render("./code/reports/mean-vol-relationship.RMD", "pdf_document", "MeanVolRelationship.pdf", "./reports")
rmarkdown::render("./code/reports/estimate-vfci-from-VAR.RMD", "pdf_document", "EstimateVFCIfromVAR.pdf", "./reports")

## Run tests
testthat::test_dir("tests")
