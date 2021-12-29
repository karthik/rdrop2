#' drop_read
#'
#' @description wrapper for importing read.csv, read_excel readRDS and load from dropbox
#'
#' @param file path on dropbox
#' @param dest local path. tempdir for default
#' @param dtoken token
#' @param ... other arguments according to file format into \code{read.csv} or \code{readxl} or \code(readRDS) or \code(load)
#' @importFrom rdrop2 drop_download drop_upload
#' @importFrom readxl read_excel
#' @export
#' @examples \dontrun{
#'
#' save(airquality, file = "airquality.RData")
#' save(attenu, file = "attenu.RData")
#' save(austres, file = "austres.RData")
#' saveRDS(AirPassengers, "AirPassengers.rds")
#' write.csv(mtcars, file = "mtcars.csv")
#' openxlsx::write.xlsx(iris, file = "iris.xlsx")
#' purrr::walk(c("airquality.RData",
#'               "attenu.RData",
#'               "austres.RData",
#'               "AirPassengers.rds",
#'               "mtcars.csv",
#'               "iris.xlsx"),
#'
#'             ~ rdrop2::drop_upload(.x,
#'                           path = "/", # path in dropbox
#'                           mode = "overwrite"
#'             ))
#' drop_read(file = "AirPassengers.rds")
#' drop_read("iris.xlsx")
#' drop_read("mtcars.csv")
#' drop_read("airquality.RData")
#' drop_read("attenu.RDATA")
#' drop_read("austres.rdata")
#'
#' }



drop_read <- function (file,
                       dest = tempdir(),
                       dtoken = rdrop2:::get_dropbox_token(),
                       ...){
  localfile = paste0(dest, "/", basename(file))
  drop_download(file, localfile, overwrite = TRUE, dtoken = dtoken)

  ext <- strsplit(basename(file), split = "\\.")[[1]][-1]

  if(ext == "csv") {
    utils::read.csv(localfile, ...)

  }else if (ext == "xlsx" | ext == "xls"){

    readxl::read_excel(localfile, ...)

  } else if(ext == "rds" ){

    readRDS(localfile, ...)

  } else if (ext == "RData" | ext == "rdata" | ext == "RDATA" | ext == "rda") {

    load(localfile, envir = .GlobalEnv, ...)
  }

}
