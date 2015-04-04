
drop_copy <- function()  {

}

#'Moves a file or folder to a new location.
#'
#' @param root This is required. The root relative to which path is specified. Valid values are auto (recommended), sandbox, and dropbox.
#' @param  from_path Source file or folder
#' @param  to_path destination file or folder
#' @template verbose
#' @template token
#' @export
#' @importFrom assertthat assert_that
drop_move <- function(root, from_path = NULL, to_path = NULL, verbose = FALSE, dtoken = get_dropbox_token())  {
  move_url <- "https://api.dropbox.com/1/fileops/move"
  x <-POST(move_url, config(token = dtoken), body = list(root = root, from_path = from_path, to_path = to_path), encode = "form")
}


#'Deletes a file or folder.
#'
#' @template path-root
#' @template verbose
#' @template token
#' @export
drop_delete <- function (path = NULL, root = "auto", verbose = FALSE, dtoken = get_dropbox_token()) {
    create_url <- "https://api.dropbox.com/1/fileops/delete"
    x <-POST(create_url, config(token = dtoken), body = list(root = root, path = path), encode = "form")
  if(verbose) {
    content(x) } else {
      if(content(x)$is_deleted) message(sprintf('Folder %s was successfully deleted', path))
    }
  invisible(content(x))
}


#' Creates a folder.
#'
#' Returns the following type of response
#' {
#'     "size": "0 bytes",
#'     "rev": "1f477dd351f",
#'     "thumb_exists": false,
#'     "bytes": 0,
#'     "modified": "Wed, 10 Aug 2011 18:21:30 +0000",
#'     "path": "/new_folder",
#'     "is_dir": true,
#'     "icon": "folder",
#'     "root": "dropbox",
#'     "revision": 5023410
#' }
#' @template path-root
#' @template verbose
#' @template token
#' @export
#' @examples \dontrun{
#' drop_create(path = "foobar")
#'}
drop_create <- function (path = NULL, root = "auto", verbose = FALSE, dtoken = get_dropbox_token()) {
    create_url <- "https://api.dropbox.com/1/fileops/create_folder"
    x <-POST(create_url, config(token = dtoken), body = list(root = root, path = path), encode = "form")
    results <- content(x)

  if(verbose) {
    data.frame(t(unlist(results)))
  } else {
    if(results$is_dir) message(sprintf("Folder %s created successfully \n", path))
  }
  invisible(results)
}
