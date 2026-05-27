

#' Search for files and folders on Dropbox.
#'
#' Returns metadata for all files and folders whose filename (or content, if
#' enabled) matches the given search string.  Uses the Dropbox
#' \code{files/search_v2} API endpoint which supports richer filtering options
#' than the original search endpoint.
#'
#' @param query The search string. Split on spaces into individual words;
#'   results are returned if they contain all words.
#' @param path  Dropbox path to restrict the search to. Defaults to the entire
#'   Dropbox (\code{""}).
#' @param max_results The maximum number of search results to return. Defaults
#'   to 100.
#' @param file_status  Filter by file status: \code{"active"} (default) returns
#'   only existing files; \code{"deleted"} returns only deleted files.
#' @param filename_only If \code{TRUE}, restricts the search to filenames only
#'   (faster). Defaults to \code{FALSE}.
#' @param file_extensions Optional character vector of file extensions to
#'   restrict results to (e.g., \code{c("pdf", "docx")}).
#' @param file_categories Optional character vector of file category tags to
#'   restrict results to. Valid values: \code{"image"}, \code{"document"},
#'   \code{"pdf"}, \code{"spreadsheet"}, \code{"presentation"}, \code{"audio"},
#'   \code{"video"}, \code{"folder"}, \code{"paper"}, \code{"others"}.
#' @template token
#'
#' @return A list as returned by the Dropbox API, with a \code{matches} element
#'   (list of match objects) and an optional \code{cursor} for pagination.
#'
#' @references \href{https://www.dropbox.com/developers/documentation/http/documentation#files-search_v2}{API documentation}
#'
#' @export
#'
#' @examples \dontrun{
#'   # simple filename search
#'   results <- drop_search("report")
#'   results$matches[[1]]$metadata$metadata$name
#'
#'   # search only PDF files
#'   drop_search("budget", file_extensions = "pdf")
#'
#'   # search images only
#'   drop_search("vacation", file_categories = "image")
#' }
drop_search <- function(query,
                        path = "",
                        max_results = 100,
                        file_status = "active",
                        filename_only = FALSE,
                        file_extensions = NULL,
                        file_categories = NULL,
                        dtoken = get_dropbox_token()) {

  valid_file_status <- c("active", "deleted")
  assertthat::assert_that(file_status %in% valid_file_status)
  assertthat::assert_that(max_results >= 0)

  # build options list, dropping NULLs
  options <- drop_compact(list(
    path              = if (nchar(path) > 0) add_slashes(path) else NULL,
    max_results       = as.integer(max_results),
    file_status       = list(".tag" = file_status),
    filename_only     = filename_only,
    file_extensions   = if (!is.null(file_extensions)) as.list(file_extensions) else NULL,
    file_categories   = if (!is.null(file_categories))
                          lapply(file_categories, function(x) list(".tag" = x))
                        else NULL
  ))

  search_url <- "https://api.dropboxapi.com/2/files/search_v2"
  drop_request(search_url, dtoken,
               body = list(query = query, options = options))
}


#' Continue a paginated search begun with \code{drop_search}.
#'
#' @param cursor A cursor string returned in a previous \code{drop_search} call.
#' @template token
#'
#' @return Same structure as \code{\link{drop_search}}.
#'
#' @references \href{https://www.dropbox.com/developers/documentation/http/documentation#files-search-continue_v2}{API documentation}
#'
#' @export
#'
#' @examples \dontrun{
#'   first_page  <- drop_search("report", max_results = 20)
#'   second_page <- drop_search_continue(first_page$cursor)
#' }
drop_search_continue <- function(cursor, dtoken = get_dropbox_token()) {

  url <- "https://api.dropboxapi.com/2/files/search/continue_v2"
  drop_request(url, dtoken, body = list(cursor = cursor))
}
