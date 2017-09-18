#' Get information about current Dropbox account.
#'
#' Fields returned will vary by account;
#'
#' @template token
#'
#' @import httr
#' @export
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

  # make request and parse response
  req <- httr::POST(url, httr::config(token = dtoken))
  httr::content(req)
}
