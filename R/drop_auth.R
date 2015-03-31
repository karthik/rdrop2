

#' Authentication for Dropbox
#'
#' This function authenticates you into Dropbox
#' @param new_user Default is \code{FALSE}. Set to \code{TRUE} if you need to switch to a new user account.
#' @export
#' @import httr
#' @examples \dontrun{
#' dropbox_auth()
#'}
drop_auth <- function(new_user = FALSE) {

   if(new_user & file.exists(".httr-oauth")) {
    message("Removing old credentials ...")
    file.remove(".httr-oauth")
  }
# These are the app keys
key <- "mmhfsybffdom42w"
secret <- "l8zeqqqgm1ne5z0"
dropbox <- oauth_endpoint("request_token", "authorize", "access_token",
                          base_url = "https://www.dropbox.com/1/oauth2")
dropbox_app <- oauth_app("dropbox", key, secret)
dropbox_token <-oauth2.0_token(dropbox, dropbox_app, cache = TRUE)

# check for validity so error is found before making requests
# shouldn't happen if id and secret don't change
if("invalid_client" %in% unlist(dropbox_token$credentials))
  message("Authorization error. Please check client_id and client_secret.")

stopifnot(inherits(dropbox_token, "Token2.0"))

.state$token <- dropbox_token
}
