

#'Returns a link directly to a file.
#'
#'Similar to \code{drop_shared}. The difference is that this bypasses the
#'Dropbox webserver, used to provide a preview of the file, so that you can
#'effectively stream the contents of your media. This URL should not be used to
#'display content directly in the browser. IMPORTANT: The media link will expire
#' after 4 hours. So you'll need to cache the content with knitr cache OR re-run
#' the function call after exipry.
#'@template path
#'@template locale
#' @template token
#'@export
#' @examples \dontrun{
#' drop_media('public/gifs/duck_rabbit.gif')
#'}
drop_media <- function(path = NULL, locale = NULL, dtoken = get_dropbox_token()) {
      assert_that(!is.null(path))
         if(drop_exists(path)) {
       args <- as.list(drop_compact(c(path = path,
                                locale = locale)))
   media_url <- "https://api.dropbox.com/1/media/auto/"
   res <- POST(media_url, query = args, config(token = dtoken), encode = "form")
   pretty_lists(content(res))
} else {
    stop("File not found \n")
    FALSE
}
}
