
#' Get a list of Deltas
#' @param cursor The last cursor
#' @template locale
#' @param path_prefix The path to subset
#' @param include_media_info Set to \code{TRUE}
#' @template token
#' @export
#' @examples \dontrun{
#' z <- drop_delta(path_prefix = "/Public")
#' # If no files have changed during this time, entries will be NULL
#' drop_delta(cursor = z$cursor, path_prefix = "/Public")
#' }
drop_delta <- function(cursor = NULL,
					   locale = NULL,
					   path_prefix = NULL,
					   include_media_info = NULL,
					   dtoken = get_dropbox_token()) {
	delta_url <- "https://api.dropbox.com/1/delta"
	     args <- as.list(drop_compact(c(cursor = cursor,
                                    locale = locale,
                                    include_media_info = include_media_info,
                                    path_prefix = path_prefix)))
	x <- POST(delta_url, config(token = dtoken), query = args, encode = "form")
	 res <- content(x)
	 df <- lapply(res$entries, function(z) data.frame(t(unlist(z))))
	 df <- data.table::rbindlist(df, fill = TRUE)
	 res$entries <- df
	 res
}
