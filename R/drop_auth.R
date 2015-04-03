# environment to store credentials
.dstate <- new.env(parent = emptyenv())


#'Authentication for Dropbox
#'
#'This function authenticates you into Dropbox. The documentation for the core Dropbox API is available \href{https://www.dropbox.com/developers/core/docs}{here}.
#'@param new_user Default is \code{FALSE}. Set to \code{TRUE} if you need to
#'  switch to a new user account or just flush existing token.
#'@param key Your application key
#'@param secret Your application token. rDrop2 already comes with a key/secret
#'  but you are welcome to swap out with our own.
#'@export
#'@import httr
#' @examples \dontrun{
#' drop_auth()
#' # If you want to overwrite an existing tokend and switch to a new user,
#' # set new_user to TRUE.
#' drop_auth(new_user = TRUE)
#'}
drop_auth <- function(new_user = FALSE,
                      key = "mmhfsybffdom42w",
                      secret = "l8zeqqqgm1ne5z0") {

   if(new_user & file.exists(".httr-oauth")) {
    message("Removing old credentials ...")
    file.remove(".httr-oauth")
  }
# These are the app keys
dropbox_app <- oauth_app("dropbox", key, secret)

dropbox <- oauth_endpoint(
  authorize = "https://www.dropbox.com/1/oauth2/authorize",
  access = "https://api.dropbox.com/1/oauth2/token"
)
dropbox_token <- oauth2.0_token(dropbox, dropbox_app, cache = TRUE)
stopifnot(inherits(dropbox_token, "Token2.0"))

.dstate$token <- dropbox_token
}



#' Retrieve drobpox token from environment
#'
#' Get token if it's previously stored, else prompt user to get one.
#'
#' @keywords internal
get_dropbox_token <- function() {

  if(!exists('.dstate') || is.null(.dstate$token)) {
    drop_auth()
  }

.dstate$token
}
