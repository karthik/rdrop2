

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
clean_test_data <- function(pattern = "rdrop2_package_test", dtoken = get_dropbox_token()) {
  files <- drop_dir()

  if (nrow(files) > 0) {
    filenames <- files[["name"]]

    matching_files <- grep(pattern, filenames, value = TRUE)

    if (length(matching_files)) {
      suppressWarnings(purrr::walk(matching_files, drop_delete))
    }
  }
}

# Counts files matching a pattern
drop_file_count <- function(x, dtoken = get_dropbox_token()) {
  y <- drop_dir()
  if(nrow(y) > 0) {
    z <- grepl(x, y$name)
    sum(z, na.rm = TRUE)
    } else {
      0
    }
}
