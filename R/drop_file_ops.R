
#'Copies a file or folder to a new location.
#'
#' @template from_to
#' @template root
#' @template verbose
#' @template token
#' @export
#' @importFrom assertthat assert_that
#' @examples \dontrun{
#' write.csv(mtcars, file = "mt.csv")
#' drop_upload("mt.csv")
#' drop_create("drop_test2")
#' drop_copy("mt.csv", "drop_test2/mt2.csv")
#' }
drop_copy <- function(from_path = NULL, to_path = NULL, root = "auto", verbose = FALSE, dtoken = get_dropbox_token())  {
  move_url <- "https://api.dropbox.com/1/fileops/copy"
     args <- as.list(drop_compact(c(root = root,
                                    from_path = from_path,
                                    to_path = to_path)))
  # TODO
  # here if to_path is just a path, append filename at the end
  x <-POST(move_url, config(token = dtoken), query = args, encode = "form")
  res <- content(x)
  if(!verbose) {
  message(sprintf("File copied to %s", res$path))
} else {
  pretty_lists(res)
  invisible(res)
}
}

#'Moves a file or folder to a new location.
#'
#' @template from_to
#' @template root
#' @template verbose
#' @template token
#' @export
#' @importFrom assertthat assert_that
#' @examples \dontrun{
#' write.csv(mtcars, file = "mt.csv")
#' drop_upload("mt.csv")
#' drop_create("drop_test2")
#' drop_move("mt.csv", "drop_test2/mt.csv")
#' }
drop_move <- function(from_path = NULL, to_path = NULL, root = "auto", verbose = FALSE, dtoken = get_dropbox_token())  {
  move_url <- "https://api.dropbox.com/1/fileops/move"
     args <- as.list(drop_compact(c(root = root,
                                    from_path = from_path,
                                    to_path = to_path)))
  # TODO
  # here if to_path is just a path, append filename at the end
  x <-POST(move_url, config(token = dtoken), query = args, encode = "form")
  res <- content(x)
  if(!verbose) {
  message(sprintf("Filed moved to %s", res$path))
  } else {
  pretty_lists(res)
  invisible(res)
}
}


#'Deletes a file or folder.
#'
#' @template path
#' @template root
#' @template verbose
#' @template token
#' @export
drop_delete <- function (path = NULL, root = "auto", verbose = FALSE, dtoken = get_dropbox_token()) {
    create_url <- "https://api.dropbox.com/1/fileops/delete"
    # Check to see if a file/folder exists before attempting to delete

    file_name <- paste0("/", basename(path)) # add a leading slash
    dir_name <- dirname(path)
    dir_listing <- drop_dir(path = dir_name)

    if(file_name %in% dir_listing$path) { # file was found
        # do delete
      x <-POST(create_url, config(token = dtoken), body = list(root = root, path = path), encode = "form")
      if(verbose) {
        content(x) } else {
          if(content(x)$is_deleted) message(sprintf('%s was successfully deleted', path))
        }
      invisible(content(x))
    } else { # Since file/folder wasn't found, report a stop error
      stop("File not found on current path")
    }
}


#'Creates a folder on Dropbox
#'
#'Returns a list containing the following fields: "size", "rev", "thumb_exists",
#'"bytes", "modified", "path", "is_dir", "icon", "root", "revision"
#'@template path
#'@template root
#'@template verbose
#'@template token
#'@export
#' @examples \dontrun{
#' drop_create(path = "foobar")
#'}
drop_create <- function (path = NULL, root = "auto", verbose = FALSE, dtoken = get_dropbox_token()) {
    create_url <- "https://api.dropbox.com/1/fileops/create_folder"
    x <-POST(create_url, config(token = dtoken), body = list(root = root, path = path), encode = "form")
    results <- content(x)

  if(verbose) {
    pretty_lists(results)
  } else {
    if(results$is_dir) message(sprintf("Folder %s created successfully \n", path))
  }
  invisible(results)
}
