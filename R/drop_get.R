

#' Downloads a file from Dropbox
#'
#'<full description>
#' @param path The path to the file you want to retrieve.
#' @param  local_file The name of the local copy. Leave this blank if you're fine with the original name.
#' @param  dest The destination directory (lcoal)
#' @export
#' @examples \dontrun{
#' drop_get(path = 'karthik_small.png', dest = "~/Desktop")
#' # To overwrite the existing file
#'  drop_get(path = 'karthik_small.png', dest = "~/Desktop", overwrite = TRUE)
#'}
drop_get <- function(path = NULL, local_file = NULL, dest = getwd(), overwrite = FALSE) {
    stopifnot(!is.null(file))
    # TODO: Add a way to override local name
    # TODO strip trailing slashes. We'll need this function across the board.
    filename <- ifelse(is.null(local_file), path, local_file)
    local_file_name <- paste0(dest,"/", filename)
    get_url <- "https://api-content.dropbox.com/1/files/auto/"
    full_download_path <- paste0(get_url, path)
    GET(full_download_path, , config(token = get_dropbox_token()), write_disk(local_file_name, overwrite = overwrite))
}


