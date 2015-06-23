

#' Downloads a file from Dropbox
#'
#' @template path
#' @param  local_file The name of the local copy. Leave this blank if you're fine with the original name.
#' @param overwrite Default is \code{FALSE} but can be set to \code{TRUE}.
#' @param rev The revision of the file to retrieve. This defaults to the most recent revision.
#' @param progress Progress bars are turned off by default. Set to \code{TRUE} ot turn this on. Progress is only reported when file sizes are known. Otherwise just bytes downloaded.
#' @template token
#' @template verbose
#' @export
#' @examples \dontrun{
#' drop_get(path = 'dataset.zip', local_file = "~/Desktop")
#' # To overwrite the existing file
#'  drop_get(path = 'dataset.zip', overwrite = TRUE)
#'}
drop_get <- function(path = NULL,
                     local_file = NULL,
                     rev = "",
                     overwrite = FALSE,
                     verbose = FALSE,
                     progress = FALSE,
                     dtoken = get_dropbox_token()) {
    stopifnot(!is.null(path))
    if(drop_exists(path, dtoken = dtoken)) {
        filename <- ifelse(is.null(local_file), basename(path), local_file)
        get_url <- "https://api-content.dropbox.com/1/files/auto/"
        args <- as.list(drop_compact(c(rev = rev)))
        full_download_path <- paste0(get_url, path)
        if(progress) {
            x <- GET(full_download_path, query = args, config(token = dtoken), write_disk(filename, overwrite = overwrite), progress())
        } else {
            x <- GET(full_download_path, query = args, config(token = dtoken), write_disk(filename, overwrite = overwrite))
        }
        if(!verbose) {
            # prints file sizes in kb but this could also be pretty printed
            message(sprintf("\n %s on disk %s KB", filename, length(x$content)/1000, x$url))
            TRUE
        } else {        
            x
        }
   } else {
       message("File not found on Dropbox \n")
       FALSE
   } 
}


