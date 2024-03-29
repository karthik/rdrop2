




#'Uploads a file to Dropbox.
#'
#'This function will allow you to write files of any size to Dropbox(even ones
#'that cannot be read into memory) by uploading them in chunks.
#'
#'@param file Relative path to local file.
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
#' @references \href{https://www.dropbox.com/developers/documentation/http/documentation#files-upload}{API documentation}
#'@template verbose
#'@template token
#'@export
#' @examples \dontrun{
#' write.csv(mtcars, file = "mtt.csv")
#' drop_upload("mtt.csv")
#'}
drop_upload <- function(file,
                        path = NULL,
                        mode = "overwrite",
                        autorename = TRUE,
                        mute = FALSE,
                        verbose = FALSE,
                        dtoken = get_dropbox_token()) {
  put_url <- "https://content.dropboxapi.com/2/files/upload"

  # Check that object exists locally before adding slashes
  # assertive::assert_all_are_existing_files(file, severity = ("stop"))
  assertthat::assert_that(file.exists(file))

  # Check to see if only supported modes are specified
  standard_modes <- c("overwrite", "add", "update")
  # assertive::assert_any_are_matching_fixed(standard_modes, mode)
  assertthat::assert_that(mode %in% standard_modes)

  # Dropbox API requires a / before an object name.
  if (is.null(path)) {
    path <- add_slashes(basename(file))
  } else {
    path <- paste0("/", strip_slashes(path), "/", basename(file))
  }

  req <- httr::POST(
    url = put_url,
    httr::config(token = dtoken),
    httr::add_headers("Dropbox-API-Arg" = jsonlite::toJSON(
      list(
        path = path,
        mode = mode,
        autorename = autorename,
        mute = mute
      ),
      auto_unbox = TRUE
    )),
    body = httr::upload_file(file, type = "application/octet-stream")
    # application/octet-stream is to save to a file to disk and not worry about
    # what application/function might handle it. This lets another application
    # figure out how to read it. So for this purpose we're totally ok.
  )
  httr::stop_for_status(req)
  response <- httr::content(req)

  if (verbose) {
    pretty_lists(response)
    invisible(response)
  } else {
    invisible(response)
    message(
      sprintf(
        'File %s uploaded as %s successfully at %s',
        file,
        response$path_display,
        response$server_modified
      )
    )
  }

}
