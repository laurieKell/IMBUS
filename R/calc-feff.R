#' Calculate Effort-based Fishing Mortality (Feff)
#'
#' Calculates Feff = SweptArea / TotalArea from effort and spatial data.
#' This is the basic effort-based fishing mortality proxy.
#'
#' @param object IMBUSData object containing effort and spatial data.
#' @param fished logical. If TRUE, calculate Feff based on fished area only. 
#'   If FALSE, include all spatial units (unfished areas = 0).
#' @param agg_effort logical. If TRUE, aggregate (sum) swept area effort to 
#'   gear, spatial unit and year.
#'
#' @return data.frame with Feff estimates, including columns for gear, spatial unit, 
#'   time, swept area, area, and Feff.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' data = imbusData(effort = effortDf, spatial = spatialDf)
#' feff = calcFeff(data, fished = TRUE, agg_effort = TRUE)
#' }
setGeneric("calcFeff", function(object, ...) standardGeneric("calcFeff"))

#' @rdname calcFeff
setMethod("calcFeff", signature(object = "IMBUSData"),
  function(object, fished = TRUE, agg_effort = TRUE) {
    
    # Extract metadata
    gearFld = object@metadata$gearfld
    spatialFld = object@metadata$spatialfld
    timeFld = object@metadata$timefld
    areaFld = object@metadata$areafld
    sweptAreaFld = object@metadata$sweptareafld
    
    # Extract data
    effortData = object@effort
    spatialData = object@spatial
    
    # Validate required columns exist
    requiredEffort = c(timeFld, spatialFld, gearFld, sweptAreaFld)
    missingEffort = setdiff(requiredEffort, colnames(effortData))
    if (length(missingEffort) > 0) {
      stop(paste("Missing columns in effort data:", paste(missingEffort, collapse = ", ")))
    }
    
    requiredSpatial = c(spatialFld, areaFld)
    missingSpatial = setdiff(requiredSpatial, colnames(spatialData))
    if (length(missingSpatial) > 0) {
      stop(paste("Missing columns in spatial data:", paste(missingSpatial, collapse = ", ")))
    }
    
    # Retain only the columns that are used
    effortData = effortData[, c(timeFld, spatialFld, gearFld, sweptAreaFld), drop = FALSE]
    
    # Aggregate (sum) swept area effort to gear, spatial unit and year
    if (agg_effort) {
      effortData = stats::aggregate(
        effortData[[sweptAreaFld]],
        by = list(
          gear = effortData[[gearFld]],
          spatial = effortData[[spatialFld]],
          time = effortData[[timeFld]]
        ),
        FUN = sum,
        na.rm = TRUE
      )
      colnames(effortData) = c(gearFld, spatialFld, timeFld, sweptAreaFld)
    }
    
    # If not fished, add all spatial units from spatialData to effortData
    if (!fished) {
      # Get all unique combinations
      allSpatial = unique(spatialData[[spatialFld]])
      allGear = unique(effortData[[gearFld]])
      allTime = unique(effortData[[timeFld]])
      
      # Create complete grid
      completeGrid = expand.grid(
        spatial = allSpatial,
        gear = allGear,
        time = allTime,
        stringsAsFactors = FALSE
      )
      colnames(completeGrid) = c(spatialFld, gearFld, timeFld)
      
      # Merge with effort data, filling missing with 0
      effortData = merge(completeGrid, effortData, 
                          by = c(spatialFld, gearFld, timeFld), 
                          all.x = TRUE)
      effortData[[sweptAreaFld]][is.na(effortData[[sweptAreaFld]])] = 0
    }
    
    # Merge effort and spatial data
    feff = merge(effortData, spatialData[, c(spatialFld, areaFld), drop = FALSE],
                  by = spatialFld, all.x = TRUE)
    
    # Calculate Feff: Area trawled divided by full area of the rectangle
    feff$Feff = feff[[sweptAreaFld]] / feff[[areaFld]]
    
    # Remove any infinite or NaN values
    feff$Feff[!is.finite(feff$Feff)] = NA
    
    return(feff)
  }
)
