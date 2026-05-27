#' Get information about current Dropbox account.
#'
#' Fields returned will vary by account.
#'
#' @template token
#'
#' @return
#'   Nested list with elements \code{account_id},
#'   \code{name} (list), \code{email}, \code{email_verified}, \code{disabled},
#'   \code{locale}, \code{referral_link}, \code{is_paired}, \code{account_type}
#'   (list).
#'
#'   If available, may also return \code{profile_photo_url},
#'   \code{country}, \code{team} (list), \code{team_member_id}.
#'
#' @references \href{https://www.dropbox.com/developers/documentation/http/documentation#users-get_current_account}{API documentation}
#'
#' @export
#'
#' @examples
#' \dontrun{
#'
#'   acc_info <- drop_acc()
#'
#'   # extract display name
#'   acc_info$name$display_name
#' }
drop_acc <- function(dtoken = get_dropbox_token()) {

  url <- "https://api.dropbox.com/2/users/get_current_account"
  drop_request(url, dtoken)
}


#' Get Dropbox storage space usage.
#'
#' Returns how much space the current account is using and how much is
#' allocated.
#'
#' @template token
#'
#' @return A list with elements \code{used} (bytes used) and \code{allocation}
#'   (a list with \code{.tag} and \code{allocated} bytes, or team-level info).
#'
#' @references \href{https://www.dropbox.com/developers/documentation/http/documentation#users-get_space_usage}{API documentation}
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   usage <- drop_space_usage()
#'   cat("Used:", usage$used, "bytes\n")
#'   cat("Allocated:", usage$allocation$allocated, "bytes\n")
#' }
drop_space_usage <- function(dtoken = get_dropbox_token()) {

  url <- "https://api.dropbox.com/2/users/get_space_usage"
  drop_request(url, dtoken)
}
