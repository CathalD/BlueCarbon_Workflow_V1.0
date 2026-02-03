# Blue Carbon MMRV Workflow
 
**Date:** January, 2026 
**Language:** R  
**Platform:** RStudio  
-----
## Table of Contents

1. [Overview](#overview)
2. [Required Inputs](#required-inputs)
3. [Expected Outputs](#expected-outputs)
4. [Implementation Guide](#implementation-guide)
5. [References](#references)
6. [Appendix A - Scientific Foundation](#Appendix A - scientific-foundation)


## Overview

This workflow automates the harmonization, analysis, mapping, and reporting of carbon stocks from Coastal Blue carbon sediments. The system processes field sediment core data through spatial modeling to produce carbon stock estimates with quantified uncertainty.

## Required Inputs (*Note input photos of inputs)
A) Basic Reporting
1. Carbon stock core locational data as a spreadsheet in this format - (link corelocations.csv)
2. Carbon stock sample lab data as a spreadsheet in this format (link coresamples.csv)
3. Project boundary and (optional) strata in one of these format (GeoJson, CSV, .shp. etc)

B) Spatial extrapolation with Remote Sensing models
*All of above from "Basic reporting" +
1. Remote sensing covariates
   - Can use any custom set of RS variables as desired
   - Option to follow this Google Earth Engine workflow that will automatically extract covairates

C). Bayesian-based analysis
* all from A) Basic Reporting (optional) can also handle RS inpu
1. Prior carbon map in a geoTiff (.tiff) format

D). Transfer Learning Analysis
*All from B) Spatial extrapolation with remote sensing models
1. Uses the global dataset from Janousek et al. () database
Option 1 can use pre-load covairiates from this script (Link: GEE pythin API script)
Option 2 can add personal covariates (ensure local and global covairates align)
Option 3 uses Google Deepminds embeded learning to build a "similarity" matrix for local cores and global dataset


## Expected Outputs (* Note add photos of file outputs + example outputs)


Basic Reporting

**Module P2_02:** Exploratory Data Analysis
- Generates summary statistics by stratum
- Creates depth profile visualizations
- Identifies outliers and data quality issues
- Produces diagnostic plots

**Module P2_03:** Depth Harmonization
- Implements equal-area spline functions
- Standardizes to depth intervals (Defualt aligns with VM0033 Methods 7.5, 22.5, 40, 75 cm)
- Extrapolates to maximum depth (100 cm)
- Validates mass balance
- Exports harmonized profiles for spatial modeling

**Module P2_04:** Spatial Predictions - Kriging
- Automated variogram modeling
- Universal kriging predictions
- Cross-validation assessment
- Uncertainty quantification via kriging variance
- Sample size power analysis

Remote sensing informed reporting

**Module P2_05:** Spatial Predictions - Random Forest
- Integration with Google Earth Engine covariates
- Random Forest model training
- Area of Applicability assessment
- Spatial cross-validation
- Variable importance analysis

**Module P2_06:** Carbon Stock Calculation
- Aggregates depth-specific predictions
- Calculates total carbon stocks (0-100 cm)
- Compares Kriging vs. Random Forest estimates
- Generates carbon stock maps
- Exports summary tables by stratum

**Module P2_07:** MMRV Reporting
- Generates VM0033 verification package
- Creates comprehensive HTML reports
- Exports spatial data for GIS verification
- Provides sampling recommendations
- Produces quality assurance documentation

Appendix A - Scientific Foudnations of this workflow
#### Depth Harmonization

**Equal-Area Spline Functions** (Bishop et al. 1999; Malone et al. 2009):
- Fits continuous depth functions to irregular sampling intervals
- Preserves mass balance (∫SOC·BD·dz constant)
- Prevents artifacts from interval averaging
- Enables standardized depth reporting for VM0033 compliance

**Hybrid Approach** (implemented in Module P2_03):
- Equal-area splines for profiles with ≥3 samples
- Mass-preserving linear interpolation for 2-sample profiles
- Exponential decay extrapolation beyond deepest sample (Holmquist et al. 2018)

**References:**
- Bishop, T.F.A., McBratney, A.B., & Laslett, G.M. (1999). "Modelling soil attribute depth functions with equal-area quadratic smoothing splines." Geoderma, 91(1-2), 27-45. https://doi.org/10.1016/S0016-7061(99)00003-8
- Malone, B.P., McBratney, A.B., Minasny, B., & Laslett, G.M. (2009). "Mapping continuous depth functions of soil carbon storage and available water capacity." Geoderma, 154(1-2), 138-152. https://doi.org/10.1016/j.geoderma.2009.10.007
- Holmquist, J.R., Windham-Myers, L., Blaauw, M., et al. (2018). "Accuracy and Precision of Tidal Wetland Soil Carbon Mapping in the Conterminous United States." Scientific Reports, 8(1), 9478. https://doi.org/10.1038/s41598-018-26948-7

#### Spatial Interpolation - Kriging

**Universal Kriging** (Goovaerts 1997; Webster & Oliver 2007):
- Geostatistical method accounting for spatial autocorrelation
- Variogram modeling captures spatial dependency structure
- Best Linear Unbiased Prediction (BLUP) with uncertainty estimates
- Suitable when covariates unavailable or sample size limited

**Implementation** (Module P2_04):
- Automated variogram fitting (exponential, spherical, Gaussian models)
- Cross-validation for model selection
- Prediction standard errors for uncertainty quantification

**References:**
- Goovaerts, P. (1997). Geostatistics for Natural Resources Evaluation. Oxford University Press.
- Webster, R., & Oliver, M.A. (2007). Geostatistics for Environmental Scientists, 2nd Edition. Wiley. https://doi.org/10.1002/9780470517277

#### Spatial Interpolation - Random Forest

**Machine Learning Approach** (Breiman 2001; Hengl et al. 2018):
- Ensemble decision tree method using remote sensing covariates
- Handles non-linear relationships and variable interactions
- Feature importance quantification
- Area of Applicability assessment (Meyer & Pebesma 2021)

**Implementation** (Module P2_05):
- Integrates Landsat, Sentinel-1 SAR, topographic data
- Ranger package for efficient random forest
- CAST package for spatial cross-validation and AOA
- Uncertainty via quantile regression forests

**References:**
- Breiman, L. (2001). "Random Forests." Machine Learning, 45(1), 5-32. https://doi.org/10.1023/A:1010933404324
- Hengl, T., Nussbaum, M., Wright, M.N., Heuvelink, G.B.M., & Gräler, B. (2018). "Random forest as a generic framework for predictive modeling of spatial and spatio-temporal variables." PeerJ, 6, e5518. https://doi.org/10.7717/peerj.5518
- Meyer, H., & Pebesma, E. (2021). "Predicting into unknown space? Estimating the area of applicability of spatial prediction models." Methods in Ecology and Evolution, 12(9), 1620-1633. https://doi.org/10.1111/2041-210X.13650
- https://soilmapper.org/
- 
#### Bayesian Integration (Optional)

**Prior Knowledge Transfer** (Wadoux et al. 2021):
- Combines site-specific likelihood with global prior distribution
- Reduces uncertainty when local samples limited
- Weight calibration via empirical Bayes or cross-validation

**Implementation** (Part 3 modules):
- Global database as informative prior (Holmquist et al. 2018; Macreadie et al. 2019)
- Bayesian updating via conjugate Normal-Normal framework
- Posterior mean and credible intervals for conservative estimates

**References:**
- Wadoux, A.M.J.-C., Brus, D.J., & Heuvelink, G.B.M. (2021). "Accounting for non-stationary variance in geostatistical mapping of soil properties." Geoderma, 324, 114138. https://doi.org/10.1016/j.geoderma.2018.03.010
- Holmquist, J.R., et al. (2018). "Coastal and Marine Ecological Classification Standard." NOAA Technical Memorandum NOS NCCOS 258.

#### Transfer Learning (Optional)

**Global-to-Local Knowledge Transfer** (Module P4_05):
- Instance weighting (Wadoux et al. 2021) to identify relevant global samples
- Hierarchical modeling across depth intervals
- Bias correction for local conditions

**Global Database:**
- Coastal Carbon Network synthesis (Holmquist et al. 2018)
- Smithsonian MarineGEO global cores
- Harmonized to VM0033 depths

**References:**
- Wadoux, A.M.J.-C., Samuel-Rosa, A., Poggio, L., & Mulder, V.L. (2021). "A note on knowledge discovery and machine learning in digital soil mapping." European Journal of Soil Science, 71(2), 133-136. https://doi.org/10.1111/ejss.12909

#### Carbon Stock Calculation

**Methodology** (Howard et al. 2014; IPCC 2014):

```
Carbon Stock (kg C/m²) = ∫[SOC (g/kg) × BD (g/cm³) × 10] dz

Where:
  SOC = Soil organic carbon concentration (g C / kg dry soil)
  BD  = Bulk density (g dry soil / cm³)
  dz  = Depth increment (cm)
  10  = Unit conversion factor
```

**Bulk Density Handling:**
- Measured BD used when available
- Ecosystem-specific defaults (Morris et al. 2016) when missing:
  - Saltmarsh (EM): 0.52 g/cm³
  - Seagrass (SG): 0.89 g/cm³
  - Mangrove (FL): 0.38 g/cm³

**References:**
- Howard, J., Hoyt, S., Isensee, K., Pidgeon, E., & Telszewski, M. (2014). Coastal Blue Carbon: Methods for Assessing Carbon Stocks and Emissions Factors in Mangroves, Tidal Salt Marshes, and Seagrass Meadows. Conservation International, Intergovernmental Oceanographic Commission of UNESCO, International Union for Conservation of Nature. Arlington, Virginia, USA.
- IPCC (2014). 2013 Supplement to the 2006 IPCC Guidelines for National Greenhouse Gas Inventories: Wetlands. Hiraishi, T., Krug, T., Tanabe, K., et al. (eds). IPCC, Switzerland.
- Morris, J.T., Barber, D.C., Callaway, J.C., et al. (2016). "Contributions of organic and inorganic matter to sediment volume and accretion in tidal wetlands at steady state." Earth's Future, 4(4), 110-121. https://doi.org/10.1002/2015EF000334

#### Uncertainty Quantification

**Conservative Approach** (IPCC 2006, VM0033):
- Propagation of measurement, spatial, and model uncertainties
- Lower 95% confidence bound for crediting
- Monte Carlo simulation when analytical propagation infeasible

**Sources of Uncertainty:**
1. **Measurement:** Lab analytical precision (typically 2-5% for SOC)
2. **Spatial:** Kriging variance or RF quantile spread
3. **Model:** Cross-validation RMSE, variogram uncertainty
4. **Temporal:** Inter-annual variability (if multi-year data)








