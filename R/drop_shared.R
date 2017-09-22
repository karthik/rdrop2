#' Creates and returns a shared link to a file or folder.
#'
#' @template path
#' @param requested_visibility Can be `public`, `team_only`, or `password`. If the
#'   passsword option is chosen one must specify the `link_password`. Note that
#'   for basic (i.e. free) Dropbox accounts, the only option is to publicly
#'   share. Private sharing requires a pro account.
#' @param link_password The password needed to access the document if
#'   `request_visibility` is set to password.
#' @param expires Set the expiry time. The timestamp format is
#'   "\%Y-\%m-\%dT\%H:\%M:\%SZ"). If no timestamp is specified, link never expires
#' @template token
#' @export
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
  settings <-
    drop_compact(
      list(
        requested_visibility = requested_visibility,
        link_password = link_password,
        expires = expires
      )
    )
  # settings <- jsonlite::toJSON(settings, auto_unbox = TRUE)
  share_url <-
    "https://api.dropboxapi.com/2/sharing/create_shared_link_with_settings"

  req <- httr::POST(
    url = share_url,
    httr::config(token = get_dropbox_token()),
    body = list(path = path, settings = settings),
    encode = "json"
  )
  # stopping for status otherwise content fails
  httr::stop_for_status(req)
  response <- httr::content(req)
  response
}

#' List all shared links
#'
#' This function returns a list of all links that are currently being shared
#' @template token
#' @param verbose Print verbose output
#'
#' @export
#'
#' @examples \dontrun{
#' list_shared_links()
#' }
list_shared_links <-
  function(verbose = TRUE, dtoken = get_dropbox_token()) {
    shared_links_url <-
      "https://api.dropboxapi.com/2/sharing/list_shared_links"
    res <-
      httr::POST(shared_links_url, httr::config(token = dtoken), encode = "json")
    httr::stop_for_status(res)
    z <- httr::content(res)
    if (verbose) {
      invisible(z)
      pretty_lists(z)
    } else {
      invisible(z)
      # TODO
      # Clean up the verbose and non-verbose options
    }
  }
