

#' Copies a file or folder to a new location.
#'
#' @template from_to
#' @template verbose
#' @template token
#' @param allow_shared_folder  If \code{TRUE}, copy will copy contents in shared
#'   folder
#' @param autorename If there's a conflict, have the Dropbox server try to
#'   autorename the file to avoid the conflict.
#' @param allow_ownership_transfer Allow moves by owner even if it would result
#'   in an ownership transfer for the content being moved. This does not apply
#'   to copies. The default for this field is False.
#' @export
#' @references \href{https://www.dropbox.com/developers/documentation/http/documentation#files-copy_v2}{API documentation}
#' @examples \dontrun{
#' write.csv(mtcars, file = "mt.csv")
#' drop_upload("mt.csv")
#' drop_create("drop_test2")
#' drop_copy("mt.csv", "drop_test2/mt2.csv")
#' }
drop_copy <-
  function(from_path = NULL,
           to_path = NULL,
           allow_shared_folder = FALSE,
           autorename = FALSE,
           allow_ownership_transfer = FALSE,
           verbose = FALSE,
           dtoken = get_dropbox_token())  {
    copy_url <- "https://api.dropboxapi.com/2/files/copy_v2"

    from_path <- add_slashes(from_path)
    to_path <- add_slashes(to_path)

    # Copying a file into a folder
    file_to_folder <-
      c(drop_type(from_path) == "file",
        drop_type(to_path) == "folder")
    to_path <-
      ifelse(all(file_to_folder), paste0(to_path, from_path), to_path)

    # coping a folder to another folder
    folder_to_folder <-
      c(drop_type(from_path) == "folder",
        drop_type(to_path) == "folder")
    to_path <-
      ifelse(all(folder_to_folder), paste0(to_path, from_path), to_path)

    # Copying a file to a file
    # Nothing to do, since both paths reflect origin and destination

    # Copying a folder to an existing filename will result in a HTTP 409 (conflict error)

    args <- drop_compact(
      list(
        from_path = from_path,
        to_path = to_path,
        allow_shared_folder = allow_shared_folder,
        autorename = autorename,
        allow_ownership_transfer = allow_ownership_transfer
      )
    )

    if (drop_exists(from_path)) {
      # copy
      x <-
        httr::POST(copy_url,
                   httr::config(token = dtoken),
                   body = args,
                   encode = "json")
      res <- httr::content(x)
      if (!verbose) {
        message(sprintf("%s copied to %s", from_path, res$metadata$path_lower))
        invisible(res)
      } else {
        pretty_lists(res)
        invisible(res)
      }
    } else {
      stop("File or folder not found \n")
    }
  }


#'Moves a file or folder to a new location.
#'
#' @template from_to
#' @template verbose
#' @template token
#' @param allow_shared_folder  If \code{TRUE}, copy will copy contents in shared
#'   folder
#' @param autorename If there's a conflict, have the Dropbox server try to
#'   autorename the file to avoid the conflict.
#' @param allow_ownership_transfer Allow moves by owner even if it would result
#'   in an ownership transfer for the content being moved. This does not apply
#'   to copies. The default for this field is False.
#' @export
#' @references \href{https://www.dropbox.com/developers/documentation/http/documentation#files-move_v2}{API documentation}
#' @examples \dontrun{
#' write.csv(mtcars, file = "mt.csv")
#' drop_upload("mt.csv")
#' drop_create("drop_test2")
#' drop_move("mt.csv", "drop_test2/mt.csv")
#' }
drop_move <-
  function(from_path = NULL,
           to_path = NULL,
           allow_shared_folder = FALSE,
           autorename = FALSE,
           allow_ownership_transfer = FALSE,
           verbose = FALSE,
           dtoken = get_dropbox_token())  {
    move_url <- "https://api.dropboxapi.com/2/files/move_v2"

    from_path <- add_slashes(from_path)
    to_path <- add_slashes(to_path)

    # Moving a file into a folder
    file_to_folder <-
      c(drop_type(from_path) == "file",
        drop_type(to_path) == "folder")
    to_path <-
      ifelse(all(file_to_folder), paste0(to_path, from_path), to_path)

    # Moving a folder to another folder
    folder_to_folder <-
      c(drop_type(from_path) == "folder",
        drop_type(to_path) == "folder")
    to_path <-
      ifelse(all(folder_to_folder), paste0(to_path, from_path), to_path)

    # Moving a file to a file
    # Nothing to do, since both paths reflect origin and destination

    # Moving a folder to an existing filename will result in a HTTP 409 (conflict error)

    args <- drop_compact(
      list(
        from_path = from_path,
        to_path = to_path,
        allow_shared_folder = allow_shared_folder,
        autorename = autorename,
        allow_ownership_transfer = allow_ownership_transfer
      )
    )

    if (drop_exists(from_path)) {
      # move
      x <-
        httr::POST(move_url,
                   httr::config(token = dtoken),
                   body = args,
                   encode = "json")
      res <- httr::content(x)

      if (!verbose) {
        message(sprintf("%s moved to %s", from_path, res$metadata$path_lower))
        invisible(res)
      } else {
        pretty_lists(res)
        invisible(res)
      }
    } else {
      stop("File or folder not found \n")
    }
  }


#'Deletes a file or folder.
#'
#' @template path
#' @template verbose
#' @template token
#' @export
#' @references \href{https://www.dropbox.com/developers/documentation/http/documentation#files-delete_v2}{API documentation}
drop_delete <-
  function (path = NULL,
            verbose = FALSE,
            dtoken = get_dropbox_token()) {
    create_url <- "https://api.dropboxapi.com/2/files/delete_v2"
    if (drop_exists(path)) {
      path <- add_slashes(path)
      x <-
        httr::POST(
          create_url,
          httr::config(token = dtoken),
          body = list(path = path),
          encode = "json"
        )
      res <- httr::content(x)

      if (verbose) {
        res
      } else {
        invisible(res)
      }
    } else {
      # Since file/folder wasn't found, report a stop error
      stop("File not found on current path")
    }
  }


#'Creates a folder on Dropbox
#'
#'Returns a list containing the following fields: "size", "rev", "thumb_exists",
#'"bytes", "modified", "path", "is_dir", "icon", "root", "revision"
#'@template path
#'@param autorename Set to \code{TRUE} to automatically rename. Default is FALSE.
#'@template verbose
#'@template token
#' @references \href{https://www.dropbox.com/developers/documentation/http/documentation#files-create_folder_v2}{API documentation}
#'@export
#' @examples \dontrun{
#' drop_create(path = "foobar")
#'}
drop_create <-
  function(path = NULL,
           autorename = FALSE,
           verbose = FALSE,
           dtoken = get_dropbox_token()) {

   # if a folder exists, but autorename is TRUE, proceed
   # However, if a folder exists, and autorename if FALSE, fail in the else.
    if (!drop_exists(path) || autorename) {
      create_url <- "https://api.dropboxapi.com/2/files/create_folder_v2"

      path <- add_slashes(path)
      x <-
        httr::POST(
          create_url,
          config(token = dtoken),
          body = list(path = path, autorename = autorename),
          encode = "json"
        )
      results <- httr::content(x)

      if (verbose) {
        pretty_lists(results)
        invisible(results)
      } else {
          message(sprintf("Folder %s created successfully \n", results$metadata$path_lower))
          invisible(results)
      }

      invisible(results)
    } else {
      stop("Folder already exists")
    }
  }






#' Checks to see if a file/folder exists on Dropbox
#'
#' Since many file operations such as move, copy, delete and history can only act
#' on files that currently exist on a Dropbox store, checking to see if the
#' \code{path} is valid before operating prevents bad API calls from being sent
#' to the server. This functions returns a logical response after checking if a
#' file path is valid on Dropbox.
#'
#' @param path The full path to a Dropbox file
#' @template token
#'
#' @return boolean; TRUE is the file or folder exists, FALSE if it does not.
#'
#' @examples \dontrun{
#'   drop_create("existential_test")
#'   drop_exists("existential_test")
#'   drop_delete("existential_test")
#' }
#'
#' @export
drop_exists <- function(path = NULL, dtoken = get_dropbox_token()) {
  #assertive::assert_is_not_null(path)
  assertthat::assert_that(!is.null(path))

  if (!grepl('^/', path))
    path <- paste0("/", path)
  dir_name <- suppressMessages(dirname(path))
  # In issue #142, this part below (the drop_dir call) fails when drop_dir is
  # looking to see if a second level folder exists (when it doesn't.) One safe
  # option is to only run drop_dir('/', recursive = TRUE) and then grep through
  # that. Downside: It would take forever if this was a really large account.
  #
  # Other solution is to use purrr::safely to trap the error and return FALSE
  # (TODO): Explore uninteded consequence of this.
  safe_dir_check <-
    purrr::safely(drop_get_metadata, otherwise = FALSE, quiet = TRUE)
  dir_listing <- safe_dir_check(path = path, dtoken = dtoken)
    # browser()
  if (length(dir_listing$result) == 1) {
    # This means that object does not exist on Dropbox
    FALSE
  } else {
    # Root of path (dir_name), exists/
    paths_only <- dir_listing$result$path_display

    if (path %in% paths_only) {
      TRUE
    } else {
      FALSE
    }
  }


}

#' Checks if an object is a file on Dropbox
#'
#' @noRd
drop_is_file <- function(x, dtoken = get_dropbox_token()) {
  x <- drop_get_metadata(x)
  ifelse(x$.tag == "file", TRUE, FALSE)
}

#' Checks if an object is a folder on Dropbox
#'
#' @noRd
drop_is_folder <- function(x, dtoken = get_dropbox_token()) {
  x <- drop_get_metadata(x)
  ifelse(x$.tag == "folder", TRUE, FALSE)
}

#' Checks on a name and returns file, folder, or FALSE for dropbox status
#' @noRd
drop_type <- function(x, dtoken = get_dropbox_token()) {
  safe_meta <-
    purrr::safely(drop_get_metadata, otherwise = FALSE, quiet = TRUE)
  x <- safe_meta(x)
  if (length(x$result) == 1 && !x$result) {
    FALSE
  } else {
    x$result$.tag
  }
}
