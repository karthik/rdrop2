# environment to store credentials
.dstate <- new.env(parent = emptyenv())


#'Authentication for Dropbox
#'
#'This function authenticates you into Dropbox. The documentation for the
#'\href{https://www.dropbox.com/developers/core/docs}{core Dropbox API} provides
#'more details including alternate methods if you desire to reimplement your
#'own.
#'@param new_user Default is \code{FALSE}. Set to \code{TRUE} if you need to
#'  switch to a new user account or just flush existing token.
#'@param key Your application key. rdrop2 already comes with a key/secret but
#'  you are welcome to swap out with our own. Since these keys are shipped with
#'  the package, there is a small chance they could be voided if someone abuses
#'  the key. So if you plan to use this in production, or for an internal tool,
#'  the recommended practice is to create a new application on Dropbox and use
#'  those keys for your purposes.
#'@param secret Your application token. rdrop2 already comes with a key/secret
#'  but you are welcome to swap out with our own.
#'@param cache By default your credentials are locally cached in a file called
#'  \code{.httr-oauth}. Set to FALSE if you need to authenticate separately each
#'  time.
#'@param rdstoken File path to stored RDS token. In server environments where
#'  interactive OAuth is not possible, a token can be created on a desktop
#'  client and used in production. See \href{https://github.com/karthik/rdrop2}
#'  for how to create RDS token.
#'@export
#'@import httr
#' @examples \dontrun{
#' drop_auth()
#'
#' # If you want to overwrite an existing local token and switch to a new user,
#' # set new_user to TRUE.
#' drop_auth(new_user = TRUE)
#'
#' # To use a stored token, set new_user to FALSE and provide token location
#' drop_auth(new_user = FALSE, rdstoken = "/path/to/tokenfile.RDS")
#'}
drop_auth <- function(new_user = FALSE,
                      key = "mmhfsybffdom42w",
                      secret = "l8zeqqqgm1ne5z0",
                      cache = TRUE,
                      rdstoken = NA) {

  # Check if token file exists & use it
  if (new_user == FALSE &  !is.na(rdstoken)) {
    if (file.exists(rdstoken)) {
      .dstate$token <- readRDS(rdstoken)
    } else {
      warning("Token file not found, creating new one ...")
      new_user <- TRUE
    }
  } else {
    # Force new
    if (new_user & file.exists(".httr-oauth")) {
      message("Removing old credentials ...")
      file.remove(".httr-oauth")
    }

    # These are the app keys
    dropbox_app <- httr::oauth_app("dropbox", key, secret)

    # the dropbox endpoint
    dropbox <- httr::oauth_endpoint(
      authorize = "https://www.dropbox.com/1/oauth2/authorize",
      access = "https://api.dropbox.com/1/oauth2/token"
    )
    dropbox_token <- httr::oauth2.0_token(dropbox, dropbox_app, cache = cache)
    stopifnot(inherits(dropbox_token, "Token2.0"))

    .dstate$token <- dropbox_token
  }
}



#' Retrieve Dropbox token from environment
#'
#' Retrieves a token if it is previously stored, otherwise prompts user to get one.
#'
#' @keywords internal
get_dropbox_token <- function() {

  if(!exists('.dstate') || is.null(.dstate$token)) {
    drop_auth()
  } else {
    .dstate$token
  }
}

