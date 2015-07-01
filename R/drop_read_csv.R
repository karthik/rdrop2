

#' drop_read_csv
#'
#' A lightweight wrapper around \code{read.csv} to read csv files from Dropbox into memory
#' @param file Name of file with full path relative to Dropbox root
#' @param  dest A temporary directory where a csv file is downloaded before being read into memory
#' @param  ... Additional arguments into \code{read.csv}
#' @template token
#' @export
#' @examples \dontrun{
#' write.csv(iris, file = "iris.csv")
#' drop_upload("iris.csv")
#' # Now let's read this back into an R session
#' new_iris <- drop_read_csv("iris.csv")
#'}
drop_read_csv <- function(file, dest = tempdir(), dtoken = get_dropbox_token(), ...) {
    localfile = paste0(dest, "/", basename(file))
    drop_get(file, local_file = localfile, overwrite = TRUE, dtoken = dtoken)
    read.csv(localfile, ...)
}
