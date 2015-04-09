

#' Downloads a file from Dropbox
#'
#' @template path
#' @param  local_file The name of the local copy. Leave this blank if you're fine with the original name.
#' @param overwrite Default is \code{FALSE} but can be set to \code{TRUE}.
#' @param rev The revision of the file to retrieve. This defaults to the most recent revision.
#' @template token
#' @export
#' @examples \dontrun{
#' drop_get(path = 'karthik_small.png', dest = "~/Desktop")
#' # To overwrite the existing file
#'  drop_get(path = 'karthik_small.png', overwrite = TRUE)
#'}
drop_get <- function(path = NULL, 
                     local_file = NULL, 
                     rev = NULL,
                     overwrite = FALSE, 
                     dtoken = get_dropbox_token()) {
    stopifnot(!is.null(path))

    filename <- ifelse(is.null(local_file), basename(path), local_file)
    get_url <- "https://api-content.dropbox.com/1/files/auto/"
    args <- as.list(drop_compact(c(rev = rev)))
    full_download_path <- paste0(get_url, path)
    GET(full_download_path, query = args, config(token = dtoken), write_disk(filename, overwrite = overwrite))
}


