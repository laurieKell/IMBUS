#' Calculate F Proxies
#'
#' Calculate multiple fishing mortality proxies from effort, spatial, species, 
#' and gear efficiency data. Supports calculation of:
#' - Feff: Effort-based F = SweptArea / Area
#' - Fgear: Gear-corrected F = Feff × GearEfficiency
#' - Fdist: Distribution-weighted F = Feff × RelativeAbundance
#' - Frealised: Realised F = Fdist × GearEfficiency
#'
#' @param object IMBUSData object.
#' @param proxies character vector. Which F proxies to calculate: 
#'   "Feff", "Fgear", "Fdist", "Frealised". Default: all available.
#' @param fished logical. If TRUE, calculate Feff based on fished area only.
#' @param agg_effort logical. If TRUE, aggregate swept area effort.
#'
#' @return data.frame with calculated F proxies. Columns depend on which proxies 
#'   are calculated and what data is available.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' data = imbusData(effort = effortDf, spatial = spatialDf, 
#'                   species = speciesDf, gear_efficiency = gearEffDf)
#' fProxies = calcFproxies(data, proxies = c("Feff", "Fgear", "Fdist", "Frealised"))
#' }
setGeneric("calcFproxies", function(object, ...) standardGeneric("calcFproxies"))

#' @rdname calcFproxies
setMethod("calcFproxies", signature(object = "IMBUSData"),
  function(object, 
           proxies = c("Feff", "Fgear", "Fdist", "Frealised"),
           fished = TRUE,
           agg_effort = TRUE) {
    
    # Extract metadata
    gearFld = object@metadata$gearfld
    spatialFld = object@metadata$spatialfld
    timeFld = object@metadata$timefld
    speciesFld = object@metadata$speciesfld
    
    # Check what data is available
    hasSpecies = nrow(object@species) > 0
    hasGearEff = nrow(object@gear_efficiency) > 0
    
    # Determine which proxies can be calculated
    availableProxies = "Feff"  # Always available
    
    if (hasGearEff && !hasSpecies) {
      availableProxies = c(availableProxies, "Fgear")
    }
    
    if (hasSpecies) {
      availableProxies = c(availableProxies, "Fdist")
      if (hasGearEff) {
        availableProxies = c(availableProxies, "Frealised")
      }
    }
    
    # Filter requested proxies to those available
    proxies = intersect(proxies, availableProxies)
    
    if (length(proxies) == 0) {
      stop("No requested proxies can be calculated with available data")
    }
    
    # Calculate Feff (always needed)
    feff = calcFeff(object, fished = fished, agg_effort = agg_effort)
    
    # If only Feff requested, return it
    if (identical(proxies, "Feff")) {
      return(feff)
    }
    
    # Calculate Fgear (if gear efficiency but no species data)
    if ("Fgear" %in% proxies && hasGearEff && !hasSpecies) {
      gearEff = object@gear_efficiency
      
      # Melt gear efficiency to long format
      gearCols = setdiff(colnames(gearEff), c(speciesFld, "Age"))
      gearEffLong = stats::reshape(gearEff,
                                      direction = "long",
                                      varying = gearCols,
                                      v.names = "Efficiency",
                                      timevar = gearFld,
                                      times = gearCols,
                                      idvar = c(speciesFld, "Age"))
      rownames(gearEffLong) = NULL
      
      # Merge Feff with gear efficiencies
      f = merge(feff, gearEffLong,
                 by.x = gearFld, by.y = gearFld,
                 all.x = TRUE, allow.cartesian = TRUE)
      
      # Calculate Fgear
      f$Fgear = f$Feff * f$Efficiency
      
      return(f)
    }
    
    # Calculate Fdist and Frealised (if species data available)
    if (hasSpecies && any(c("Fdist", "Frealised") %in% proxies)) {
      speciesData = object@species
      
      # Pad ages in species data (add missing age combinations)
      speciesData = padAges(object, speciesData)
      
      # Get gear names from Feff
      gearNames = unique(feff[[gearFld]])
      
      # Combine Feff with species data
      f = combineFeffSpecies(feff, speciesData, gearNames, object@metadata)
      
      # Calculate Fdist
      if ("Fdist" %in% proxies) {
        f$Fdist = f$Feff * f$R  # R is relative abundance
      }
      
      # Calculate Frealised (if gear efficiency available)
      if ("Frealised" %in% proxies && hasGearEff) {
        gearEff = padGearEfficiency(object, object@gear_efficiency, gearNames)
        
        # Melt gear efficiency
        gearCols = setdiff(colnames(gearEff), c(speciesFld, "Age"))
        gearEffLong = stats::reshape(gearEff,
                                        direction = "long",
                                        varying = gearCols,
                                        v.names = "Efficiency",
                                        timevar = gearFld,
                                        times = gearCols,
                                        idvar = c(speciesFld, "Age"))
        rownames(gearEffLong) = NULL
        
        # Merge with f
        f = merge(f, gearEffLong,
                   by = c(speciesFld, "Age", gearFld),
                   all.x = TRUE)
        
        # Calculate Frealised
        f$Frealised = f$Fdist * f$Efficiency
      }
      
      # Remove Feff if not requested (as per swaf logic)
      if (!"Feff" %in% proxies) {
        f$Feff = NULL
      }
      
      return(f)
    }
    
    # Fallback: return Feff
    return(feff)
  }
)

#' Pad Ages in Species Data
#'
#' Internal function to pad missing age combinations in species data.
#'
#' @param object IMBUSData object.
#' @param speciesdata data.frame. Species distribution data.
#'
#' @return data.frame with padded ages.
#'
#' @keywords internal
padAges <- function(object, speciesdata) {
  timeFld = object@metadata$timefld
  speciesFld = object@metadata$speciesfld
  spatialFld = object@metadata$spatialfld
  
  # Get required columns
  forCols = colnames(speciesdata)[colnames(speciesdata) %in% 
                                     c(timeFld, speciesFld, "Age", spatialFld)]
  speciesdata = speciesdata[, c(forCols, "R"), drop = FALSE]
  
  result = data.frame()
  
  for (sp in unique(speciesdata[[speciesFld]])) {
    sloop = speciesdata[speciesdata[[speciesFld]] == sp, ]
    
    maxAge = max(sloop$Age, na.rm = TRUE)
    minAge = min(sloop$Age, na.rm = TRUE)
    allAges = minAge:maxAge
    
    for (yr in unique(sloop[[timeFld]])) {
      yloop = sloop[sloop[[timeFld]] == yr, ]
      missingAges = allAges[!allAges %in% unique(yloop$Age)]
      
      if (length(missingAges) > 0) {
        missingDf = data.frame(
          sp, yr, yloop[[spatialFld]][1], missingAges, 0,
          stringsAsFactors = FALSE
        )
        colnames(missingDf) = c(speciesFld, timeFld, spatialFld, "Age", "R")
        yloop = rbind(yloop, missingDf)
      }
      
      # Complete all combinations using expand.grid
      allCombos = expand.grid(
        spatial = unique(yloop[[spatialFld]]),
        time = yr,
        species = sp,
        age = allAges,
        stringsAsFactors = FALSE
      )
      colnames(allCombos) = c(spatialFld, timeFld, speciesFld, "Age")
      
      # Merge with existing data
      yloop = merge(allCombos, yloop,
                     by = c(spatialFld, timeFld, speciesFld, "Age"),
                     all.x = TRUE)
      yloop$R[is.na(yloop$R)] = 0
      
      result = rbind(result, yloop)
    }
  }
  
  return(result)
}

#' Combine Feff with Species Data
#'
#' Internal function to merge Feff with species distribution data.
#'
#' @param Feff data.frame. Feff estimates.
#' @param speciesdata data.frame. Species distribution data.
#' @param gear_names character vector. Gear names.
#' @param metadata list. Field name metadata.
#'
#' @return data.frame with merged data.
#'
#' @keywords internal
combineFeffSpecies <- function(Feff, speciesdata, gear_names, metadata) {
  gearFld = metadata$gearfld
  spatialFld = metadata$spatialfld
  timeFld = metadata$timefld
  
  # Spread Feff by gear
  feffWide = stats::reshape(Feff[Feff[[gearFld]] %in% gear_names, 
                                    c(spatialFld, gearFld, timeFld, "Feff")],
                               direction = "wide",
                               idvar = c(spatialFld, timeFld),
                               timevar = gearFld,
                               v.names = "Feff")
  
  # Rename columns to remove "Feff." prefix
  gearCols = grep("^Feff\\.", colnames(feffWide), value = TRUE)
  newNames = sub("^Feff\\.", "", gearCols)
  colnames(feffWide)[colnames(feffWide) %in% gearCols] = newNames
  
  # Merge with species data
  f = merge(speciesdata, feffWide,
             by.x = c(spatialFld, timeFld),
             by.y = c(spatialFld, timeFld),
             all.x = TRUE)
  
  # Melt back to long format
  fLong = stats::reshape(f,
                           direction = "long",
                           varying = gear_names,
                           v.names = "Feff",
                           timevar = gearFld,
                           times = gear_names,
                           idvar = setdiff(colnames(f), c(gearFld, gear_names)))
  rownames(fLong) = NULL
  
  # Set NA Feff to 0 (no fishing by that gear)
  fLong$Feff[is.na(fLong$Feff)] = 0
  
  return(fLong)
}

#' Pad Gear Efficiency
#'
#' Internal function to pad missing ages in gear efficiency data.
#'
#' @param object IMBUSData object.
#' @param gearefficiency data.frame. Gear efficiency data.
#' @param gear_names character vector. Gear names.
#'
#' @return data.frame with padded gear efficiency.
#'
#' @keywords internal
padGearEfficiency <- function(object, gearefficiency, gear_names) {
  speciesFld = object@metadata$speciesfld
  
  if (nrow(object@species) > 0) {
    # Use species data to determine desired ages
    desired = unique(object@species[, c("Age", speciesFld)])
    present = unique(gearefficiency[, c("Age", speciesFld)])
    
    absent = desired[!paste0(desired$Age, desired[[speciesFld]]) %in%
                      paste0(present$Age, present[[speciesFld]]), ]
    
    if (nrow(absent) > 0) {
      absent[, gear_names] = NA
      gearefficiency = rbind(gearefficiency, absent)
    }
    
    gearefficiency = gearefficiency[order(gearefficiency[[speciesFld]], 
                                           gearefficiency$Age), ]
  }
  
  # Use last observation carried forward for each species
  for (spp in unique(gearefficiency[[speciesFld]])) {
    chunk = gearefficiency[gearefficiency[[speciesFld]] == spp, ]
    for (gear in gear_names) {
      chunk[[gear]] = zoo::na.locf(chunk[[gear]], na.rm = FALSE)
    }
    gearefficiency[gearefficiency[[speciesFld]] == spp, ] = chunk
  }
  
  return(gearefficiency)
}
