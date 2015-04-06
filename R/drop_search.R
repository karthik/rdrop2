

#'Returns metadata for all files and folders whose filename contains the given
#'search string as a substring.
#'
#'@param query  The search string. This string is split (on spaces) into
#'  individual words. Files and folders will be returned if they contain all
#'  words in the search string.
#'@template path
#'@template file_limit
#'@param  include_deleted If this parameter is set to true, then files and
#'  folders that have been deleted will also be included in the search.
#'@template locale
#'@template include_membership
#'@template token
#'@export
#' @examples \dontrun{
#' # If you know me, you know why this query exists
#' drop_search('gif') %>% select(path, is_dir, mime_type)
#'}
drop_search <- function(query = NULL,
                        path = NULL,
                        file_limit = 1000,
                        include_deleted = FALSE,
                        locale = NULL,
                        include_membership = FALSE,
                        dtoken = get_dropbox_token()) {
    args <- as.list(drop_compact(c(query = query,
                                 path = path,
                                 file_limit = file_limit,
                                 include_deleted = include_deleted,
                                 locale = locale,
                                 include_membership = include_membership)))
    search_url <- "https://api.dropbox.com/1/search/auto/"
    res <- GET(search_url, query = args, config(token = dtoken))
    results <- content(res)
    # The search results contain a field called 'modifier' that is NULL
    # by default. This makes it really hard to rbind the list either with
    # dplyr or data.table. So this lapply just kills that field before I
    # can rbind everything into a nice list.
    zz <- lapply(results, function(t) { t$modifier = NULL; t })
    # I hate myself :(
    dplyr::tbl_df(data.table::rbindlist(zz, fill = T))
}


