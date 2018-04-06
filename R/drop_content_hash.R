#' Compute a "content hash" using the same algorithm as dropbox.  This
#' can be used to verify the content against the \code{content_hash}
#' field returned in \code{\link{drop_dir}}.
#'
#' Dropbox returns a hash of file contents in \code{\link{drop_dir}}.
#' However, this is not a straightforward file hash.  Instead the file
#' is divided into 4MB chunks, each of those is hashed and then the
#' concatenation of the hashes is itself hashed (see
#' \href{https://www.dropbox.com/developers/reference/content-hash}{this
#' page} in the dropbox developer documentation for the details).
#' It's entirely unclear why it does not compute a hash of the file
#' itself, but here we are.
#'
#' @title Compute Dropbox's content hash for one or more files
#'
#' @param file A vector of filenames
#'
#' @return A character vector the same length as \code{file}.  Each
#'   element is 64 character string which is the unique hash.  Two
#'   files that have the same hash have the same contents.  Compare
#'   this hash of a local file with the \code{content_hash} field from
#'   \code{\link{drop_dir}} to see if you have the same file as
#'   dropbox.
#'
#' @export
#' @examples
#' \dontrun{
#' write.csv(mtcars, file = "mtt.csv")
#' drop_upload("mtt.csv")
#' files <- drop_dir()
#' # Dropbox's reported hash
#' files$content_hash[files$name == "mtt.csv"]
#' # Our computed hash:
#' drop_content_hash("mtt.csv")
#' }
drop_content_hash <- function(file) {
  if (!is.character(file)) {
    stop("Expected 'file' to be a character vector")
  }
  if (length(file) != 1L) {
    return(vapply(file, drop_content_hash, character(1), USE.NAMES = FALSE))
  }

  con <- file(file, "rb")
  on.exit(close(con))

  block_size <- 4L * 1024L * 1024L

  n <- ceiling(file.size(file) / block_size)
  h <- vector("list", n)
  for (i in seq_len(n)) {
    bytes <- readBin(con, raw(1), block_size)
    h[[i]] <- sha256(bytes, raw = TRUE)
  }

  sha256(unlist(h))
}

sha256 <- function(bytes, raw = FALSE) {
  digest::digest(bytes, algo = "sha256", serialize = FALSE, raw = raw)
}
