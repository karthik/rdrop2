


#'Returns metadata for all files and folders whose filename contains the given
#'search string as a substring.
#'
#'@param query  The search string. This string is split (on spaces) into
#'  individual words. Files and folders will be returned if they contain all
#'  words in the search string.
#'@template path
#'@param start The starting index within the search results (used for paging).
#'  The default for this field is 0
#'@param max_results The maximum number of search results to return. The default
#'  for this field is 100.
#'@param  mode Mode can take the option of filename, filename_and_content, or search deleted files with deleted_filename
#'@template token
#' @references \href{https://www.dropbox.com/developers/documentation/http/documentation#files-search}{API documentation}
#'@export
#' @examples \dontrun{
#' # If you know me, you know why this query exists
#' drop_search('gif') %>% select(path, is_dir, mime_type)
#'}
drop_search <- function(query,
                        path = "",
                        start = 0,
                        max_results = 100,
                        mode = "filename",
                        dtoken = get_dropbox_token()) {
  available_modes <-
    c("filename", "filename_and_content", "deleted_filename")
  assertive::assert_any_are_matching_fixed(available_modes, mode)
  # A search cannot have a negative start index and a negative max_results
  assertive::assert_all_are_non_negative(start, max_results)

  start <- as.integer(start)
  max_results <- as.integer(max_results)

  api_search(path, query, start, max_results, mode, dtoken)
  # TODO
  # Need to do a verbose return but also print a nice data.frame
  # One way to do that is with purrr::flatten
  # e.g. purrr::flatten(results$matches)
  # But, do we want purrr as another import???
}


#' API wrapper for files/search
#'
#' @noRd
#'
#' @keywords internal
api_search <- function(
  path,
  query,
  start = 0L,
  max_results = 100L,
  mode = "filename",
  dtoken
) {

  post_api(
    "https://api.dropboxapi.com/2/files/search",
    dtoken,
    path,
    query,
    start,
    max_results,
    mode
  )
}
