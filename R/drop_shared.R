

#' Creates and returns a shared link to a file or folder.
#'
#' @template path
#' @template locale
#' @param  short_url By default the function return shortened URL. Set to \code{FALSE} if you require a full path.
#' @template token
#' @export
#' @examples \dontrun{
#' write.csv(mtcars, file = "mt.csv")
#' drop_upload("mt.csv")
#' drop_share("mt.csv")
#'}
drop_share <- function(path = NULL, locale = NULL, short_url = TRUE, dtoken = get_dropbox_token()) {
   args <- as.list(drop_compact(c(path = path,
                                locale = locale,
                                short_url = short_url))) 
   share_url <- "https://api.dropbox.com/1/shares/auto/"
   res <- GET(share_url, query = args, config(token = dtoken))
   results <- content(res)
   results
}