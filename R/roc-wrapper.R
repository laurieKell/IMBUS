#' ROC (Receiver Operating Characteristic) Analysis
#'
#' Wrapper function for ROC analysis from FLSkill package.
#' This function provides a convenient interface to FLSkill's \code{roc2} function.
#'
#' @param ... Arguments passed to \code{FLSkill::roc2}
#'
#' @return Results from ROC analysis
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Use roc function (wraps FLSkill::roc2)
#' rocResult = roc(indicator, referenceStatus)
#' }
#'
#' @seealso \code{\link[FLSkill]{roc2}}
roc <- function(...) {
  FLSkill::roc2(...)
}
