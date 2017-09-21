

#'Returns a link directly to a file.
#'
#'Similar to \code{drop_shared}. The difference is that this bypasses the
#'Dropbox webserver, used to provide a preview of the file, so that you can
#'effectively stream the contents of your media. This URL should not be used to
#'display content directly in the browser. IMPORTANT: The media link will expire
#' after 4 hours. So you'll need to cache the content with knitr cache OR re-run
#' the function call after exipry.
#'@template path
#' @template token
#'@export
#' @examples \dontrun{
#' drop_media('Public/gifs/duck_rabbit.gif')
#'}
drop_media <- function(path = NULL, dtoken = get_dropbox_token()) {
  assert_that(!is.null(path))
  if(drop_exists(path)) {
    media_url <- "https://api.dropbox.com/2/files/get_temporary_link"
    path <- paste0("/",path)
    res <- POST(media_url, body = list(path = path), httr::config(token = dtoken), encode = "json")
    content(res)
  } else {
    stop("File not found \n")
    FALSE
  }
}
