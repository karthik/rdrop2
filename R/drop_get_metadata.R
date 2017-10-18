#' Retrieve metadata for a file or folder.
#'
#' Details vary by input and args.
#'
#' @param path Path to a file or folder on Dropbox. Can also be an ID ("id:...") or revision ("rev:...").
#' @param include_media_info If TRUE, additional metadata for photo or video is returns. Defaults to FALSE.
#' @param include_deleted If TRUE, metadata will be returned for a deleted file, otherwise error. Defaults to FALSE.
#' @param include_has_explicit_shared_members If TRUE, the results will include a flag for each file indicating whether or not that file has any explicit members. Defaults to FALSE.
#' @template token
#'
#' @return possibly-nested list of all available metadata for specified file/folder/id/revision.
#'
#' @references \href{https://www.dropbox.com/developers/documentation/http/documentation#files-get_metadata}{API Documentation}
#'
#' @export
drop_get_metadata <- function(
  path,
  include_media_info = FALSE,
  include_deleted = FALSE,
  include_has_explicit_shared_members = FALSE,
  dtoken = get_dropbox_token()
) {

  if (!grepl("^(id|rev):", path)) path <- add_slashes(path)

  api_get_metadata(
    path,
    include_media_info,
    include_deleted,
    include_has_explicit_shared_members,
    dtoken
  )
}


#' API wrapper for files/get_metadata
#'
#' @noRd
#'
#' @keywords internal
api_get_metadata <- function(
  path,
  include_media_info = FALSE,
  include_deleted = FALSE,
  include_has_explicit_shared_members = FALSE,
  dtoken
) {

  post_api(
    "https://api.dropboxapi.com/2/files/get_metadata",
    dtoken,
    path,
    include_media_info,
    include_deleted,
    include_has_explicit_shared_members
  )
}
