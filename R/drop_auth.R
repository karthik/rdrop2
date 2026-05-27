# environment to store credentials
.dstate <- new.env(parent = emptyenv())

# default cache path for the token RDS file
.default_token_cache <- ".rdrop2-token.rds"


#' Authentication for Dropbox
#'
#' This function authenticates you into Dropbox using OAuth 2.0 via the
#' \pkg{httr2} package. The documentation for the
#' \href{https://www.dropbox.com/developers/documentation}{Dropbox API v2}
#' provides more details.
#'
#' @param new_user Set to \code{TRUE} if you need to switch to a new user
#'   account or flush the existing cached token. Default is \code{FALSE}.
#' @param key Your application key. \code{rdrop2} ships with a default key, but
#'   for production use you should create your own Dropbox app and supply its
#'   credentials.
#' @param secret Your application secret.
#' @param cache Either \code{TRUE} (save token to \code{.rdrop2-token.rds} in
#'   the working directory), \code{FALSE} (do not cache), or a file path string
#'   specifying where to save the token RDS file.
#' @param rdstoken File path to a previously saved RDS token. In non-interactive
#'   (server) environments, create a token on a desktop machine with
#'   \code{drop_auth()}, save it with \code{saveRDS()}, and supply the path
#'   here. See examples.
#'
#' @return The \code{httr2_token} object, invisibly.
#'
#' @import httr2
#' @references \href{https://www.dropbox.com/developers/documentation/http/documentation#authorization}{API documentation}
#' @export
#'
#' @examples
#' \dontrun{
#'
#'   # Open a browser to authenticate (and cache the token)
#'   drop_auth()
#'
#'   # Switch to a new user account
#'   drop_auth(new_user = TRUE)
#'
#'   # Save the token for later re-use
#'   token <- drop_auth()
#'   saveRDS(token, "/path/to/tokenfile.rds")
#'
#'   # Load a previously saved token
#'   drop_auth(rdstoken = "/path/to/tokenfile.rds")
#' }
drop_auth <- function(new_user = FALSE,
                      key = "mmhfsybffdom42w",
                      secret = "l8zeqqqgm1ne5z0",
                      cache = TRUE,
                      rdstoken = NA) {

  # resolve cache path
  cache_path <- if (isTRUE(cache)) {
    .default_token_cache
  } else if (is.character(cache)) {
    cache
  } else {
    NULL
  }

  # load token from explicit RDS path
  if (!isTRUE(new_user) && !is.na(rdstoken)) {
    if (!file.exists(rdstoken)) cli::cli_abort("token file not found")
    .dstate$token      <- readRDS(rdstoken)
    .dstate$cache_path <- rdstoken
    return(invisible(.dstate$token))
  }

  # load token from cache path (unless new_user)
  if (!isTRUE(new_user) && !is.null(cache_path) && file.exists(cache_path)) {
    .dstate$token      <- readRDS(cache_path)
    .dstate$cache_path <- cache_path
    return(invisible(.dstate$token))
  }

  # remove old cache if switching users
  if (isTRUE(new_user) && !is.null(cache_path) && file.exists(cache_path)) {
    cli::cli_alert_info("Removing old cached credentials...")
    file.remove(cache_path)
  }

  # build OAuth2 client
  dropbox_client <- httr2::oauth_client(
    id        = key,
    secret    = secret,
    token_url = "https://api.dropbox.com/oauth2/token",
    name      = "dropbox"
  )

  # run auth-code flow (opens browser); request offline access so that
  # Dropbox returns a refresh_token alongside the short-lived access_token.
  # redirect_uri must match the URI registered for the Dropbox app (port 1410).
  dropbox_token <- httr2::oauth_flow_auth_code(
    client       = dropbox_client,
    auth_url     = "https://www.dropbox.com/oauth2/authorize",
    auth_params  = list(token_access_type = "offline"),
    redirect_uri = "http://localhost:1410/",
    pkce         = FALSE
  )

  if (is.null(dropbox_token$access_token)) {
    cli::cli_abort("Authentication failed: no access token returned. Please try again.")
  }

  # persist to cache
  if (!is.null(cache_path)) {
    saveRDS(dropbox_token, cache_path)
  }

  .dstate$token      <- dropbox_token
  .dstate$client     <- dropbox_client
  .dstate$cache_path <- cache_path
  invisible(.dstate$token)
}


#' Authenticate with Dropbox using environment variables
#'
#' A non-interactive authentication method that exchanges a long-lived refresh
#' token for a short-lived access token.  Suitable for server or CI/CD
#' environments where browser-based authentication is not possible.
#'
#' Set the following environment variables before calling this function (or any
#' rdrop2 function that requires authentication):
#' \itemize{
#'   \item \code{DROPBOX_APP_KEY} – the app key from your Dropbox app console.
#'   \item \code{DROPBOX_APP_SECRET} – the app secret.
#'   \item \code{DROPBOX_REFRESH_TOKEN} – a long-lived refresh token. Obtain
#'     one by running \code{drop_auth()} interactively and inspecting
#'     \code{token$refresh_token}.
#' }
#'
#' @param app_key      Dropbox application key. Defaults to
#'   \code{Sys.getenv("DROPBOX_APP_KEY")}.
#' @param app_secret   Dropbox application secret. Defaults to
#'   \code{Sys.getenv("DROPBOX_APP_SECRET")}.
#' @param refresh_token Long-lived refresh token. Defaults to
#'   \code{Sys.getenv("DROPBOX_REFRESH_TOKEN")}.
#'
#' @return The token list (invisibly). The access token is stored in the rdrop2
#'   session environment for use by all other rdrop2 functions.
#'
#' @import httr2
#' @importFrom cli cli_alert_info cli_abort
#' @export
#'
#' @examples
#' \dontrun{
#'   Sys.setenv(
#'     DROPBOX_APP_KEY       = "your_app_key",
#'     DROPBOX_APP_SECRET    = "your_app_secret",
#'     DROPBOX_REFRESH_TOKEN = "your_refresh_token"
#'   )
#'   drop_auth_env()
#'
#'   # Alternatively, pass values directly:
#'   drop_auth_env(
#'     app_key       = "your_app_key",
#'     app_secret    = "your_app_secret",
#'     refresh_token = "your_refresh_token"
#'   )
#' }
drop_auth_env <- function(
    app_key       = Sys.getenv("DROPBOX_APP_KEY"),
    app_secret    = Sys.getenv("DROPBOX_APP_SECRET"),
    refresh_token = Sys.getenv("DROPBOX_REFRESH_TOKEN")
) {
  cli::cli_alert_info("Authenticating with Dropbox using environment variables...")

  if (!nzchar(app_key))
    cli::cli_abort("app_key is empty. Set {.envvar DROPBOX_APP_KEY} or pass it directly.")
  if (!nzchar(app_secret))
    cli::cli_abort("app_secret is empty. Set {.envvar DROPBOX_APP_SECRET} or pass it directly.")
  if (!nzchar(refresh_token))
    cli::cli_abort("refresh_token is empty. Set {.envvar DROPBOX_REFRESH_TOKEN} or pass it directly.")

  token_resp <- httr2::request("https://api.dropbox.com/oauth2/token") |>
    httr2::req_body_form(
      refresh_token = refresh_token,
      grant_type    = "refresh_token",
      client_id     = app_key,
      client_secret = app_secret
    ) |>
    httr2::req_error(body = function(resp) httr2::resp_body_json(resp)$error) |>
    httr2::req_perform()

  token <- httr2::resp_body_json(token_resp)

  # Convert expires_in (seconds) to an absolute timestamp for expiry checks
  if (!is.null(token$expires_in)) {
    token$expires_at <- Sys.time() + token$expires_in
  }

  # Dropbox does not re-issue the refresh token on refresh; preserve the original
  token$refresh_token <- refresh_token

  # Store the OAuth client so that get_dropbox_token() can refresh automatically later
  .dstate$client <- httr2::oauth_client(
    id        = app_key,
    secret    = app_secret,
    token_url = "https://api.dropbox.com/oauth2/token",
    name      = "dropbox"
  )
  .dstate$token <- token

  invisible(token)
}


#' Retrieve the Dropbox bearer token string
#'
#' Returns the access token string stored in the rdrop2 environment. If no
#' token is cached, \code{\link{drop_auth}} is called interactively. If the
#' stored token has expired and a refresh token is available, the token is
#' silently refreshed and the cache file is updated.
#'
#' @keywords internal
#' @export
#' @return The Dropbox access token string.
get_dropbox_token <- function() {
  if (!exists(".dstate") || is.null(.dstate$token)) {
    # Prefer non-interactive env-var authentication when the variables are set
    env_key     <- Sys.getenv("DROPBOX_APP_KEY")
    env_secret  <- Sys.getenv("DROPBOX_APP_SECRET")
    env_refresh <- Sys.getenv("DROPBOX_REFRESH_TOKEN")
    if (nzchar(env_key) && nzchar(env_secret) && nzchar(env_refresh)) {
      drop_auth_env(env_key, env_secret, env_refresh)
    } else {
      drop_auth()
    }
  }

  token <- .dstate$token

  # Refresh if the access token has expired and we have a refresh token
  has_refresh  <- !is.null(token$refresh_token)
  has_expiry   <- !is.null(token$expires_at)
  is_expired   <- has_expiry && token$expires_at < Sys.time()

  if (has_refresh && is_expired) {
    client <- if (!is.null(.dstate$client)) {
      .dstate$client
    } else {
      httr2::oauth_client(
        id        = "mmhfsybffdom42w",
        secret    = "l8zeqqqgm1ne5z0",
        token_url = "https://api.dropbox.com/oauth2/token",
        name      = "dropbox"
      )
    }
    old_refresh_token <- token$refresh_token
    token <- httr2::oauth_flow_refresh(client, old_refresh_token)
    # Dropbox does not re-issue the refresh token on refresh; preserve the
    # original so subsequent refreshes continue to work.
    if (is.null(token$refresh_token)) {
      token$refresh_token <- old_refresh_token
    }
    .dstate$token <- token
    if (!is.null(.dstate$cache_path)) {
      saveRDS(token, .dstate$cache_path)
    }
  }

  token$access_token
}

