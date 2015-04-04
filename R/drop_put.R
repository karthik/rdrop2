

#'Uploads a file to Dropbox using PUT semantics.
#'
#' @param file Full local path to file.
#' @param  dest The relative path on Dropbox where the file should get uploaded.
#' @param  encode = "multipart" encoding format.
#' @export
#' @examples \dontrun{
#' drop_put()
#'}
drop_put <- function(file, dest = NULL, encode = "multipart") {
    dest <- ifelse(is.null(dest), basename(file), paste0(strip_slashes(dest),"/", basename(file)))
    put_url <- paste0("https://api-content.dropbox.com/1/files_put/auto/", dest)
    PUT(put_url, config(token = get_dropbox_token()), encode = encode, body = list(y = upload_file(file)))

}
