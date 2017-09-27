

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
clean_test_data <- function(pattern = "rdrop_package_test", dtoken = get_dropbox_token()) {
  x <- drop_dir() 
  if(nrow(x) > 0) {
  x1 <- x %>% dplyr::select(name) %>% pull
  matching_files <- x1[grepl(pattern, x1)]
  if(length(matching_files)) {
  suppressWarnings(sapply(matching_files, drop_delete))
}
}
}

# Counts files matching a pattern
drop_file_count <- function(x, dtoken = get_dropbox_token()) {
  y <- drop_dir()
  z <- grepl(x, y$name)
  sum(z, na.rm = TRUE)
}
