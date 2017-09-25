

#' Use this function to clean out your Dropbox in case there are stray files left over from a failed test.
clean_dropbox <- function(dtoken = get_dropbox_token()) {
  x <-
    readline(
      "WARNING: this will delete everything in your Dropbox account. Do not do this unless this is a test account. Are you sure?? (y/n)"
    )
  if (x == "y") {
    files <- drop_dir()
    sapply(files$path_lower, drop_delete)
  }
}
