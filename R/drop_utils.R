#' Pipe operator
#'
#' @name %>%
#' @rdname pipe
#' @keywords internal
#' @export
#' @importFrom magrittr %>%
#' @usage lhs \%>\% rhs
NULL


#' A local version of list compact from plyr.
#' @noRd
drop_compact <- function(l) Filter(Negate(is.null), l)


#' A small function to strip trailing slashes from a path
#' @noRd
strip_slashes <- function(path) {
  if (length(path) && grepl("/$", path)) {
    path <- substr(path, 1, nchar(path) - 1)
  }
  # Also remove leading slashes
  if (length(path) && grepl("^/", path)) {
    path <- substr(path, 2, nchar(path))
  }

  path
}

#' A small function to add a prefix slash
#' @noRd
add_slashes <- function(path) {
  if (length(path) && !grepl("^/", path)) {
    path <- paste0("/", path)
  }
  path
}

#' Internal helper: build, perform, and parse a standard JSON Dropbox API call.
#'
#' Constructs an httr2 request with bearer-token authentication, an optional
#' JSON body, and performs it.  HTTP errors are raised automatically by httr2.
#'
#' @param url    Full Dropbox API endpoint URL.
#' @param token  ****** token string (from \code{get_dropbox_token()}).
#' @param body   Named list to serialise as the JSON request body, or
#'               \code{NULL} for a body-less POST (some Dropbox endpoints
#'               require an empty body POST).
#'
#' @return Parsed JSON response as a named R list.
#'
#' Extract the bearer token string from a token argument.
#'
#' Accepts either a plain character string (as returned by
#' \code{get_dropbox_token}) or an \code{httr2_token} / list object (as
#' returned by \code{drop_auth}) and always returns the access-token string.
#'
#' @noRd
resolve_token <- function(token) {
  if (is.character(token)) return(token)
  if (is.list(token) && !is.null(token$access_token)) return(token$access_token)
  cli::cli_abort("Invalid token: supply the output of {.fn drop_auth} or {.fn get_dropbox_token}.")
}

drop_request <- function(url, token, body = NULL) {
  req <- httr2::request(url)
  req <- httr2::req_auth_bearer_token(req, resolve_token(token))
  if (!is.null(body)) {
    req <- httr2::req_body_json(req, body)
  } else {
    # Dropbox expects POST; send empty body
    req <- httr2::req_body_raw(req, "", type = "application/json")
  }
  resp <- httr2::req_perform(req)
  httr2::resp_body_json(resp)
}

#' @noRd
# This is an internal function to linearize lists
# Source: https://gist.github.com/mrdwab/4205477
# Author page (currently unreachable):  https://sites.google.com/site/akhilsbehl/geekspace/articles/r/linearize_nested_lists_in
# Original Author: Akhil S Bhel
# Notes: Current author could not be reached and original site () appears defunct. Copyright remains with original author
LinearizeNestedList <- function(NList, LinearizeDataFrames = FALSE,
                                NameSep = "/", ForceNames = FALSE) {

  if (!is.list(NList) || length(NList) == 0) return(NList)

  stack <- vector("list", length(NList))
  for (i in seq_along(NList)) {
    nm <- if (!is.null(names(NList)) && !ForceNames) names(NList)[i] else as.character(i)
    stack[[i]] <- list(value = NList[[i]], prefix = nm)
  }

  result <- list()

  while (length(stack) > 0) {
    item   <- stack[[1]]
    stack  <- stack[-1]
    val    <- item$value
    prefix <- item$prefix

    is_df  <- is.data.frame(val)
    is_lst <- is.list(val) && (!is_df || LinearizeDataFrames)

    if (is_lst && length(val) > 0) {
      children <- vector("list", length(val))
      for (i in seq_along(val)) {
        nm <- if (!is.null(names(val)) && !ForceNames) names(val)[i] else as.character(i)
        children[[i]] <- list(value = val[[i]], prefix = paste(prefix, nm, sep = NameSep))
      }
      stack <- c(children, stack)
    } else {
      # Convert empty lists to NA before storing
      result[[prefix]] <- if (is.list(val) && length(val) == 0) NA else val
    }
  }

  result
}

#' A pretty list printer. Reduces extraneous space.
#' @noRd
pretty_lists <- function(x)
{
  # assertive::assert_is_list(x)
  assertthat::assert_that(is.list(x))

  for(key in names(x)){
    value <- format(x[[key]])
    if(value == "") next
    cat(key, "=", value, "\n")
  }
  invisible(x)
}


#' @noRd
release_questions <- function() {
  c("For the love of God did I add skip_on_cran?")
}


#' A small function to strip trailing slashes from a path
#' @noRd
strip_slashes <- function(path) {
  if (length(path) && grepl("/$", path)) {
    path <- substr(path, 1, nchar(path) - 1)
  }
  # Also remove leading slashes
  if (length(path) && grepl("^/", path)) {
    path <- substr(path, 2, nchar(path))
  }

  path
}

#' A small function to add a prefix slash
#' @noRd
add_slashes <- function(path) {
  if (length(path) && !grepl("^/", path)) {
    path <- paste0("/", path)
  }
  path
}

#' A pretty list printer. Reduces extraneous space.
#' @noRd
pretty_lists <- function(x)
{
  # assertive::assert_is_list(x)
  assertthat::assert_that(is.list(x))

  for(key in names(x)){
    value <- format(x[[key]])
    if(value == "") next
    cat(key, "=", value, "\n")
  }
  invisible(x)
}


#' @noRd
release_questions <- function() {
  c("For the love of God did I add skip_on_cran?")
}
