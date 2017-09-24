#' List contents of a Dropbox folder.
#'
#' For internal use; drop_dir should generally be used to list files in a folder.
#'
#' @return a list with three elements: \code{entries}, \code{cursor}, and \code{has_more}.
#'
#' @references \href{https://www.dropbox.com/developers/documentation/http/documentation#files-list_folder}{API reference}
#'
#' @noRd
drop_list_folder <- function(
  path,
  recursive = FALSE,
  include_media_info = FALSE,
  include_deleted = FALSE,
  include_has_explicit_shared_members = FALSE,
  include_mounted_folders = TRUE,
  limit = NULL,
  dtoken = get_dropbox_token()
) {

  if (!is.null(limit)) assertive::assert_is_numeric(limit)

  url <- "https://api.dropboxapi.com/2/files/list_folder"

  req <- httr::POST(
    url = url,
    httr::config(token = dtoken),
    body = drop_compact(list(
      path = add_slashes(path),
      recursive = recursive,
      include_media_info = include_media_info,
      include_deleted = include_deleted,
      include_has_explicit_shared_members = include_has_explicit_shared_members,
      include_mounted_folders = include_mounted_folders,
      limit = if (!is.null(limit)) as.integer(limit)
    )),
    encode = "json"
  )

  httr::stop_for_status(req)

  httr::content(req)

  # # extract list of matches
  # results  <- content$entries
  #
  # # continue fetching & appending results if necessary
  # while (content$has_more) {
  #
  #   content <- drop_list_folder_continue(content$cursor, dtoken = dtoken)
  #
  #   results  <- append(results, content$entries)
  # }
  #
  # results
}


#' Helper function for fetching additional results
#'
#' @noRd
drop_list_folder_continue <- function(cursor, dtoken = get_dropbox_token()) {

  url <- "https://api.dropboxapi.com/2/files/list_folder/continue"

  req <- httr::POST(
    url = url,
    httr::config(token = dtoken),
    body = list(cursor = content$cursor),
    encode = "json"
  )

  httr::stop_for_status(req)

  httr::content(req)
}
