

#'Uploads a file to Dropbox using PUT semantics.
#'
#' @param file Full local path to file.
#' @param  dest The relative path on Dropbox where the file should get uploaded.
#' @param  encode File encoding
#' @param  verbose default is FALSE
#' @template token
#' @export
#' @examples \dontrun{
#' write.csv(mtcars, file = "mtcars.csv")
#' drop_upload("mtcars.csv")
#'}
drop_upload <- function(file, dest = NULL, encode = "multipart", verbose = FALSE, dtoken = get_dropbox_token()) {
    dest <- ifelse(is.null(dest), basename(file), paste0(strip_slashes(dest),"/", basename(file)))
    put_url <- paste0("https://api-content.dropbox.com/1/files_put/auto/", dest)
    content_type <- "text/csv; utf-8"
    response <- PUT(put_url, config(token = dtoken), encode = encode, body = list(data = upload_file(file, type = content_type)))
    if(verbose) {
        content(response)
    } else {
        message(sprintf('File %s uploaded successfully', file))
    }
}
