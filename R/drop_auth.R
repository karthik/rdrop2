# environment to store credentials
.dstate <- new.env(parent = emptyenv())


#' Authentication for Dropbox
#'
#' This function authenticates you into Dropbox. The documentation for the
#' \href{https://www.dropbox.com/developers/core/docs}{core Dropbox API}
#' provides more details including alternate methods if you desire to
#' reimplement your own.
#'
#' @param new_user Set to \code{TRUE} if you need to switch to a new user
#' account or just flush existing token. Default is \code{FALSE}.
#' @param key Your application key. \code{rdrop2} already comes with a key/secret but
#'   you are welcome to swap out with our own. Since these keys are shipped with
#'   the package, there is a small chance they could be voided if someone abuses
#'   the key. If you plan to use this in production, or for an internal tool,
#'   the recommended practice is to create a new application on Dropbox and use
#'   those keys for your purposes.
#' @param secret Your application secret. Like \code{key}, \code{rdrop2} comes
#' with a secret but you are welcome to swap out with our own.
#' @param cache By default your credentials are locally cached in a file called
#'   \code{.httr-oauth}. Set to FALSE if you need to authenticate separately
#'   each time.
#' @param rdstoken File path to stored RDS token. In server environments where
#'   interactive OAuth is not possible, a token can be created on a desktop
#'   client and used in production. See examples.
#'
#' @return A Token2.0 object, invisibly
#'
#' @import httr
#' @export
#'
#' @examples
#' \dontrun{
#'
#'   # To either read token from .httr-oauth in the working directory or open a
#'   # web browser to authenticate (and cache a token)
#'   drop_auth()
#'
#'   # If you want to overwrite an existing local token and switch to a new
#'   # user, set new_user to TRUE.
#'   drop_auth(new_user = TRUE)
#'
#'   # To store a token for re-use (more flexible than .httr-oauth), save the
#'   # output of drop_auth and save it to an RDS file
#'   token <- drop_auth()
#'   saveRDS(token, "/path/to/tokenfile.RDS")
#'
#'   # To use a stored token provide token location
#'   drop_auth(rdstoken = "/path/to/tokenfile.RDS")
#' }
drop_auth <- function(new_user = FALSE,
                      key = "mmhfsybffdom42w",
                      secret = "l8zeqqqgm1ne5z0",
                      cache = TRUE,
                      rdstoken = NA) {

  # check if token file exists & use it
  if (new_user == FALSE &  !is.na(rdstoken)) {

    # read token or error
    if (file.exists(rdstoken)) {
      .dstate$token <- readRDS(rdstoken)
    } else {
      stop("token file not found")
    }

    # authenticate normally
  } else {

    # remove any cached token if new user
    if (new_user && file.exists(".httr-oauth")) {
      message("Removing old credentials...")
      file.remove(".httr-oauth")
    }

    # set dropbox oauth2 endpoints
    dropbox <- httr::oauth_endpoint(
      authorize = "https://www.dropbox.com/oauth2/authorize",
      access = "https://api.dropbox.com/oauth2/token"
    )

    # registered dropbox app's key & secret
    dropbox_app <- httr::oauth_app("dropbox", key, secret)

    # get the token
    dropbox_token <- httr::oauth2.0_token(dropbox, dropbox_app, cache = cache)

    # make sure we got a token
    if (!inherits(dropbox_token, "Token2.0")) {
      stop("something went wrong, try again")
    }

    # cache token in rdrop2 namespace
    .dstate$token <- dropbox_token
  }
}



#' Retrieve oauth2 token from rdrop2-namespaced environment
#'
#' Retrieves a token if it is previously stored, otherwise prompts user to get one.
#'
#' @keywords internal
get_dropbox_token <- function() {

  if (!exists('.dstate') || is.null(.dstate$token)) {
    drop_auth()
  } else {
    .dstate$token
  }
}

