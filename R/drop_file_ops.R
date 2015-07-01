
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
  if(drop_exists(from_path)) {
    # copy
    x <-POST(move_url, config(token = dtoken), query = args, encode = "form")
    res <- content(x)
    if(!verbose) {
      message(sprintf("%s copied to %s", basename(res$path), dirname(res$path)))
    } else {
      pretty_lists(res)
      invisible(res)
    }
  } else {
    stop("File or folder not found \n")
    FALSE
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
  if(drop_exists(from_path)) {
    x <-POST(move_url, config(token = dtoken), query = args, encode = "form")
    res <- content(x)
    if(!verbose) {
      message(sprintf("%s moved to %s", from_path, res$path)) 
    } else {
      pretty_lists(res)
      invisible(res)
    }
  } else {
    stop("File or folder not found \n")
    FALSE
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
   if(drop_exists(path)) { # file was found
        # do delete
      x <-POST(create_url, config(token = dtoken), body = list(root = root, path = path), encode = "form")
      if(verbose) {
        content(x) } else {
          if(content(x)$is_deleted) message(sprintf('%s was successfully deleted', path))
          invisible(content(x))
        }
    } else {
      # Since file/folder wasn't found, report a stop error
      stop("File not found on current path")
      FALSE
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
       if(!drop_exists(path)) {
    create_url <- "https://api.dropbox.com/1/fileops/create_folder"
    x <-POST(create_url, config(token = dtoken), body = list(root = root, path = path), encode = "form")
    results <- content(x)

  if(verbose) {
    pretty_lists(results)
  } else {
    if(results$is_dir) message(sprintf("Folder %s created successfully \n", path))
  }
  invisible(results)
  } else {
    stop("Folder already exists")
  }
}






#'Checks to see if a file/folder exists on Dropbox
#'
#'Since many file operations such as move, copy, delete and history can only act
#'on files that currently exist on a Dropbox store, checking to see if the
#'\code{path} is valid before operating prevents bad API calls from being sent
#'to the server. This functions returns a logical response after checking if a
#'file path is valid on Dropbox.
#'@param path The full path to a Dropbox file
#' @template token
#' @export
#' @examples \dontrun{
#' drop_create("existential_test")
#' drop_exists("existential_test")
#' drop_delete("existential_test")
#'}
drop_exists <- function(path = NULL, dtoken = get_dropbox_token()) {
  assert_that(!is.null(path))
  if(!grepl('^/', path)) path <- paste0("/", path)
  dir_name <- suppressMessages(dirname(path))
  dir_listing <- drop_dir_internal(path = dir_name, dtoken = dtoken)

    if(path %in% dir_listing$path) {
      TRUE
    } else {
      FALSE
    }

}

