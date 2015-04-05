#' Computes mime type from file extension.
#'
#' @param path path to file
#' @keywords internal
#' @return mime string
drop_mime <- function(path) {
  ext <- strsplit(path, ".", fixed = TRUE)[[1L]]
  n <- length(ext)

  if (n == 0) return()

  types <- c(
    "csv" = "text/csv",
    "css" = "text/css",
    "png" = "image/png",
    "tiff", "image/tiff",
    "gif" = "image/gif",
    "js" = "text/javascript",
    "jpeg" = "image/jpeg",
    "jpg" = "image/jpeg",
    "html" = "text/html",
    "ico" = "image/x-icon",
    "pdf" = "application/pdf",
    "eps" = "application/postscript",
    "ps" = "application/postscript",
    "sgml"= "text/sgml",
    "xml" = "text/xml",
    "text/plain"
  )

  unname(types[ext[n]])
}
