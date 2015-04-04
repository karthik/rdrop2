

#' Downloads a file from Dropbox
#'
#' @template path
#' @param  local_file The name of the local copy. Leave this blank if you're fine with the original name.
#' @param overwrite Default is \code{FALSE} but can be set to \code{TRUE}.
#' @template token
#' @export
#' @examples \dontrun{
#' drop_get(path = 'karthik_small.png', dest = "~/Desktop")
#' # To overwrite the existing file
#'  drop_get(path = 'karthik_small.png', overwrite = TRUE)
#'}
drop_get <- function(path = NULL, local_file = NULL, overwrite = FALSE, dtoken = get_dropbox_token()) {
    stopifnot(!is.null(path))

    filename <- ifelse(is.null(local_file), basename(path), local_file)
    get_url <- "https://api-content.dropbox.com/1/files/auto/"
    full_download_path <- paste0(get_url, path)
    GET(full_download_path, , config(token = dtoken), write_disk(filename, overwrite = overwrite))
}


