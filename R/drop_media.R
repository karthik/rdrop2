

#'Returns a link directly to a file.
#'
#'Similar to \code{drop_shared}. The difference is that this bypasses the
#'Dropbox webserver, used to provide a preview of the file, so that you can
#'effectively stream the contents of your media. This URL should not be used to
#'display content directly in the browser. IMPORTANT: The media link will expire
#' after 4 hours. So you'll need to cache the content with knitr cache OR re-run
#' the function call after expiry.
#'@template path
#' @template token
#'@export
#' @references \href{https://www.dropbox.com/developers/documentation/http/documentation#files-get_temporary_link}{API documentation}
#' @examples \dontrun{
#' drop_media('Public/gifs/duck_rabbit.gif')
#'}
drop_media <- function(path = NULL, dtoken = get_dropbox_token()) {
  assertive::assert_is_not_null(path)
  if (drop_exists(path)) {
    api_get_temporary_link(add_slashes(path), dtoken)
  } else {
    stop("File not found \n")
    FALSE
  }
}


#' API wrapper for files/get_temporary_link
#'
#' @noRd
#'
#' @keywords internal
api_get_temporary_link <- function(path, dtoken) {

  post_api(
    "https://api.dropbox.com/2/files/get_temporary_link",
    dtoken,
    path
  )
}
