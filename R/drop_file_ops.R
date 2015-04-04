
drop_copy <- function()  {

}

drop_move <- function()  {

}


#'Deletes a file or folder.
#'
#' @param  path This is required The path to the new folder to create relative to root.
#' @param root This is required. The root relative to which path is specified. Valid values are auto (recommended), sandbox, and dropbox.
#' @export
drop_delete <- function (path = NULL, root = "auto") {
    create_url <- "https://api.dropbox.com/1/fileops/delete"
    x <-POST(create_url, config(token = get_dropbox_token()), body = list(root = root, path = path), encode = "form")
  content(x)
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
#' @param  path This is required The path to the new folder to create relative to root.
#' @param root This is required. The root relative to which path is specified. Valid values are auto (recommended), sandbox, and dropbox.
#' @export
#' @examples \dontrun{
#' drop_create(path = "")
#'}
drop_create <- function (path = NULL, root = "auto") {
    create_url <- "https://api.dropbox.com/1/fileops/create_folder"
    x <-POST(create_url, config(token = get_dropbox_token()), body = list(root = root, path = path), encode = "form")
  content(x)
}
