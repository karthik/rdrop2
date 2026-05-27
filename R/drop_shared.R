#' Creates and returns a shared link to a file or folder.
#'
#' @template path
#' @param requested_visibility Can be `public`, `team_only`, or `password`. If the
#'   password option is chosen one must specify the `link_password`. Note that
#'   for basic (i.e. free) Dropbox accounts, the only option is to publicly
#'   share. Private sharing requires a pro account.
#' @param link_password The password needed to access the document if
#'   `request_visibility` is set to password.
#' @param expires Set the expiry time. The timestamp format is
#'   "\%Y-\%m-\%dT\%H:\%M:\%SZ"). If no timestamp is specified, link never expires
#' @template token
#' @export
#' @references \href{https://www.dropbox.com/developers/documentation/http/documentation#sharing-create_shared_link_with_settings}{API documentation}
#' @examples \dontrun{
#' write.csv(mtcars, file = "mt.csv")
#' drop_upload("mt.csv")
#' drop_share("mt.csv")
#' # If you have a pro account, you can share files privately
#' drop_share("mt.csv", requested_visibility = "password", link_password = "test")
#'}
drop_share <- function(path = NULL,
                       requested_visibility = "public",
                       link_password = NULL,
                       expires = NULL,
                       dtoken = get_dropbox_token()) {

  # Check to see if only supported modes are specified
  visibilities <- c("public", "team_only", "password")
  assertthat::assert_that(requested_visibility %in% visibilities)

  path <- add_slashes(path)
  settings <-
    drop_compact(
      list(
        requested_visibility = requested_visibility,
        link_password = link_password,
        expires = expires
      )
    )

  share_url <-
    "https://api.dropboxapi.com/2/sharing/create_shared_link_with_settings"

  drop_request(share_url, dtoken,
               body = list(path = path, settings = settings))
}

#' List all shared links
#'
#' This function returns a list of all links that are currently being shared
#' @template token
#' @param verbose Print verbose output
#'
#' @export
#' @references \href{https://www.dropbox.com/developers/documentation/http/documentation#sharing-list_shared_links}{API documentation}
#'
#' @examples \dontrun{
#' drop_list_shared_links()
#' }
drop_list_shared_links <-
  function(verbose = TRUE, dtoken = get_dropbox_token()) {
    shared_links_url <-
      "https://api.dropboxapi.com/2/sharing/list_shared_links"
    z <- drop_request(shared_links_url, dtoken)
    if (verbose) {
      invisible(z)
      pretty_lists(z)
    } else {
      invisible(z)
    }
  }


#' Download a file from Dropbox via a shared link.
#'
#' Retrieves the content of a file identified by a shared link URL (rather than
#' a Dropbox file path).  This is useful when you have received a shared link
#' from another user.
#'
#' @param url     The shared link URL pointing to the file.
#' @param local_path Path to save the downloaded file to. If \code{NULL}
#'   (default), the file is saved to the working directory using the filename
#'   derived from the link. If a directory, the file is placed inside it.
#' @param overwrite If \code{TRUE}, overwrite an existing local file.
#'   Defaults to \code{FALSE}.
#' @param path    Optional Dropbox path within the shared folder to a specific
#'   sub-file/folder. Leave as \code{NULL} for root of the shared link.
#' @template token
#'
#' @return \code{TRUE} invisibly on success.
#'
#' @references \href{https://www.dropbox.com/developers/documentation/http/documentation#sharing-get_shared_link_file}{API documentation}
#'
#' @export
#'
#' @examples \dontrun{
#'   drop_get_shared_link_file(
#'     url = "https://www.dropbox.com/s/xxxx/example.csv?dl=0",
#'     local_path = "example.csv"
#'   )
#' }
drop_get_shared_link_file <- function(url,
                                      local_path = NULL,
                                      overwrite = FALSE,
                                      path = NULL,
                                      dtoken = get_dropbox_token()) {

  download_url <- "https://content.dropboxapi.com/2/sharing/get_shared_link_file"

  arg <- drop_compact(list(url = url, path = path))
  arg_json <- jsonlite::toJSON(arg, auto_unbox = TRUE)

  # derive local filename from the shared URL if not provided
  if (is.null(local_path)) {
    local_path <- basename(gsub("\\?.*$", "", url))
    if (nchar(local_path) == 0) local_path <- "dropbox_download"
  } else if (dir.exists(local_path)) {
    fname <- basename(gsub("\\?.*$", "", url))
    if (nchar(fname) == 0) fname <- "dropbox_download"
    local_path <- file.path(local_path, fname)
  }

  if (file.exists(local_path) && !overwrite) {
    cli::cli_abort(
      "Local file {.file {local_path}} already exists. Set {.code overwrite = TRUE} to replace it."
    )
  }

  req <- httr2::request(download_url)
  req <- httr2::req_auth_bearer_token(req, resolve_token(dtoken))
  req <- httr2::req_headers(req, `Dropbox-API-Arg` = arg_json)
  req <- httr2::req_body_raw(req, "", type = "application/json")
  httr2::req_perform(req, path = local_path)

  invisible(TRUE)
}
