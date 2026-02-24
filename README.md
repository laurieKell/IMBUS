# IMBUS Package

**IMBUS: Implementing More and Better Use of ICES Survey Data**

## Overview

The IMBUS package consolidates and extends useful functions from multiple R packages for IMBUS T4.4: Assessment of Survey-based Indices. It provides standardized workflows for survey index calculation, length-based indicators, auxiliary data extraction, and validation tools.

## Installation

```r
# Install from GitHub (when available)
devtools::install_github("laurieKell/IMBUS")

# Or install from local source
devtools::install("path/to/IMBUS")
```

## Package Sources

This package consolidates functions from:

- **FLCore**: Core data classes (FLStock, FLIndex, FLQuant), `indicators.len`, and operations
- **FLRebuild**: `jabba` functions
- **FLSkill**: ROC functions
- **icesdata**: DATRAS data access and ICES database integration
- **Spatial indicators**: Integrated spatial indicator functions (spreadingarea, gini, positivearea, proppres, equivalentarea, densitylevel, spi, extentofoccurrence)

## Key Functions

### Survey Indices
- `calc_survey_index()` - Calculate standardized survey index
- `standardise_survey_index()` - Apply standardisation procedures

### Length-based Indicators
- `calc_lbi()` - Calculate length-based indicators
- `calc_length_indicators()` - Comprehensive length indicator calculation

### Auxiliary Data
- `extract_auxiliary_data()` - Extract auxiliary data from surveys
- `format_for_assessment()` - Format data for assessment models

### Validation
- `validate_indicator()` - Validate indicators using ROC analysis
- `diagnostic_plots()` - Generate diagnostic plots

### Spatial Indicators
- `calc_spatial_indicators()` - Calculate spatial indicators from survey data
- `spreadingarea()`, `gini()`, `positivearea()`, `proppres()`, `equivalentarea()`, `densitylevel()`, `spi()`, `extentofoccurrence()` - Individual spatial indicator functions
- `cumdenscurve()`, `cumdensdata()` - Cumulative density functions

### Workflows
- `imbus_workflow()` - Complete workflow for indicator calculation

### Data Access
- `get_datras_table()` - Download DATRAS data from ICES

## Usage Example

```r
library(IMBUS)

# Download DATRAS data
data <- get_datras_table("HL", "NS-IBTS", "2020", "1")

# Calculate length-based indicators
lbi <- calc_lbi(data, indicators = c("lmean", "lbar", "l95"))

# Calculate survey index
index <- calc_survey_index(data, method = "stratified", area_weight = TRUE)

# Extract auxiliary data
aux_data <- extract_auxiliary_data(data, data_type = "F_index")

# Validate indicator
validation <- validate_indicator(lbi$lmean, reference_status, method = "roc")
```

## Integration with IMBUS Tasks

- **T4.1**: Uses standardized DATRAS workflows
- **T4.2**: Integrates spatial distribution models
- **T4.3**: Uses growth parameters for priors
- **T4.5**: Provides data for Shiny app visualization

## Documentation

See package vignettes for detailed examples and workflows.

## License

GPL-3

## Contact

IMBUS Project Team
