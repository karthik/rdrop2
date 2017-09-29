#' List folder contents and associated metadata.
#'
#' Can be used to either see all items in a folder, or only items that have changed since a previous request was made.
#'
#' @param path path to folder in Dropbox to list contents of. Defaults to the root directory.
#' @param recursive If TRUE, the list folder operation will be applied recursively to all subfolders and the response will contain contents of all subfolders. Defaults to FALSE.
#' @param include_media_info If TRUE, FileMetadata.media_info is set for photo and video. Defaults to FALSE.
#' @param include_deleted If TRUE, the results will include entries for files and folders that used to exist but were deleted. Defaults to FALSE.
#' @param include_has_explicit_shared_members If TRUE, the results will include a flag for each file indicating whether or not that file has any explicit members. Defaults to FALSE.
#' @param include_mounted_folders If TRUE, the results will include entries under mounted folders which includes app folder, shared folder and team folder. Defaults to TRUE.
#' @param limit The maximum number of results to return per request. Note: This is an approximate number and there can be slightly more entries returned in some cases. Defaults to NULL, no limit.
#' @param cursor string or boolean: \itemize{
#'   \item{If FALSE, return metadata of items in \code{path}}
#'   \item{If TRUE, return a cursor to be used for detecting changed later}
#'   \item{If a string, return metadata of changed items since the cursor was fetched}
#' }
#' @template token
#'
#' @return Either a \code{tbl_df} of items in folder, one row per file or folder, with metadata values as columns, or a character string giving a cursor to be used later for change detection (see \code{cursor}).
#'
#' @examples \dontrun{
#'
#'   # list files in root directory
#'   drop_dir()
#'
#'   # get a cursor from root directory,
#'   # upload a new file,
#'   # return only information about new file
#'   cursor <- drop_dir(cursor = TRUE)
#'   drop_upload("some_new_file")
#'   drop_dir(cursor = cursor)
#' }
#'
#' @export
drop_dir <- function(
  path = "",
  recursive = FALSE,
  include_media_info = FALSE,
  include_deleted = FALSE,
  include_has_explicit_shared_members = FALSE,
  include_mounted_folders = TRUE,
  limit = NULL,
  cursor = FALSE,
  dtoken = get_dropbox_token()
) {

  # check args
  assertive::assert_is_a_string(path)
  if (!is.null(limit)) assertive::assert_is_numeric(limit)
  assertive::assert_is_any_of(cursor, c("logical", "character"))

  # this API doesn't accept "/", so don't add slashes to empty path, remove if given
  if (path != "") path <- add_slashes(path)
  if (path == "/") path <- ""

  # force limit to integer
  if (!is.null(limit)) limit <- as.integer(limit)

  # behavior depends on cursor
  if (is.character(cursor)) {

    # list changes since cursor
    content <- drop_list_folder_continue(cursor, dtoken)

  } else if (cursor) {

    # get a cursor to track changes against
    content <- drop_list_folder_get_latest_cursor(
      path,
      recursive,
      include_media_info,
      include_deleted,
      include_has_explicit_shared_members,
      include_mounted_folders,
      limit,
      dtoken
    )
    return(content$cursor)

  } else {

    # list files normally
    content <- drop_list_folder(
      path,
      recursive,
      include_media_info,
      include_deleted,
      include_has_explicit_shared_members,
      include_mounted_folders,
      limit,
      dtoken
    )

  }

  # extract list of content metadata
  results <- content$entries

  # if no limit was given, make additional requests until all content retrieved
  if (is.null(limit)) {
    while (content$has_more) {

      # update content, append results
      content <- drop_list_folder_continue(content$cursor)
      results  <- append(results, content$entries)
    }
  }

  # coerce to tibble, one row per item found
  dplyr::bind_rows(purrr::map(results, LinearizeNestedList))
}


#' List contents of a Dropbox folder.
#'
#' For internal use; drop_dir should generally be used to list files in a folder.
#'
#' @return a list with three elements: \code{entries}, \code{cursor}, and \code{has_more}.
#'
#' @references \href{https://www.dropbox.com/developers/documentation/http/documentation#files-list_folder}{API reference}
#'
#' @noRd
#'
#' @keywords internal
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

  url <- "https://api.dropboxapi.com/2/files/list_folder"

  req <- httr::POST(
    url = url,
    httr::config(token = dtoken),
    body = drop_compact(list(
      path = path,
      recursive = recursive,
      include_media_info = include_media_info,
      include_deleted = include_deleted,
      include_has_explicit_shared_members = include_has_explicit_shared_members,
      include_mounted_folders = include_mounted_folders,
      limit = limit
    )),
    encode = "json"
  )

  httr::stop_for_status(req)

  httr::content(req)
}


#' Fetch additional results from a cursor
#'
#' @return see \code{drop_list_folder}
#'
#' @references \href{https://www.dropbox.com/developers/documentation/http/documentation#files-list_folder-continue}{Dropbox API}
#'
#' @noRd
#'
#' @keywords internal
drop_list_folder_continue <- function(cursor, dtoken = get_dropbox_token()) {

  url <- "https://api.dropboxapi.com/2/files/list_folder/continue"

  req <- httr::POST(
    url = url,
    httr::config(token = dtoken),
    body = list(cursor = cursor),
    encode = "json"
  )

  httr::stop_for_status(req)

  httr::content(req)
}


#' Get the current cursor for a set of path + options
#'
#' @return a cursor, a string uniquely identifying a folder and how much of it has been listed
#'
#' @references \href{https://www.dropbox.com/developers/documentation/http/documentation#files-list_folder-get_latest_cursor}{Dropbox API}
#'
#' @noRd
#'
#' @keywords internal
drop_list_folder_get_latest_cursor <- function(
  path,
  recursive = FALSE,
  include_media_info = FALSE,
  include_deleted = FALSE,
  include_has_explicit_shared_members = FALSE,
  include_mounted_folders = TRUE,
  limit = NULL,
  dtoken = get_dropbox_token()
) {

  url <- "https://api.dropboxapi.com/2/files/list_folder/get_latest_cursor"

  req <- httr::POST(
    url = url,
    httr::config(token = dtoken),
    body = drop_compact(list(
      path = path,
      recursive = recursive,
      include_media_info = include_media_info,
      include_deleted = include_deleted,
      include_has_explicit_shared_members = include_has_explicit_shared_members,
      include_mounted_folders = include_mounted_folders,
      limit = limit
    )),
    encode = "json"
  )

  httr::stop_for_status(req)

  httr::content(req)
}
