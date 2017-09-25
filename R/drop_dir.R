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
  path = "/",
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
    add_slashes(path),
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


#' Old internal function used by drop_delete.
#'
#' TODO: update drop_delete to not need this, then delete it.
#'
#' noRd
#' @keywords internal
drop_dir_internal <- function(
  path = NULL,
  file_limit = 10000,
  hash = NULL,
  list = TRUE,
  include_deleted = FALSE,
  rev = NULL,
  locale = NULL,
  include_media_info = TRUE,
  include_membership = FALSE,
  verbose = FALSE,
  dtoken = get_dropbox_token()
) {

  is_dir <- NULL

  args <- as.list(drop_compact(c(file_limit = file_limit,
                                 hash = hash,
                                 list = list,
                                 include_deleted = include_deleted,
                                 rev = rev,
                                 locale = locale,
                                 include_media_info = include_media_info,
                                 include_membership = include_membership)))
  metadata_url <- "https://api.dropbox.com/1/metadata/auto/"

  if (!is.null(path)) {
    metadata_url <- paste0(metadata_url, path)
  }

  req <- httr::GET(metadata_url, query = args, config(token = dtoken))
  res <- jsonlite::fromJSON(httr::content(req, as = "text"), flatten = TRUE)

  if (length(res$contents) > 0) { # i.e. not an empty folder
    if (verbose) {
      res2 <- res
      res2$contents <- data.frame()
      res$contents <- dplyr::tbl_df(res$contents)
      pretty_lists(res2)
      print(dplyr::tbl_df(res$contents))
      invisible(res)
    } else {
      path <- mime_type <- root <- bytes <- modified <- NULL
      if ("mime_type" %in% names(res$contents)) {
        dplyr::tbl_df(res$contents) %>% dplyr::select(path, mime_type, root, bytes, modified) # prints 25 files
      } else {
        dplyr::tbl_df(res$contents) %>% dplyr::select(path, is_dir, root, bytes, modified)  # prints 25 files
      }
    }
  } else {
    data.frame()
  }
}
