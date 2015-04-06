

#' Dropbox account information
#'
#' Retrieves information about the user's account. Returns the following fields:  \code{referral_link}, \code{display_name},  \code{uid}, \code{locale}, \code{email_verified}, \code{quota_info.datastores}, \code{quota_info.shared}, \code{quota_info.quota}, \code{quota_info.normal}, \code{is_paired}, \code{country}, \code{name_details.familiar_name}, \code{name_details.surname}, \code{name_details.given_name}, \code{email}
#' @template token
#' @template verbose
#' @export
#' @examples \dontrun{
#' drop_acc()
#' # Select name and UID
#' drop_acc() %>% select(uid, display_name, quota_info.normal)
#'}
drop_acc <- function(dtoken = get_dropbox_token(), verbose = FALSE) {
  url <- "https://api.dropbox.com/1/account/info"
  req <- httr::GET(url, config(token = dtoken))
  res <- content(req)
  res <- LinearizeNestedList(res) # This flattens nested JSON.
  if(verbose) {
    pretty_lists(res)
  } else {
    data.frame(t(unlist(res)))
  }
}
