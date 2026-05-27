
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
  assertthat::assert_that(!is.null(path))

  if(drop_exists(path)) {
    media_url <- "https://api.dropbox.com/2/files/get_temporary_link"
    path <- add_slashes(path)
    drop_request(media_url, dtoken, body = list(path = path))
  } else {
    cli::cli_abort("File not found")
  }
}


#' Retrieve a thumbnail for an image file on Dropbox.
#'
#' Downloads a JPEG or PNG thumbnail for a photo or video stored in Dropbox.
#' Supported formats: jpg, png, tiff, tif, gif, webp, ppm, bmp.
#'
#' @param path        Path to the image file on Dropbox.
#' @param local_path  Local path to save the thumbnail. If \code{NULL}
#'   (default), a temporary file is created and its path is returned.
#' @param format      Thumbnail format: \code{"jpeg"} (default) or \code{"png"}.
#' @param size        Thumbnail size preset. One of \code{"w32h32"},
#'   \code{"w64h64"}, \code{"w128h128"}, \code{"w256h256"} (default),
#'   \code{"w480h320"}, \code{"w640h480"}, \code{"w960h640"},
#'   \code{"w1024h768"}, \code{"w2048h1536"}.
#' @param overwrite   If \code{TRUE}, overwrite an existing local file.
#'   Defaults to \code{FALSE}.
#' @template token
#'
#' @return Path to the saved thumbnail file, invisibly.
#'
#' @references \href{https://www.dropbox.com/developers/documentation/http/documentation#files-get_thumbnail_v2}{API documentation}
#'
#' @export
#'
#' @examples \dontrun{
#'   thumb_path <- drop_get_thumbnail("photos/vacation.jpg")
#'   # display in R (requires the 'magick' package)
#'   # magick::image_read(thumb_path)
#' }
drop_get_thumbnail <- function(path,
                                local_path = NULL,
                                format = "jpeg",
                                size = "w256h256",
                                overwrite = FALSE,
                                dtoken = get_dropbox_token()) {

  valid_formats <- c("jpeg", "png")
  valid_sizes   <- c("w32h32", "w64h64", "w128h128", "w256h256",
                     "w480h320", "w640h480", "w960h640",
                     "w1024h768", "w2048h1536")
  assertthat::assert_that(format %in% valid_formats)
  assertthat::assert_that(size   %in% valid_sizes)

  if (!grepl("^(id|rev):", path)) path <- add_slashes(path)

  if (is.null(local_path)) {
    local_path <- tempfile(fileext = paste0(".", format))
  }

  if (file.exists(local_path) && !overwrite) {
    cli::cli_abort(
      "Local file {.file {local_path}} already exists. Set {.code overwrite = TRUE} to replace it."
    )
  }

  url <- "https://content.dropboxapi.com/2/files/get_thumbnail_v2"

  arg_json <- jsonlite::toJSON(
    list(
      resource = list(
        ".tag" = "path",
        path   = path
      ),
      format  = list(".tag" = format),
      size    = list(".tag" = size)
    ),
    auto_unbox = TRUE
  )

  req <- httr2::request(url)
  req <- httr2::req_auth_bearer_token(req, resolve_token(dtoken))
  req <- httr2::req_headers(req, `Dropbox-API-Arg` = arg_json)
  req <- httr2::req_body_raw(req, "", type = "application/octet-stream")
  httr2::req_perform(req, path = local_path)

  invisible(local_path)
}
