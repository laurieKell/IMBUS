# IMBUS Package

**IMBUS: Implementing More and Better Use of ICES Survey Data**

## Overview

The IMBUS package consolidates and extends useful functions from multiple R packages for IMBUS T4.4: Assessment of Survey-based Indices. It provides standardized workflows for DATRAS data access, F and effort proxy calculations, and validation tools.

## Installation

```r
# Install from GitHub
devtools::install_github("laurieKell/IMBUS")

# Or install from local source
devtools::install("path/to/IMBUS")
```

## Package Sources

This package consolidates functions from:

- **FLCore**: Core data classes (FLStock, FLIndex, FLQuant), `indicators.len`, and operations
- **FLRebuild**: `jabba` functions
- **FLSkill**: ROC functions (via `roc()` wrapper)
- **icesdata**: DATRAS data access and ICES database integration

## Currently Implemented Functions

### Data Access
- `get_datras_table()` - Download DATRAS data from ICES database

### Validation
- `roc()` - ROC (Receiver Operating Characteristic) analysis wrapper for FLSkill::roc2

### F and Effort Proxies
- `IMBUSData` - S4 class for holding survey data (effort, spatial, species, gear efficiency)
- `imbusData()` - Constructor function for IMBUSData objects
- `calcFeff()` - Calculate effort-based fishing mortality (Feff = SweptArea / Area)
- `calcFproxies()` - Calculate multiple F proxies:
  - **Feff**: Effort-based F = SweptArea / Area
  - **Fgear**: Gear-corrected F = Feff × GearEfficiency
  - **Fdist**: Distribution-weighted F = Feff × RelativeAbundance
  - **Frealised**: Realised F = Fdist × GearEfficiency

## Usage Examples

### Download DATRAS Data

```r
library(IMBUS)

# Download haul data for North Sea IBTS Q1 1988
dfDatras = get_datras_table(
  recordtype = "HH",
  survey = "NS-IBTS",
  year = "1988",
  quarter = "1"
)
```

### Calculate F Proxies

```r
library(IMBUS)

# Create IMBUSData object
data = imbusData(
  effort = effortDf,      # Swept area by gear/spatial/time
  spatial = spatialDf,    # Spatial units with areas
  species = speciesDf,     # Optional: species distribution
  gear_efficiency = gearEffDf  # Optional: gear efficiency
)

# Calculate basic Feff
feff = calcFeff(data, fished = TRUE, agg_effort = TRUE)

# Calculate all available F proxies
fProxies = calcFproxies(data, 
                        proxies = c("Feff", "Fgear", "Fdist", "Frealised"),
                        fished = TRUE,
                        agg_effort = TRUE)
```

### ROC Analysis

```r
library(IMBUS)

# Use ROC function (wraps FLSkill::roc2)
rocResult = roc(indicator, referenceStatus)
```

## Integration with IMBUS Tasks

- **T4.1**: Uses standardized DATRAS workflows
- **T4.2**: Integrates spatial distribution models
- **T4.3**: Uses growth parameters for priors
- **T4.5**: Provides data for Shiny app visualization

## Re-exported Functions

The package re-exports useful functions from dependencies:

- **FLCore**: `FLStock`, `FLIndex`, `FLQuant`, `indicators.len`
- **FLRebuild**: `jabba`

## Documentation

See package help files for detailed function documentation:
- `?get_datras_table`
- `?roc`
- `?IMBUSData`
- `?imbusData`
- `?calcFeff`
- `?calcFproxies`

## License

GPL-3

## Contact

IMBUS Project Team  
Email: imbus@ices.dk  
GitHub: https://github.com/laurieKell/IMBUS
