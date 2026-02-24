#' Spatial Indicator Functions
#'
#' Spatial indicator functions for measuring aggregation, distribution, and spatial extent
#' of fish populations from survey data. These functions were integrated from the spatind package.
#'
#' @name spatial-indicators
NULL

#' Calculate Spreading Area
#'
#' Calculate the area over which a species is spread based on survey data.
#'
#' @param x Numeric vector. Longitude coordinates
#' @param y Numeric vector. Latitude coordinates
#' @param z Numeric vector. Catch per unit area or density values
#' @param w Numeric vector. Optional area weights
#' @param threshold Numeric. Minimum density threshold (default: 0)
#' @return Numeric. Spreading area value
#' @export
spreadingarea <- function(x, y, z, w = NULL, threshold = 0) {
  if (is.null(w)) {
    # Calculate area based on convex hull of positive catches
    idx <- which(z > threshold)
    if (length(idx) < 3) return(0)
    
    # Simple area calculation using bounding box
    x_range <- diff(range(x[idx], na.rm = TRUE))
    y_range <- diff(range(y[idx], na.rm = TRUE))
    
    # Approximate area (assuming degrees, rough conversion)
    area <- x_range * y_range * 111 * 111 * cos(mean(y[idx], na.rm = TRUE) * pi / 180)
    return(area)
  } else {
    # Weighted area
    idx <- which(z > threshold)
    if (length(idx) == 0) return(0)
    return(sum(w[idx], na.rm = TRUE))
  }
}

#' Calculate Gini Coefficient
#'
#' Calculate Gini coefficient as a measure of spatial aggregation.
#'
#' @param z Numeric vector. Catch per unit area or density values
#' @param w Numeric vector. Optional area weights
#' @return Numeric. Gini coefficient (0-1)
#' @export
gini <- function(z, w = NULL) {
  if (is.null(w)) w <- rep(1, length(z))
  
  # Remove zeros and NAs
  idx <- which(z > 0 & !is.na(z) & !is.na(w))
  if (length(idx) < 2) return(0)
  
  z_clean <- z[idx]
  w_clean <- w[idx]
  
  # Sort by density
  ord <- order(z_clean)
  z_clean <- z_clean[ord]
  w_clean <- w_clean[ord]
  
  # Calculate cumulative proportions
  cum_z <- cumsum(z_clean * w_clean)
  cum_w <- cumsum(w_clean)
  
  total_z <- sum(z_clean * w_clean, na.rm = TRUE)
  total_w <- sum(w_clean, na.rm = TRUE)
  
  if (total_z == 0 || total_w == 0) return(0)
  
  # Gini coefficient calculation
  n <- length(z_clean)
  gini_val <- 0
  for (i in 1:(n-1)) {
    gini_val <- gini_val + (cum_z[i] / total_z) * (w_clean[i+1] / total_w) - 
                (cum_w[i] / total_w) * (z_clean[i+1] * w_clean[i+1] / total_z)
  }
  
  return(abs(gini_val) * 2)
}

#' Calculate Positive Area
#'
#' Calculate the area with positive catches.
#'
#' @param x Numeric vector. Longitude coordinates
#' @param y Numeric vector. Latitude coordinates
#' @param z Numeric vector. Catch per unit area or density values
#' @param w Numeric vector. Optional area weights
#' @return Numeric. Positive area value
#' @export
positivearea <- function(x, y, z, w = NULL) {
  idx <- which(z > 0 & !is.na(z))
  if (length(idx) == 0) return(0)
  
  if (is.null(w)) {
    # Calculate area based on positive catches
    if (length(idx) < 3) return(0)
    x_range <- diff(range(x[idx], na.rm = TRUE))
    y_range <- diff(range(y[idx], na.rm = TRUE))
    area <- x_range * y_range * 111 * 111 * cos(mean(y[idx], na.rm = TRUE) * pi / 180)
    return(area)
  } else {
    return(sum(w[idx], na.rm = TRUE))
  }
}

#' Calculate Proportion of Presence
#'
#' Calculate the proportion of stations with positive catches.
#'
#' @param z Numeric vector. Catch per unit area or density values
#' @param w Numeric vector. Optional area weights
#' @return Numeric. Proportion of presence (0-1)
#' @export
proppres <- function(z, w = NULL) {
  if (is.null(w)) w <- rep(1, length(z))
  
  idx <- which(z > 0 & !is.na(z) & !is.na(w))
  if (length(idx) == 0) return(0)
  
  total_weight <- sum(w[!is.na(z) & !is.na(w)], na.rm = TRUE)
  if (total_weight == 0) return(0)
  
  positive_weight <- sum(w[idx], na.rm = TRUE)
  return(positive_weight / total_weight)
}

#' Calculate Equivalent Area
#'
#' Calculate the equivalent area based on density distribution.
#'
#' @param z Numeric vector. Catch per unit area or density values
#' @param w Numeric vector. Optional area weights
#' @return Numeric. Equivalent area value
#' @export
equivalentarea <- function(z, w = NULL) {
  if (is.null(w)) w <- rep(1, length(z))
  
  idx <- which(!is.na(z) & !is.na(w) & z >= 0)
  if (length(idx) == 0) return(0)
  
  z_clean <- z[idx]
  w_clean <- w[idx]
  
  total_density <- sum(z_clean * w_clean, na.rm = TRUE)
  mean_density <- mean(z_clean[z_clean > 0], na.rm = TRUE)
  
  if (mean_density == 0 || is.na(mean_density)) return(0)
  
  equivalent_area <- total_density / mean_density
  return(equivalent_area)
}

#' Calculate Density Level
#'
#' Calculate density level at a given percentile.
#'
#' @param z Numeric vector. Catch per unit area or density values
#' @param w Numeric vector. Optional area weights
#' @param level Numeric. Percentile level (default: 0.5 for median)
#' @return Numeric. Density level value
#' @export
densitylevel <- function(z, w = NULL, level = 0.5) {
  if (is.null(w)) w <- rep(1, length(z))
  
  idx <- which(!is.na(z) & !is.na(w) & z >= 0)
  if (length(idx) == 0) return(0)
  
  z_clean <- z[idx]
  w_clean <- w[idx]
  
  # Weighted quantile
  ord <- order(z_clean)
  z_clean <- z_clean[ord]
  w_clean <- w_clean[ord]
  
  cum_w <- cumsum(w_clean)
  total_w <- sum(w_clean, na.rm = TRUE)
  
  target_w <- level * total_w
  idx_level <- which(cum_w >= target_w)[1]
  
  if (is.na(idx_level)) return(max(z_clean, na.rm = TRUE))
  return(z_clean[idx_level])
}

#' Calculate Spatial Index (SPI)
#'
#' Calculate the Spatial Index as a measure of spatial distribution.
#'
#' @param x Numeric vector. Longitude coordinates
#' @param y Numeric vector. Latitude coordinates
#' @param z Numeric vector. Catch per unit area or density values
#' @param w Numeric vector. Optional area weights
#' @return Numeric. Spatial index value
#' @export
spi <- function(x, y, z, w = NULL) {
  if (is.null(w)) w <- rep(1, length(z))
  
  idx <- which(z > 0 & !is.na(z) & !is.na(x) & !is.na(y) & !is.na(w))
  if (length(idx) < 2) return(0)
  
  x_clean <- x[idx]
  y_clean <- y[idx]
  z_clean <- z[idx]
  w_clean <- w[idx]
  
  # Calculate weighted centroid
  total_weight <- sum(z_clean * w_clean, na.rm = TRUE)
  if (total_weight == 0) return(0)
  
  x_centroid <- sum(x_clean * z_clean * w_clean, na.rm = TRUE) / total_weight
  y_centroid <- sum(y_clean * z_clean * w_clean, na.rm = TRUE) / total_weight
  
  # Calculate mean distance from centroid
  distances <- sqrt((x_clean - x_centroid)^2 + (y_clean - y_centroid)^2)
  mean_distance <- sum(distances * z_clean * w_clean, na.rm = TRUE) / total_weight
  
  return(mean_distance)
}

#' Calculate Extent of Occurrence
#'
#' Calculate the extent of occurrence based on the area of the convex hull or bounding box.
#'
#' @param x Numeric vector. Longitude coordinates
#' @param y Numeric vector. Latitude coordinates
#' @param z Numeric vector. Catch per unit area or density values (optional, for filtering)
#' @param threshold Numeric. Minimum density threshold (default: 0)
#' @return Numeric. Extent of occurrence area
#' @export
extentofoccurrence <- function(x, y, z = NULL, threshold = 0) {
  if (is.null(z)) {
    idx <- which(!is.na(x) & !is.na(y))
  } else {
    idx <- which(z > threshold & !is.na(x) & !is.na(y) & !is.na(z))
  }
  
  if (length(idx) < 3) return(0)
  
  x_clean <- x[idx]
  y_clean <- y[idx]
  
  # Calculate bounding box area
  x_range <- diff(range(x_clean, na.rm = TRUE))
  y_range <- diff(range(y_clean, na.rm = TRUE))
  
  # Approximate area (degrees to km^2, rough conversion)
  mean_lat <- mean(y_clean, na.rm = TRUE)
  area <- x_range * y_range * 111 * 111 * cos(mean_lat * pi / 180)
  
  return(area)
}

#' Calculate Cumulative Density Curve
#'
#' Calculate cumulative density curve data.
#'
#' @param z Numeric vector. Catch per unit area or density values
#' @param w Numeric vector. Optional area weights
#' @return Data frame with cumulative density curve data
#' @export
cumdenscurve <- function(z, w = NULL) {
  if (is.null(w)) w <- rep(1, length(z))
  
  idx <- which(!is.na(z) & !is.na(w) & z >= 0)
  if (length(idx) == 0) {
    return(data.frame(density = numeric(0), cumulative_area = numeric(0)))
  }
  
  z_clean <- z[idx]
  w_clean <- w[idx]
  
  # Sort by density
  ord <- order(z_clean)
  z_clean <- z_clean[ord]
  w_clean <- w_clean[ord]
  
  # Calculate cumulative area
  cum_area <- cumsum(w_clean)
  total_area <- sum(w_clean, na.rm = TRUE)
  
  return(data.frame(
    density = z_clean,
    cumulative_area = cum_area,
    cumulative_proportion = cum_area / total_area
  ))
}

#' Calculate Cumulative Density Data
#'
#' Calculate cumulative density data for plotting.
#'
#' @param z Numeric vector. Catch per unit area or density values
#' @param w Numeric vector. Optional area weights
#' @param n_bins Numeric. Number of bins for density levels (default: 100)
#' @return Data frame with cumulative density data
#' @export
cumdensdata <- function(z, w = NULL, n_bins = 100) {
  if (is.null(w)) w <- rep(1, length(z))
  
  idx <- which(!is.na(z) & !is.na(w) & z >= 0)
  if (length(idx) == 0) {
    return(data.frame(density_level = numeric(0), cumulative_area = numeric(0)))
  }
  
  z_clean <- z[idx]
  w_clean <- w[idx]
  
  # Create density bins
  z_max <- max(z_clean, na.rm = TRUE)
  if (z_max == 0) {
    return(data.frame(density_level = 0, cumulative_area = sum(w_clean, na.rm = TRUE)))
  }
  
  density_levels <- seq(0, z_max, length.out = n_bins)
  cumulative_areas <- numeric(n_bins)
  
  for (i in 1:n_bins) {
    idx_level <- which(z_clean >= density_levels[i])
    cumulative_areas[i] <- sum(w_clean[idx_level], na.rm = TRUE)
  }
  
  return(data.frame(
    density_level = density_levels,
    cumulative_area = cumulative_areas
  ))
}

#' Calculate Spatial Indicators from Survey Data
#'
#' Calculate multiple spatial indicators from DATRAS survey data.
#'
#' @param datras_data Data frame. DATRAS survey data with spatial coordinates
#' @param indicators Character vector. Indicators to calculate:
#'   "spreadingarea", "gini", "positivearea", "proppres", "equivalentarea",
#'   "densitylevel", "spi", "extentofoccurrence"
#' @param z Character. Column name for catches per unit area
#' @param w Character. Column name for area weights (optional)
#' @param x Character. Column name for longitude
#' @param y Character. Column name for latitude
#' @param ... Additional arguments passed to indicator functions
#'
#' @return List of spatial indicator values
#'
#' @export
#'
#' @examples
#' \dontrun{
#' data <- get_datras_table("HH", "NS-IBTS", "2020", "1")
#' spatial_indicators <- calc_spatial_indicators(
#'   data,
#'   indicators = c("gini", "spreadingarea", "extentofoccurrence"),
#'   z = "cpue",
#'   x = "lon",
#'   y = "lat"
#' )
#' }
calc_spatial_indicators <- function(datras_data, indicators = NULL,
                                    z = "cpue", w = NULL, x = "lon", y = "lat", ...) {
  
  # Extract columns
  x_vec <- datras_data[[x]]
  y_vec <- datras_data[[y]]
  z_vec <- datras_data[[z]]
  w_vec <- if (!is.null(w)) datras_data[[w]] else NULL
  
  # Default indicators if not specified
  if (is.null(indicators)) {
    indicators <- c("spreadingarea", "gini", "positivearea", "proppres", 
                    "equivalentarea", "densitylevel", "spi", "extentofoccurrence")
  }
  
  results <- list()
  
  for (ind in indicators) {
    tryCatch({
      switch(ind,
        "spreadingarea" = {
          results$spreadingarea <- spreadingarea(x_vec, y_vec, z_vec, w_vec, ...)
        },
        "gini" = {
          results$gini <- gini(z_vec, w_vec)
        },
        "positivearea" = {
          results$positivearea <- positivearea(x_vec, y_vec, z_vec, w_vec)
        },
        "proppres" = {
          results$proppres <- proppres(z_vec, w_vec)
        },
        "equivalentarea" = {
          results$equivalentarea <- equivalentarea(z_vec, w_vec)
        },
        "densitylevel" = {
          results$densitylevel <- densitylevel(z_vec, w_vec, ...)
        },
        "spi" = {
          results$spi <- spi(x_vec, y_vec, z_vec, w_vec)
        },
        "extentofoccurrence" = {
          results$extentofoccurrence <- extentofoccurrence(x_vec, y_vec, z_vec, ...)
        },
        {
          warning(paste("Unknown indicator:", ind))
        }
      )
    }, error = function(e) {
      warning(paste("Error calculating", ind, ":", e$message))
    })
  }
  
  return(results)
}
