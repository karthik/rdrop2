# Chunk size for session-based uploads (150 MB)
.UPLOAD_CHUNK_SIZE <- 150L * 1024L * 1024L
# Files larger than this threshold use the session-based chunked upload
.UPLOAD_THRESHOLD  <- 150L * 1024L * 1024L


#' Uploads a file to Dropbox.
#'
#' This function will allow you to write files of any size to Dropbox. Files
#' larger than 150 MB are automatically uploaded in chunks using the Dropbox
#' upload session API.
#'
#' @param file Relative path to local file.
#' @param path The relative path on Dropbox where the file should get uploaded.
#' @param mode Upload mode: \code{"overwrite"} (default) will always overwrite
#'   an existing file; \code{"add"} will not overwrite and instead create a
#'   renamed copy on conflict; \code{"update"} requires a \code{rev} argument.
#' @param autorename If \code{TRUE} (default), the file being uploaded will be
#'   automatically renamed to avoid conflicts when using \code{mode = "add"}.
#' @param mute Set to \code{TRUE} to suppress desktop/mobile notifications.
#'   Defaults to \code{FALSE}.
#' @template verbose
#' @template token
#'
#' @return Dropbox file metadata list, invisibly.
#'
#' @references \href{https://www.dropbox.com/developers/documentation/http/documentation#files-upload}{API documentation}
#' @export
#'
#' @examples \dontrun{
#' write.csv(mtcars, file = "mtt.csv")
#' drop_upload("mtt.csv")
#'}
drop_upload <- function(file,
                        path = NULL,
                        mode = "overwrite",
                        autorename = TRUE,
                        mute = FALSE,
                        verbose = FALSE,
                        dtoken = get_dropbox_token()) {

  assertthat::assert_that(file.exists(file))

  standard_modes <- c("overwrite", "add", "update")
  assertthat::assert_that(mode %in% standard_modes)

  # Dropbox API requires a / before an object name.
  if (is.null(path)) {
    dest_path <- add_slashes(basename(file))
  } else {
    dest_path <- paste0("/", strip_slashes(path), "/", basename(file))
  }

  file_size <- file.size(file)

  if (file_size <= .UPLOAD_THRESHOLD) {
    response <- .upload_small(file, dest_path, mode, autorename, mute, dtoken)
  } else {
    response <- .upload_chunked(file, dest_path, mode, autorename, mute, dtoken)
  }

  if (verbose) {
    pretty_lists(response)
    invisible(response)
  } else {
    invisible(response)
    cli::cli_alert_success(
      "File {.file {file}} uploaded as {response$path_display} successfully at {response$server_modified}"
    )
  }
}


#' Single-request upload for files <= 150 MB.
#' @noRd
.upload_small <- function(file, dest_path, mode, autorename, mute, dtoken) {

  put_url <- "https://content.dropboxapi.com/2/files/upload"

  arg_json <- jsonlite::toJSON(
    list(
      path       = dest_path,
      mode       = mode,
      autorename = autorename,
      mute       = mute
    ),
    auto_unbox = TRUE
  )

  req <- httr2::request(put_url)
  req <- httr2::req_auth_bearer_token(req, resolve_token(dtoken))
  req <- httr2::req_headers(req, `Dropbox-API-Arg` = arg_json)
  req <- httr2::req_body_file(req, file, type = "application/octet-stream")
  resp <- httr2::req_perform(req)
  httr2::resp_body_json(resp)
}


#' Session-based chunked upload for files > 150 MB.
#'
#' Uses the three-step upload session API:
#'   1. \code{upload_session/start}   – open a session
#'   2. \code{upload_session/append_v2} – upload all but the last chunk
#'   3. \code{upload_session/finish}  – upload last chunk and commit
#'
#' @noRd
.upload_chunked <- function(file, dest_path, mode, autorename, mute, dtoken) {

  start_url  <- "https://content.dropboxapi.com/2/files/upload_session/start"
  append_url <- "https://content.dropboxapi.com/2/files/upload_session/append_v2"
  finish_url <- "https://content.dropboxapi.com/2/files/upload_session/finish"

  file_size  <- file.size(file)
  con        <- file(file, "rb")
  on.exit(close(con), add = TRUE)

  offset     <- 0L

  # ---- step 1: start session with first chunk ----
  first_chunk <- readBin(con, raw(), .UPLOAD_CHUNK_SIZE)
  offset      <- length(first_chunk)

  start_arg <- jsonlite::toJSON(list(close = FALSE), auto_unbox = TRUE)
  req <- httr2::request(start_url)
  req <- httr2::req_auth_bearer_token(req, resolve_token(dtoken))
  req <- httr2::req_headers(req, `Dropbox-API-Arg` = start_arg)
  req <- httr2::req_body_raw(req, first_chunk, type = "application/octet-stream")
  resp <- httr2::req_perform(req)
  session_id <- httr2::resp_body_json(resp)$session_id

  # ---- step 2: append middle chunks ----
  while (offset + .UPLOAD_CHUNK_SIZE < file_size) {
    chunk <- readBin(con, raw(), .UPLOAD_CHUNK_SIZE)
    if (length(chunk) == 0L) break

    append_arg <- jsonlite::toJSON(
      list(cursor = list(session_id = session_id,
                         offset     = offset),
           close  = FALSE),
      auto_unbox = TRUE
    )
    req <- httr2::request(append_url)
    req <- httr2::req_auth_bearer_token(req, resolve_token(dtoken))
    req <- httr2::req_headers(req, `Dropbox-API-Arg` = append_arg)
    req <- httr2::req_body_raw(req, chunk, type = "application/octet-stream")
    httr2::req_perform(req)
    offset <- offset + length(chunk)
  }

  # ---- step 3: finish with the last chunk ----
  last_chunk  <- readBin(con, raw(), .UPLOAD_CHUNK_SIZE)

  finish_arg <- jsonlite::toJSON(
    list(
      cursor = list(session_id = session_id,
                    offset     = offset),
      commit = list(
        path       = dest_path,
        mode       = mode,
        autorename = autorename,
        mute       = mute
      )
    ),
    auto_unbox = TRUE
  )
  req <- httr2::request(finish_url)
  req <- httr2::req_auth_bearer_token(req, resolve_token(dtoken))
  req <- httr2::req_headers(req, `Dropbox-API-Arg` = finish_arg)
  req <- httr2::req_body_raw(req, last_chunk, type = "application/octet-stream")
  resp <- httr2::req_perform(req)
  httr2::resp_body_json(resp)
}


#' Save a remote URL directly to Dropbox.
#'
#' Instructs Dropbox to download a file from the given URL and save it to your
#' Dropbox without you needing to download it locally first.  Useful for
#' automated pipelines that source data from the web.
#'
#' @param path   Destination path in Dropbox (including filename).
#' @param url    The URL of the file to download into Dropbox.
#' @param poll   If \code{TRUE} (default), block until the save operation
#'   completes and return the saved file metadata.  If \code{FALSE}, return
#'   immediately with the async job ID.
#' @param interval Polling interval in seconds when \code{poll = TRUE}.
#'   Default \code{2}.
#' @template token
#'
#' @return If \code{poll = TRUE}, a file metadata list for the saved file.
#'   If \code{poll = FALSE}, a list with \code{async_job_id} (or the completed
#'   metadata if the server finished synchronously).
#'
#' @references \href{https://www.dropbox.com/developers/documentation/http/documentation#files-save_url}{API documentation}
#'
#' @export
#'
#' @examples \dontrun{
#'   drop_save_url(
#'     path = "/data/penguins.csv",
#'     url  = "https://raw.githubusercontent.com/allisonhorst/palmerpenguins/main/inst/extdata/penguins.csv"
#'   )
#' }
drop_save_url <- function(path, url, poll = TRUE, interval = 2,
                          dtoken = get_dropbox_token()) {

  save_url   <- "https://api.dropboxapi.com/2/files/save_url"
  check_url  <- "https://api.dropboxapi.com/2/files/save_url/check_job_status"

  path <- add_slashes(path)

  res <- drop_request(save_url, dtoken,
                      body = list(path = path, url = url))

  # Dropbox may return immediately with 'complete' or give an async job id
  if (!is.null(res[[".tag"]]) && res[[".tag"]] == "complete") {
    return(res)
  }
  if (!poll) return(res)

  # Poll until done
  async_job_id <- res$async_job_id
  if (is.null(async_job_id)) return(res)

  repeat {
    Sys.sleep(interval)
    status <- drop_request(check_url, dtoken,
                           body = list(async_job_id = async_job_id))
    tag <- status[[".tag"]]
    if (!is.null(tag) && tag == "complete") return(status)
    if (!is.null(tag) && tag == "failed")   cli::cli_abort("save_url job failed: {status$failed}")
    # in_progress: keep polling
  }
}
