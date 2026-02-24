#' IMBUS: Implementing More and Better Use of ICES Survey Data
#'
#' @description
#' The IMBUS package consolidates and extends useful functions from FLRebuild, 
#' FLCore, FLSkill, and icesdata for IMBUS T4.4: Assessment of Survey-based Indices.
#'
#' @details
#' This package provides:
#' \itemize{
#'   \item DATRAS data access from ICES database
#'   \item F and effort proxy calculations via S4 methods
#'   \item ROC analysis tools
#'   \item Integration with FLR framework
#' }
#'
#' @section Key Functions:
#' \describe{
#'   \item{Data Access}{get_datras_table}
#'   \item{Validation}{roc}
#'   \item{F and Effort Proxies}{IMBUSData, imbusData, calcFeff, calcFproxies}
#' }
#'
#' @section Package Sources:
#' Functions are consolidated from:
#' \itemize{
#'   \item FLCore: Core data classes (FLStock, FLIndex, FLQuant), indicators.len
#'   \item FLRebuild: jabba functions
#'   \item FLSkill: ROC functions (via roc wrapper)
#'   \item icesdata: DATRAS data access
#' }
#'
#' @docType package
#' @name IMBUS-package
#' @aliases IMBUS
NULL
