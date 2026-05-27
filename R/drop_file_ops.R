

#' Copies a file or folder to a new location.
#'
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
drop_copy <- function(from_path = NULL,
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
    file_to_folder <- c(drop_type(from_path) == "file",
                        drop_type(to_path) == "folder")
    to_path <- ifelse(all(file_to_folder), paste0(to_path, from_path), to_path)
    # Copying a folder to another folder
    folder_to_folder <- c(drop_type(from_path) == "folder",
                          drop_type(to_path) == "folder")
    to_path <- ifelse(all(folder_to_folder), paste0(to_path, from_path), to_path)
    # Nothing to do, since both paths reflect origin and destination
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
      res <- drop_request(copy_url, dtoken, body = args)
      if (!verbose) {
        cli::cli_alert_success("{from_path} copied to {res$metadata$path_lower}")
        invisible(res)
      } else {
        pretty_lists(res)
        invisible(res)
      }
    } else {
      cli::cli_abort("File or folder not found")
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
drop_move <- function(from_path = NULL,
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
    file_to_folder <- c(drop_type(from_path) == "file",
                        drop_type(to_path) == "folder")
    to_path <- ifelse(all(file_to_folder), paste0(to_path, from_path), to_path)

    # Moving a folder to another folder
    folder_to_folder <- c(drop_type(from_path) == "folder",
                          drop_type(to_path) == "folder")
    to_path <- ifelse(all(folder_to_folder), paste0(to_path, from_path), to_path)

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
      res <- drop_request(move_url, dtoken, body = args)

      if (!verbose) {
        cli::cli_alert_success("{from_path} moved to {res$metadata$path_lower}")
        invisible(res)
      } else {
        pretty_lists(res)
        invisible(res)
      }
    } else {
      cli::cli_abort("File or folder not found")
    }
  }


#'Deletes a file or folder.
#'
#' @template path
#' @template verbose
#' @template token
#' @export
#' @references \href{https://www.dropbox.com/developers/documentation/http/documentation#files-delete_v2}{API documentation}
drop_delete <- function(path = NULL,
            verbose = FALSE,
            dtoken = get_dropbox_token()) {
    create_url <- "https://api.dropboxapi.com/2/files/delete_v2"
    if (drop_exists(path)) {
      path <- add_slashes(path)
      res <- drop_request(create_url, dtoken, body = list(path = path))

      if (verbose) {
        res
      } else {
        invisible(res)
      }
    } else {
      # Since file/folder wasn't found, report a stop error
      cli::cli_abort("File not found on current path")
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
drop_create <- function(path = NULL,
           autorename = FALSE,
           verbose = FALSE,
           dtoken = get_dropbox_token()) {

   # if a folder exists, but autorename is TRUE, proceed
   # However, if a folder exists, and autorename if FALSE, fail in the else.
    if (!drop_exists(path) || autorename) {
      create_url <- "https://api.dropboxapi.com/2/files/create_folder_v2"

      path <- add_slashes(path)
      results <- drop_request(
        create_url, dtoken,
        body = list(path = path, autorename = autorename)
      )

      if (verbose) {
        pretty_lists(results)
        invisible(results)
      } else {
          cli::cli_alert_success("Folder {results$metadata$path_lower} created successfully")
          invisible(results)
      }

      invisible(results)
    } else {
      cli::cli_abort("Folder already exists")
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
  safe_dir_check <- purrr::safely(drop_get_metadata, otherwise = FALSE, quiet = TRUE)
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
  safe_meta <- purrr::safely(drop_get_metadata, otherwise = FALSE, quiet = TRUE)
  x <- safe_meta(x)
  if (length(x$result) == 1 && !x$result) {
    FALSE
  } else {
    x$result$.tag
  }
}


#' Copy multiple files or folders in a single batch request.
#'
#' More efficient than calling \code{\link{drop_copy}} repeatedly for large
#' numbers of files.  The function blocks until the batch job completes.
#'
#' @param entries A list of named lists, each with \code{from_path} and
#'   \code{to_path} character elements.
#' @param autorename If \code{TRUE}, the Dropbox server will try to autorename
#'   files to avoid conflicts. Default \code{FALSE}.
#' @template token
#'
#' @return A list of per-entry results returned by the Dropbox API.
#'
#' @references \href{https://www.dropbox.com/developers/documentation/http/documentation#files-copy_batch_v2}{API documentation}
#'
#' @export
#'
#' @examples \dontrun{
#'   entries <- list(
#'     list(from_path = "/file1.csv", to_path = "/backup/file1.csv"),
#'     list(from_path = "/file2.csv", to_path = "/backup/file2.csv")
#'   )
#'   drop_copy_batch(entries)
#' }
drop_copy_batch <- function(entries, autorename = FALSE,
                            dtoken = get_dropbox_token()) {
  url_start  <- "https://api.dropboxapi.com/2/files/copy_batch_v2"
  url_check  <- "https://api.dropboxapi.com/2/files/copy_batch/check_v2"

  res <- drop_request(url_start, dtoken,
                      body = list(entries = entries, autorename = autorename))

  .poll_async_job(res, url_check, dtoken)
}


#' Move multiple files or folders in a single batch request.
#'
#' More efficient than calling \code{\link{drop_move}} repeatedly for large
#' numbers of files.  The function blocks until the batch job completes.
#'
#' @param entries A list of named lists, each with \code{from_path} and
#'   \code{to_path} character elements.
#' @param autorename If \code{TRUE}, the Dropbox server will try to autorename
#'   files to avoid conflicts. Default \code{FALSE}.
#' @param allow_ownership_transfer If \code{TRUE}, allow moves that would
#'   result in ownership transfer. Default \code{FALSE}.
#' @template token
#'
#' @return A list of per-entry results returned by the Dropbox API.
#'
#' @references \href{https://www.dropbox.com/developers/documentation/http/documentation#files-move_batch_v2}{API documentation}
#'
#' @export
#'
#' @examples \dontrun{
#'   entries <- list(
#'     list(from_path = "/file1.csv", to_path = "/archive/file1.csv")
#'   )
#'   drop_move_batch(entries)
#' }
drop_move_batch <- function(entries, autorename = FALSE,
                            allow_ownership_transfer = FALSE,
                            dtoken = get_dropbox_token()) {
  url_start <- "https://api.dropboxapi.com/2/files/move_batch_v2"
  url_check <- "https://api.dropboxapi.com/2/files/move_batch/check_v2"

  res <- drop_request(url_start, dtoken,
                      body = list(
                        entries                  = entries,
                        autorename               = autorename,
                        allow_ownership_transfer = allow_ownership_transfer
                      ))

  .poll_async_job(res, url_check, dtoken)
}


#' Delete multiple files or folders in a single batch request.
#'
#' More efficient than calling \code{\link{drop_delete}} repeatedly for large
#' numbers of files.  The function blocks until the batch job completes.
#'
#' @param entries A list of named lists, each with a \code{path} character
#'   element specifying the Dropbox path to delete.
#' @template token
#'
#' @return A list of per-entry results returned by the Dropbox API.
#'
#' @references \href{https://www.dropbox.com/developers/documentation/http/documentation#files-delete_batch}{API documentation}
#'
#' @export
#'
#' @examples \dontrun{
#'   entries <- list(
#'     list(path = "/old_file1.csv"),
#'     list(path = "/old_file2.csv")
#'   )
#'   drop_delete_batch(entries)
#' }
drop_delete_batch <- function(entries, dtoken = get_dropbox_token()) {
  url_start <- "https://api.dropboxapi.com/2/files/delete_batch"
  url_check <- "https://api.dropboxapi.com/2/files/delete_batch/check"

  res <- drop_request(url_start, dtoken, body = list(entries = entries))

  .poll_async_job(res, url_check, dtoken)
}


#' Poll an async Dropbox job until it completes.
#'
#' @param res   Initial response from a batch/async endpoint.
#' @param check_url  URL of the corresponding check endpoint.
#' @param dtoken ****** string.
#' @param interval Polling interval in seconds. Default 2.
#'
#' @return The completed job result list.
#'
#' @noRd
.poll_async_job <- function(res, check_url, dtoken, interval = 2) {
  # If already complete, return immediately
  if (!is.null(res[[".tag"]]) && res[[".tag"]] == "complete") {
    return(res$entries)
  }

  async_job_id <- res$async_job_id
  if (is.null(async_job_id)) return(res)

  repeat {
    Sys.sleep(interval)
    status <- drop_request(check_url, dtoken,
                           body = list(async_job_id = async_job_id))
    tag <- status[[".tag"]]
    if (!is.null(tag) && tag == "complete") {
      return(status$entries)
    }
    if (!is.null(tag) && tag == "failed") {
      cli::cli_abort("Batch job failed: {status$failure}")
    }
    # tag == "in_progress": keep polling
  }
}
