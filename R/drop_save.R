#' drop_save
#'
#'@param object R object to save
#'@param path The relative path on Dropbox where the file should get uploaded.
#'@param mode - "add" - will not overwrite an existing file in case of a
#'  conflict. With this mode, when a a duplicate file.txt is uploaded, it  will
#'  become file (2).txt. - "overwrite" will always overwrite a file -
#'@param autorename This logical determines what happens when there is a
#'  conflict. If true, the file being uploaded will be automatically renamed to
#'  avoid the conflict. (For example, test.txt might be automatically renamed to
#'  test (1).txt.) The new name can be obtained from the returned metadata. If
#'  false, the call will fail with a 409 (Conflict) response code. The default is `TRUE`
#'@param mute Set to FALSE to prevent a notification trigger on the desktop and
#'  mobile apps
#'@template verbose
#'@template token
#'@references \href{https://www.dropbox.com/developers/documentation/http/documentation#files-upload}{API documentation}
#'@param ext file extension that will be saved. here we suggest csv, excel, rds, RData
#'@param ... other arguments for write.csv, write.xlsx, readRDS, save
#'@importFrom openxlsx write.xlsx
#'@importFrom utils write.csv
#'@author Lewis Hounkpevi
#'@export
#'
#' @examples \dontrun{
#' drop_save(BOD, ext = "rds")
#' drop_save(BOD, ext = "RData")
#' drop_save(BOD, ext = "xlsx")
#' drop_save(BOD, ext = "csv")
#'}
drop_save <- function (object,
                       path = NULL,
                       mode = "overwrite",
                       autorename = TRUE,
                       mute = FALSE,
                       verbose = FALSE,
                       dtoken = get_dropbox_token(),
                       ext = c("csv", "xlsx", "rds", "RData"),
                       ...){


  localpath <- paste0(tempdir(), "/", deparse(substitute(object)), ".", ext)



  if(ext == "csv") {

    write.csv(object, file = localpath, ...)

  }else if (ext == "xlsx" | ext == "xls"){

    openxlsx::write.xlsx(object, file = localpath, ...)

  } else if(ext == "rds" ){

    saveRDS(object, file = localpath, ...)

  } else if (ext == "RData" | ext == "rdata" | ext == "RDATA") {

    save(object, file = localpath, ...)
  }




  drop_upload(file = localpath,
              path = path,
              mode = mode,
              autorename = autorename,
              mute = mute,
              verbose = verbose,
              dtoken = dtoken)

}
