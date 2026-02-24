#' Download DATRAS Table from ICES
#'
#' Downloads and reads DATRAS survey data from ICES database.
#'
#' @param recordtype Character. Record type (e.g., "HH", "HL", "CA")
#' @param survey Character. Survey name (e.g., "NS-IBTS")
#' @param year Character or numeric. Year
#' @param quarter Character or numeric. Quarter
#'
#' @return Data frame containing the DATRAS table
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Download haul data for North Sea IBTS Q1 1988
#' dfDatras = get_datras_table(
#'   recordtype = "HH",
#'   survey = "NS-IBTS",
#'   year = "1988",
#'   quarter = "1"
#' )
#' }
get_datras_table <- function(recordtype, survey, year, quarter) {
  
  baseUrl = "Https://datras.ices.dk/Data_products/Download/GetDATRAS.aspx"
  fullUrl = paste0(
    baseUrl,
    "?recordtype=", recordtype,
    "&survey=", survey,
    "&year=", year,
    "&quarter=", quarter
  )
  
  tempZip = tempfile(fileext = ".zip")
  tempDir = tempdir()
  
  message("Downloading from: ", fullUrl)
  download.file(fullUrl, destfile = tempZip, mode = "wb", quiet = TRUE)
  
  # ---- Unzip ----
  message("Unzipping...")
  unzip(tempZip, exdir = tempDir)
  
  # Find CSV file
  csvFile = list.files(tempDir, pattern = "Table\\.csv$", full.names = TRUE)
  
  if (length(csvFile) == 0) {
    stop("No table.csv found inside the ZIP file.")
  }
  
  # ---- Read CSV ----
  message("Reading table.csv into dataframe...")
  df = read.csv(csvFile[1], stringsAsFactors = FALSE)
  
  # ---- Clean up ----
  unlink(tempZip)
  
  message("Done! Returning dataframe.")
  return(df)
}
