

#' Use this function to clean out your Dropbox in case there are stray files left over from a failed test.
clean_dropbox <- function(x = "" , dtoken = get_dropbox_token()) {
  if(x != "y") {
  x <-
    readline(
      "WARNING: this will delete everything in your Dropbox account.  \n Do not do this unless this is a test account. Are you sure?? (y/n)"
    )
  }
  if (x == "y") {
    files <- drop_dir()
    suppressWarnings(sapply(files$path_lower, drop_delete))
  }
}


#' Function makes file/folder names unique to prevent race conditions during concurrent tests. Pun on race condition
traceless <- function(file) {
  paste0("rdrop2_package_test_", uuid::UUIDgenerate(), "_", file)
}


# This should clean out any remaining/old test files and folders
clean_test_data <- function(dtoken = get_dropbox_token()) {
files <- drop_search("rdrop2_package_test_")
sapply(files$path_lower, drop_delete)
}
