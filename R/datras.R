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
#' df_datras <- get_datras_table(
#'   recordtype = "HH",
#'   survey = "NS-IBTS",
#'   year = "1988",
#'   quarter = "1"
#' )
#' }
get_datras_table <- function(recordtype, survey, year, quarter) {
  
  base_url <- "Https://datras.ices.dk/Data_products/Download/GetDATRAS.aspx"
  full_url <- paste0(
    base_url,
    "?recordtype=", recordtype,
    "&survey=", survey,
    "&year=", year,
    "&quarter=", quarter
  )
  
  temp_zip <- tempfile(fileext = ".zip")
  temp_dir <- tempdir()
  
  message("Downloading from: ", full_url)
  download.file(full_url, destfile = temp_zip, mode = "wb", quiet = TRUE)
  
  # ---- Unzip ----
  message("Unzipping...")
  unzip(temp_zip, exdir = temp_dir)
  
  # Find CSV file
  csv_file <- list.files(temp_dir, pattern = "Table\\.csv$", full.names = TRUE)
  
  if (length(csv_file) == 0) {
    stop("No table.csv found inside the ZIP file.")
  }
  
  # ---- Read CSV ----
  message("Reading table.csv into dataframe...")
  df <- read.csv(csv_file[1], stringsAsFactors = FALSE)
  
  # ---- Clean up ----
  unlink(temp_zip)
  
  message("Done! Returning dataframe.")
  return(df)
}
