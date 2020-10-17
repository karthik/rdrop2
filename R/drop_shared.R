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
  # This is a list because in the POST call it becomes a nested JSON.
  # A sample response looks like this:

  # curl -X POST https://api.dropboxapi.com/2/sharing/create_shared_link_with_settings \
  #  --header "Authorization: Bearer <get access token>" \
  #  --header "Content-Type: application/json" \
  #  --data "{\"path\": \"/Prime_Numbers.txt\",\"settings\": {\"requested_visibility\": \"public\"}

  # Check to see if only supported modes are specified
  visibilities <- c("public", "team_only", "password")
  assertive::assert_any_are_matching_fixed(visibilities, requested_visibility)

  # TODO
  # Once the new drop_exists is done, one must check to see if a file/folder
  # exists on Dropbox before proceeding

  path <- add_slashes(path)

  settings <- purrr::compact(tibble::lst(
    requested_visibility,
    link_password,
    expires
  ))

  api_create_shared_link_with_settings(path, settings, dtoken)
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

    z <- api_list_shared_links(dtoken = dtoken)$links

    if (verbose) {
      invisible(z)
      pretty_lists(z)
    } else {
      invisible(z)
      # TODO
      # Clean up the verbose and non-verbose options
    }
  }


#### API wrappers ####

#' API wrapper for sharing/create_shared_link_with_settings
#'
#' @noRd
#'
#' @keywords internal
api_create_shared_link_with_settings <- function(
  path,
  settings = NULL,
  dtoken
) {

  post_api(
    "https://api.dropboxapi.com/2/sharing/create_shared_link_with_settings",
    dtoken,
    path,
    settings
  )
}


#' API wrapper for sharing/list_shared_links
#'
#' @noRd
#'
#' @keywords internal
api_list_shared_links <- function(
  path = NULL,
  cursor = NULL,
  direct_only = NULL,
  dtoken
) {

  post_api(
    "https://api.dropboxapi.com/2/sharing/list_shared_links",
    dtoken,
    path,
    cursor,
    direct_only
  )
}
