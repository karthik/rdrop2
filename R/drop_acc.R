

#' Dropbox account information
#'
#' Retrieves information about the user's account. Returns the following fields:  referral_link, display_name,  uid, locale, email_verified, quota_info.datastores, quota_info.shared, quota_info.quota, quota_info.normal, is_paired, country, name_details.familiar_name, name_details.surname, name_details.given_name, email
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
  res <- LinearizeNestedList(res)
  if(verbose) {
    pretty_lists(res)
  } else {
    data.frame(t(unlist(res)))
  }
}
