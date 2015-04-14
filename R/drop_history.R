

#'Obtains metadata for all available revisions of a file, including the current
#'revision.
#'
#'Only revisions up to thirty days old are available (or more if the Dropbox
#'user has Extended Version History). You can use the revision number in
#'conjunction with the /restore call to revert the file to its previous state.
#'@template path
#'@template token
#'@export
#' @examples \dontrun{
#' write.csv(iris, file = "iris.csv")
#' drop_upload("iris.csv")
#' write.csv(iris[iris$Species == "setosa", ], file = "iris.csv")
#' drop_upload("iris.csv")
#' drop_history("iris.csv")
#'}
drop_history <- function(path = NULL, dtoken = get_dropbox_token()) {
    rev_url <- "https://api.dropbox.com/1/revisions/auto/"
    assert_that(!is.null(path))
    rev_url <- paste0(rev_url, strip_slashes(path))
    res <- httr::GET(rev_url, , config(token = dtoken))
    httr::stop_for_status(res)
    results <- httr::content(res)
    res_df <- lapply(results, function(x) data.frame(t(unlist(x)), stringsAsFactors = FALSE))
    data.table::rbindlist(res_df, fill = TRUE)
}




