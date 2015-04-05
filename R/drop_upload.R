

#'Uploads a file to Dropbox using PUT semantics.
#'
#'@param file Full local path to file.
#'@param  dest The relative path on Dropbox where the file should get uploaded.
#'@param overwrite Default is \code{TRUE}
#'@param autorename This value, either true (default) or false, determines what
#'  happens when there is a conflict. If true, the file being uploaded will be
#'  automatically renamed to avoid the conflict. (For example, test.txt might be
#'  automatically renamed to test (1).txt.) The new name can be obtained from
#'  the returned metadata. If false, the call will fail with a 409 (Conflict)
#'  response code.
#'@template verbose
#'@template token
#'@export
#' @examples \dontrun{
#' write.csv(mtcars, file = "mtcars.csv")
#' drop_upload("mtcars.csv")
#'}
drop_upload <- function(file,
                        dest = NULL,
                        overwrite = TRUE,
                        autorename = FALSE,
                        verbose = FALSE,
                        dtoken = get_dropbox_token()) {
  if(is.null(dest)) {
    dest <- basename(file)
  } else {
    dest <- paste0(strip_slashes(dest),"/", basename(file))
  }
    put_url <- "https://api-content.dropbox.com/1/files_put/auto/"
    content_type <- drop_mime(file)
    content_length <- file.info(file)$size
    args <- as.list(drop_compact(c(`Content-Type` = content_type, 
                                    `Content-Length` = content_length, 
                                    overwrite = overwrite, 
                                    autorename = autorename, 
                                    path = dest)))
    response <- PUT(put_url, 
                    config(token = dtoken), 
                    query = args, 
                    body = list(data = upload_file(file)))
    if(verbose) {
        content(response)
    } else {
        message(sprintf('File %s uploaded successfully', file))
    }
    invisible(content(response))
}
