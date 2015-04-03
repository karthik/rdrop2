

#' Dropbox account information
#'
#' Retrieves information about the user's account. Returns the following fields:  referral_link, display_name,  uid, locale, email_verified, quota_info.datastores, quota_info.shared, quota_info.quota, quota_info.normal, is_paired, country, name_details.familiar_name, name_details.surname, name_details.given_name, email
#' @export
#' @examples \dontrun{
#' acc_info()
#' # Select name and UID
#' acc_info() %>% select(uid, name_details.given_name)
#'}
acc_info <- function() {
  url <- "https://api.dropbox.com/1/account/info"
  req <- httr::GET(url, config(token = get_dropbox_token()))
  res <- content(req)
  data.frame(t(unlist(res)))
}
