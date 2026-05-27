#' Download a file from Dropbox to disk.
#'
#' @param path path to a file in Dropbox
#' @param local_path path to save file to. If NULL (the default), saves file to working directory with same name. If not null, but a valid folder, file will be saved in this folder with same basename as path. If not null and not a folder, file will be saved to this path exactly.
#' @param overwrite If TRUE, overwrite local file. Defaults to FALSE
#' @param progress If TRUE, show a progress bar for large file downloads. Defaults to TRUE in interactive sessions, otherwise FALSE.
#' @param verbose if TRUE, emit message giving location and size of the newly downloaded file. Defaults to TRUE in interactive sessions, otherwise FALSE.
#' @references \href{https://www.dropbox.com/developers/documentation/http/documentation#files-download}{API documentation}
#' @template token
#'
#' @importFrom cli cli_abort cli_alert_success
#'
#' @return TRUE if successful; error thrown otherwise.
#'
#' @examples \dontrun{
#'
#'   # download a file to the current working directory
#'   drop_download("dataset.zip")
#'
#'   # download again, overwriting previous result
#'   drop_download("dataset.zip", overwrite = TRUE)
#'
#'   # download to a different path, keeping file name constant
#'   # will download to "some/other/place/dataset.zip"
#'   drop_download("dataset.zip", local_path = "some/other/place/")
#'
#'   # download to a different path, changing filename
#'   drop_download("dataset.zip", local_path = "some/other/place/not_a_dataset.zip")
#' }
#'
#' @export
drop_download <- function(
  path,
  local_path = NULL,
  overwrite = FALSE,
  progress = interactive(),
  verbose = interactive(),
  dtoken = get_dropbox_token()
) {

  # if path isn't an id or revision, ensure it has leading slash
  if (!grepl("^(id|rev):", path)) path <- add_slashes(path)

  # if no local path given, download it to working directory
  # if path given is folder, append filename to it
  if (is.null(local_path)) {
    local_path <- basename(path)
  } else if (dir.exists(local_path)) {
    local_path <- file.path(local_path, basename(path))
  }

  if (file.exists(local_path) && !overwrite) {
    cli::cli_abort(
      "Local file {.file {local_path}} already exists. Set {.code overwrite = TRUE} to replace it."
    )
  }

  url <- "https://content.dropboxapi.com/2/files/download"

  arg_json <- jsonlite::toJSON(list(path = path), auto_unbox = TRUE)

  req <- httr2::request(url)
  req <- httr2::req_auth_bearer_token(req, resolve_token(dtoken))
  req <- httr2::req_headers(req, `Dropbox-API-Arg` = arg_json)
  req <- httr2::req_body_raw(req, "", type = "application/octet-stream")
  if (progress) req <- httr2::req_progress(req)

  httr2::req_perform(req, path = local_path)

  # print message in verbose mode
  if (verbose) {
    size <- file.size(local_path)
    class(size) <- "object_size"
    size_fmt <- format(size, units = "auto")
    cli::cli_alert_success(
      "Downloaded {.path {path}} to {.path {local_path}} ({.val {size_fmt}})"
    )
  }

  TRUE
}


#' Downloads a file from Dropbox
#'
#' @template path
#' @param  local_file The name of the local copy. Leave this blank if you're fine with the original name.
#' @param overwrite Default is \code{FALSE} but can be set to \code{TRUE}.
#' @param progress Progress bars are turned off by default. Set to \code{TRUE} to turn this on.
#' @template token
#' @template verbose
#' @importFrom cli cli_alert_danger cli_alert_success
#'
#' @examples \dontrun{
#'   drop_get(path = 'dataset.zip', local_file = "~/Desktop")
#'   # To overwrite the existing file
#'   drop_get(path = 'dataset.zip', overwrite = TRUE)
#' }
#'
#' @export
drop_get <- function(
  path = NULL,
  local_file = NULL,
  overwrite = FALSE,
  verbose = FALSE,
  progress = FALSE,
  dtoken = get_dropbox_token()
) {

  .Deprecated("drop_download")

  assertthat::assert_that(!is.null(path))

  if (drop_exists(path, dtoken = dtoken)) {
    filename <- ifelse(is.null(local_file), basename(path), local_file)
    drop_download(path, filename, overwrite, progress, verbose, dtoken)

    if (!verbose) {
      size <- file.size(filename)
      class(size) <- "object_size"
      cli::cli_alert_success(
        "{.path {filename}} downloaded ({format(size, units = 'auto')})"
      )
      TRUE
    } else {
      drop_get_metadata(path)
    }
  } else {
    cli::cli_alert_danger("File not found on Dropbox: {.path {path}}")
    FALSE
  }
}
