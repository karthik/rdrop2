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

  content <- drop_list_revisions(
    path = add_slashes(path),
    limit = limit,
    dtoken = dtoken
  )

  dplyr::bind_rows(content$entries)
}


#' API wrapper for files/list_revisions
#'
#' Get revision history of a file. Does not include deletions.
#'
#' @param path path to a file in Dropbox.
#' @param mode "path" or "id" (unexposed)
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
drop_list_revisions <- function(
  path,
  mode = "path",
  limit = 10,
  dtoken
) {

  post_api(
    "https://api.dropboxapi.com/2/files/list_revisions",
    dtoken,
    path,
    mode,
    limit
  )
}
