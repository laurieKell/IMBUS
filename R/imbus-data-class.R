#' IMBUSData S4 Class
#'
#' Container class for IMBUS survey data used to calculate F and effort proxies.
#' Holds effort data, spatial data, species distribution, and gear efficiency data.
#'
#' @slot effort data.frame. Swept area effort data with columns for gear, spatial unit, time, and swept area.
#' @slot spatial data.frame. Spatial units with associated areas.
#' @slot species data.frame. Species distribution data (optional), with columns for species, age, spatial unit, time, and relative abundance.
#' @slot gear_efficiency data.frame. Gear efficiency by species and age (optional).
#' @slot metadata list. Metadata including field names (gearfld, spatialfld, timefld, etc.) and other configuration.
#'
#' @name IMBUSData-class
#' @rdname IMBUSData-class
#' @exportClass IMBUSData
#'
#' @examples
#' \dontrun{
#' # Create IMBUSData object
#' data = new("IMBUSData",
#'   effort = effortDf,
#'   spatial = spatialDf,
#'   metadata = list(gearfld = "Gear", spatialfld = "StatRec", timefld = "Year")
#' )
#' }
setClass("IMBUSData",
  slots = c(
    effort = "data.frame",
    spatial = "data.frame",
    species = "data.frame",
    gear_efficiency = "data.frame",
    metadata = "list"
  ),
  prototype = list(
    effort = data.frame(),
    spatial = data.frame(),
    species = data.frame(),
    gear_efficiency = data.frame(),
    metadata = list(
      gearfld = "Regulated_gear",
      spatialfld = "StatRec",
      timefld = "Year",
      areafld = "AREA_KM2",
      sweptareafld = "SweptArea_KM2",
      speciesfld = "Code"
    )
  ),
  validity = function(object) {
    # Basic validation
    if (nrow(object@effort) == 0) {
      return("effort slot cannot be empty")
    }
    if (nrow(object@spatial) == 0) {
      return("spatial slot cannot be empty")
    }
    return(TRUE)
  }
)

#' Create IMBUSData Object
#'
#' Constructor function for IMBUSData class.
#'
#' @param effort data.frame. Swept area effort data.
#' @param spatial data.frame. Spatial units with areas.
#' @param species data.frame. Species distribution data (optional).
#' @param gear_efficiency data.frame. Gear efficiency data (optional).
#' @param gearfld character. Name of gear field (default: "Regulated_gear").
#' @param spatialfld character. Name of spatial unit field (default: "StatRec").
#' @param timefld character. Name of time field (default: "Year").
#' @param areafld character. Name of area field (default: "AREA_KM2").
#' @param sweptareafld character. Name of swept area field (default: "SweptArea_KM2").
#' @param speciesfld character. Name of species field (default: "Code").
#'
#' @return IMBUSData object
#' @export
#'
#' @examples
#' \dontrun{
#' data = imbusData(effort = effortDf, spatial = spatialDf)
#' }
imbusData <- function(effort, spatial, species = data.frame(), gear_efficiency = data.frame(),
                      gearfld = "Regulated_gear", spatialfld = "StatRec", timefld = "Year",
                      areafld = "AREA_KM2", sweptareafld = "SweptArea_KM2", speciesfld = "Code") {
  
  metadata = list(
    gearfld = gearfld,
    spatialfld = spatialfld,
    timefld = timefld,
    areafld = areafld,
    sweptareafld = sweptareafld,
    speciesfld = speciesfld
  )
  
  new("IMBUSData",
      effort = effort,
      spatial = spatial,
      species = species,
      gear_efficiency = gear_efficiency,
      metadata = metadata)
}
