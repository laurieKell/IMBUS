#' IMBUS: Implementing More and Better Use of ICES Survey Data
#'
#' @description
#' The IMBUS package consolidates and extends useful functions from FLRebuild, 
#' FLCore, icesdata, and spatial indicator packages for IMBUS T4.4: Assessment 
#' of Survey-based Indices.
#'
#' @details
#' This package provides:
#' \itemize{
#'   \item Standardized workflows for survey index calculation
#'   \item Length-based indicator calculations
#'   \item Auxiliary data extraction and formatting
#'   \item Validation and diagnostic tools
#'   \item Integration with FLR framework
#' }
#'
#' @section Key Functions:
#' \describe{
#'   \item{Survey Indices}{calc_survey_index, standardise_survey_index}
#'   \item{Length-based Indicators}{calc_lbi, calc_length_indicators}
#'   \item{Auxiliary Data}{extract_auxiliary_data, format_for_assessment}
#'   \item{Validation}{validate_indicator, diagnostic_plots}
#'   \item{Workflows}{imbus_workflow}
#' }
#'
#' @section Package Sources:
#' Functions are consolidated from:
#' \itemize{
#'   \item FLRebuild: ROC functions, indicators.len, jabba functions
#'   \item FLCore: Core data classes and operations
#'   \item icesdata: DATRAS data access
#'   \item spatind: Spatial indicator functions (spreadingarea, gini, positivearea, 
#'     proppres, equivalentarea, densitylevel, spi, extentofoccurrence)
#' }
#'
#' @docType package
#' @name IMBUS-package
#' @aliases IMBUS
NULL
