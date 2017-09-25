#' List folder contents and associated metadata
#'
#' @param path path to folder in Dropbox to list contents of. Defaults to the root directory.
#' @param recursive If true, the list folder operation will be applied recursively to all subfolders and the response will contain contents of all subfolders. Defaults to FALSE.
#' @param include_media_info If true, FileMetadata.media_info is set for photo and video. Defaults to FALSE.
#' @param include_deleted If true, the results will include entries for files and folders that used to exist but were deleted. Defaults to FALSE.
#' @param include_has_explicit_shared_members If true, the results will include a flag for each file indicating whether or not that file has any explicit members. Defaults to FALSE.
#' @param include_mounted_folders If true, the results will include entries under mounted folders which includes app folder, shared folder and team folder. Defaults to TRUE.
#' @param limit The maximum number of results to return per request. Note: This is an approximate number and there can be slightly more entries returned in some cases. Defaults to NULL, no limit.
#' @template token
#'
#' @return \code{tbl_df} of items in folder, one row per file or folder, with metadata values as columns.
#'
#' @examples \dontrun{
#'   drop_dir()
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
  dtoken = get_dropbox_token()
) {

  # make initial request
  contents <- drop_list_folder(
    path,
    recursive,
    include_media_info,
    include_deleted,
    include_has_explicit_shared_members,
    include_mounted_folders,
    limit,
    dtoken
  )

  # extract list of content metadata
  results <- contents$entries

  # if no limit given, make additional requests until all content retrieved
  if (is.null(limit)) {
    while (contents$has_more) {

      # update content, append results
      contents <- drop_list_folder_continue(contents$cursor)
      results  <- append(results, contents$entries)
    }
  }

  # coerce to tibble, one row per item found
  dplyr::bind_rows(results)
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

  # this API doesn't accept "/", so don't add slashes to empty path, remove if given
  if (path != "") path <- add_slashes(path)
  if (path == "/") path <- ""

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
      limit = if (!is.null(limit)) as.integer(limit)
    )),
    encode = "json"
  )

  httr::stop_for_status(req)

  httr::content(req)
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
