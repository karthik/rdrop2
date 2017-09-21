



#'Uploads a file to Dropbox.
#'
#'This function will allow you to write files of any size to Dropbox(even ones
#'that cannot be read into memory) by uploading them in chunks.
#'
#'@param file Relative path to local file.
#'@param path The relative path on Dropbox where the file should get uploaded.
#'@param mode - "add" - will not overwrite an existing file in case of a
#'  conflict. With this mode, when a a duplicate file.txt is uploaded, it  will
#'  become file (2).txt. - "overwrite" will always overwrite a file - "update"
#'  Overwrite if the given "rev" matches the existing file's "rev".
#'@param autorename This logical determines what happens when there is a
#'  conflict. If true, the file being uploaded will be automatically renamed to
#'  avoid the conflict. (For example, test.txt might be automatically renamed to
#'  test (1).txt.) The new name can be obtained from the returned metadata. If
#'  false, the call will fail with a 409 (Conflict) response code. The default is `TRUE`
#'@param mute Set to FALSE to prevent a notification trigger on the desktop and
#'  mobile apps
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
                        verbose = FALSE,
                        mute = FALSE,
                        dtoken = get_dropbox_token()) {
  if (is.null(path)) {
    path <- paste0("/", basename(file))
  } else {
    path <- paste0("/", strip_slashes(path), "/", basename(file))
  }

  stopifnot(file.exists(file))
  put_url <- "https://content.dropboxapi.com/2/files/upload"
  req <- httr::POST(
    url = put_url,
    httr::config(token = get_dropbox_token()),
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

# TODO
# add and autorename do not work
# need to add tests for update, overwrite, autorename
# need to test a few different file types
# drop_upload("mtt.txt", path = "foo/foo.txt")
# File mtt.txt uploaded as /foo/foo.txt/mtt.txt successfully at 2017-09-20T00:40:08Z
# This is an issue because it doesn’t rename the files
