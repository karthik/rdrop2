#' Obtains metadata for all available revisions of a file, including the current
#' revision.
#'
#' Does not include deleted revisions.
#'
#' @param path path to a file in dropbox.
#' @param limit maximum number of revisions to return; defaults to 10.
#' @template token
#'
#' @return \code{tbl_df} of metadata, one row per revision.
#'
#' @examples \dontrun{
#'   write.csv(iris, file = "iris.csv")
#'   drop_upload("iris.csv")
#'   write.csv(iris[iris$Species == "setosa", ], file = "iris.csv")
#'   drop_upload("iris.csv")
#'   drop_history("iris.csv")
#' }
#'
#' @export
drop_history <- function(path, limit = 10, dtoken = get_dropbox_token()) {

  content <- drop_list_revisions(path, limit, dtoken)

  dplyr::bind_rows(content$entries)
}


#' Get revision history of a file
#'
#' Does not include deletions.
#'
#' @param path path to a file in Dropbox.
#' @param limit maximum number of revisions to return; defaults to 10.
#' @template token
#' @references \href{https://www.dropbox.com/developers/documentation/http/documentation#files-list_revisions}{API documentation}
#'
#' @return list with elements \itemize{
#'   \item{\code{is_deleted}}{logical; has the file been deleted?}
#'   \item{\code{entries}}{list of metadata lists, one per revisions}
#'   \item{\code{server_deleted}}{}
#' }
#'
#' @noRd
#'
#' @keywords internal
drop_list_revisions <- function(path, limit = 10, dtoken = get_dropbox_token()) {

  url <- "https://api.dropboxapi.com/2/files/list_revisions"

  drop_request(url, dtoken, body = list(
    path  = add_slashes(path),
    limit = limit
  ))
}


#' Restore a file to a specific revision.
#'
#' Reverts a file on Dropbox to the content it had at a given revision. Use
#' \code{\link{drop_history}} to find available revision IDs.
#'
#' @param path Path to the file on Dropbox.
#' @param rev  The revision identifier string (e.g. \code{"a1c10ce0dd78"}) to
#'   restore to.  Revision IDs are returned in the \code{rev} column of
#'   \code{\link{drop_history}}.
#' @template token
#'
#' @return A list of file metadata reflecting the restored version.
#'
#' @references \href{https://www.dropbox.com/developers/documentation/http/documentation#files-restore}{API documentation}
#'
#' @export
#'
#' @examples \dontrun{
#'   history <- drop_history("report.csv")
#'   # restore to the second most recent version
#'   drop_restore("report.csv", rev = history$rev[2])
#' }
drop_restore <- function(path, rev, dtoken = get_dropbox_token()) {

  url <- "https://api.dropboxapi.com/2/files/restore"

  drop_request(url, dtoken, body = list(
    path = add_slashes(path),
    rev  = rev
  ))
}
