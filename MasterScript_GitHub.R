## ============================================================================
## BLUE CARBON MMRV WORKFLOW: REMOTE IMPORT & STEP-BY-STEP EXECUTION
## ============================================================================

# ---- STEP 0: LOCAL ENVIRONMENT & DATA SETUP ----
# Overview: Initializes the local project structure and downloads all necessary 
# scripts and raw data files directly from the GitHub repository.

rm(list = ls())
setwd("~/Desktop/CoastalBC_GitHubTest") # Project Root

# Repository configuration
repo_base <- "https://raw.githubusercontent.com/cathald/northstarproject_coastalbluecarbonmmrv/main/NorthStarProject_CoastalBlueCarbonMMRV/"
data_raw_url <- paste0(repo_base, "data_raw/")
data_global_url <- paste0(repo_base, "data_global/")

# Function to fetch single files
fetch_file <- function(file_path) {
  dir.create(dirname(file_path), showWarnings = FALSE, recursive = TRUE)
  download.file(paste0(repo_base, file_path), destfile = file_path, mode = "wb")
}

# 1. Download Core Infrastructure
infra <- c("blue_carbon_config.R", "P1_0a_install_packages.R", "P1_0b_setup_directories.R")
lapply(infra, fetch_file)
source("P1_0a_install_packages.R")

# 2. Bulk Download 'data_raw' and 'data_global' Files (Templates & Sample Data)
# Note: For public repos, we explicitly list the files to download
raw_files <- c("data_raw/core_locations.csv", "data_raw/core_samples.csv", 
               "data_raw/Janousek_Core_Locations.csv", "data_raw/Janousek_Samples.csv",
               "data_global/Global_Core_Locations.csv", "data_global/Global_Core_Samples.csv", "data_global/global_cores_with_gee_covariates.csv")
lapply(raw_files, fetch_file)

# 2.2 Setup Folders
source("P1_0b_setup_directories.R")

# 3. Download All Processing Scripts
scripts <- c("P1_01_data_prep_bluecarbon.R", "P2_02_exploratory_analysis_bluecarbon.R",
             "P2_3a_Depth_Harmonization_Local.R", "P2_04_raster_predictions_kriging_bluecarbon.R",
             "P2_05_raster_predictions_rf_bluecarbon.R", "P2_06_carbon_stock_calculation_bluecarbon.R",
             "P2_07_mmrv_reporting_bluecarbon.R")
lapply(scripts, fetch_file)

cat("\n✓ SETUP COMPLETE: Scripts and raw data successfully imported.\n")

# ---- MODULE 01: DATA PREPARATION & QA/QC ----
# Overview: Cleans raw field data, applies bulk density defaults, and validates 
# site readiness against VM0033 precision and sample size standards.
# Inputs: 'data_raw/core_locations.csv', 'data_raw/core_samples.csv'
# Outputs: 'data_processed/cores_clean_bluecarbon.csv' (Cleaned Data), 
#          'diagnostics/data_prep/vm0033_compliance_report.csv' (Compliance)
source("P1_01_data_prep_bluecarbon.R")

# ---- MODULE 02: EXPLORATORY DATA ANALYSIS ----
# Overview: Performs visual inspections of sediment profiles and spatial density 
# to identify outliers and verify stratum-level carbon distributions.
# Inputs: 'data_processed/cores_clean_bluecarbon.rds'
# Outputs: 'diagnostics/' Folder (Standardized Depth Profile and Distribution Plots)
source("P2_02_exploratory_analysis_bluecarbon.R")

# ---- MODULE 03: DEPTH HARMONIZATION ----
# Overview: Standardizes core samples of varying lengths into fixed depth intervals 
# (7.5, 22.5, 40, 75cm) using mass-preserving equal-area spline functions.
# Inputs: Cleaned core data from Module 01.
# Outputs: 'data_processed/cores_harmonized_bluecarbon.rds' (Standardized Profiles)
source("P2_3a_Depth_Harmonization_Local.R")

# ---- MODULE 04: SPATIAL PREDICTIONS (KRIGING) ----
# Overview: Uses universal kriging to model carbon stocks across the project site, 
# accounting for spatial autocorrelation and providing quantified uncertainty.
# Inputs: Harmonized core data from Module 03.
# Outputs: 'outputs/predictions/kriging/' (Stock and Uncertainty Rasters .tif)
source("P2_04_raster_predictions_kriging_bluecarbon.R")

# ---- MODULE 05: SPATIAL PREDICTIONS (RANDOM FOREST) ----
# Overview: Integrates field data with remote sensing covariates (NDVI, Elevation, SAR) 
# to produce machine-learning driven carbon stock maps and applicability masks.
# Inputs: Raster covariates in 'covariates/' folder.
# Outputs: 'outputs/predictions/rf/' (ML Prediction Rasters and AOA Masks)
source("P2_05_raster_predictions_rf_bluecarbon.R")

# ---- MODULE 06: CARBON STOCK CALCULATION ----
# Overview: Aggregates depth-specific maps into a final 0-100cm total carbon stock 
# inventory, comparing geostatistical and machine learning results.
# Inputs: Prediction rasters from Modules 04 and 05.
# Outputs: 'outputs/carbon_stocks/total_carbon_stock_0-100cm.tif' (Final Inventory)
source("P2_06_carbon_stock_calculation_bluecarbon.R")

# ---- MODULE 07: MMRV REPORTING ----
# Overview: Generates a comprehensive, interactive verification package including 
# all diagnostics and maps for final standard compliance and auditing.
# Inputs: All processed diagnostics, maps, and stock calculations.
# Outputs: 'outputs/mmrv_reports/vm0033_verification_package.html' (Final Package)
source("P2_07_mmrv_reporting_bluecarbon.R")
