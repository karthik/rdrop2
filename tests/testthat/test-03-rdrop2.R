
# These are the remaining tests after auth and upload.If the tests are getting
# to be more than 30 lines, split them off into a separate file. Execution order
# is is all of the `helper-*.R` files and then all of the `test-*.R` files

context("File ops")
# --------------------------------------

# drop_dir
# ......................................
context("Directory listing works ok")
test_that("drop_dir returns data correctly", {
  skip_on_cran()

  file1 <- paste0(uuid::UUIDgenerate(), ".csv")
  file2 <- paste0(uuid::UUIDgenerate(), ".csv")
  file3 <- paste0(uuid::UUIDgenerate(), ".csv")
  write.csv(iris, file1)
  write.csv(iris, file2)
  write.csv(iris, file3)

  filenames <- c(file1, file2, file3)
  # add a leading slash
  filenames_slash <- paste0("/", filenames)
  drop_create(path = "testingdirectories")
  drop_upload(file1, "testingdirectories")
  drop_upload(file2, "testingdirectories")
  drop_upload(file3, "testingdirectories")
  dir_listing <- drop_dir("testingdirectories")
  # Now test that it has nrow 3
  expect_equal(nrow(dir_listing), 3)
  expect_identical(sort(basename(dir_listing$path)), sort(basename(filenames_slash)))
  drop_delete("testingdirectories")
  sapply(filenames, unlink)
})


# All the file ops (move/copy/delete)
# drop_get, drop_upload
# ......................................
context("drop_get")


test_that("Drop_get work correctly", {
  skip_on_cran()
  download.file("http://media4.giphy.com/media/YaXcVXGvBQlEI/200.gif",
                destfile = "duck_rabbit.gif")
  drop_upload("duck_rabbit.gif")
  drop_get("duck_rabbit.gif", overwrite = TRUE)
  expect_true("duck_rabbit.gif" %in% dir())
  file.remove("duck_rabbit.gif")
  drop_delete("duck_rabbit.gif")
})

# drop_copy
# ......................................
test_that("Copying files works correctly", {
  skip_on_cran()
  file_name <- paste0(uuid::UUIDgenerate(), ".csv")
  write.csv(iris, file = file_name)
  drop_upload(file_name)
  drop_create("copy_test")
  # Try a duplicate create. This should fail
  expect_error(drop_create("copy_test"))
  drop_upload(file_name)
  drop_copy(file_name, paste0("/copy_test/", file_name))
  res <- drop_dir("copy_test")
  expect_identical(basename(file_name), basename(res$path))
  drop_delete("copy_test")
  unlink(file_name)
})

# drop_move
# ......................................
test_that("Moving files works correctly", {
  skip_on_cran()
  file_name <- paste0(uuid::UUIDgenerate(), ".csv")
  write.csv(iris, file = file_name)
  drop_upload(file_name)
  drop_create("move_test")
  drop_move(file_name, paste0("/move_test/", file_name))
  res <- drop_dir("move_test")
  # problem
  expect_identical(basename(file_name), basename(res$path))
  # Now test that the file is there.
  # do a search for the path/file
  # the make sure it exists
  # ......................................
  drop_delete("/move_test")
  unlink(file_name)
})

# drop_shared
# ......................................
context("testing drop share")
test_that("Sharing a Dropbox resource works correctly", {
  skip_on_cran()
  file_name <- paste0(uuid::UUIDgenerate(), ".csv")
  write.csv(iris, file = file_name)
  drop_upload(file_name)
  res <- drop_share(file_name)
  expect_equal(length(res), 3)
  share_names <- sort(c("url", "expires", "visibility"))
  res_names <- sort(names(res))
  expect_identical(share_names, res_names)
  unlink(file_name)
  drop_delete(file_name)
  # Make sure the $url starts with http://
})



# drop_search
# ......................................

context("testing search")
test_that("Search works correctly", {
  skip_on_cran()

  download.file("http://media4.giphy.com/media/YaXcVXGvBQlEI/200.gif",
                destfile = "duck_rabbit.gif")
  drop_upload("duck_rabbit.gif")
  my_gifs <- drop_search('gif')
  expect_is(my_gifs, "data.frame")
  expect_true("/duck_rabbit.gif" %in% my_gifs$path)
  unlink("duck_rabbit.gif")
  drop_delete("/duck_rabbit.gif")
})


# drop_history

context("testing dropbox revisions")

test_that("Revisions are returned correctly", {
  skip_on_cran()

  write.csv(iris, file = "iris.csv")
  drop_upload("iris.csv")
  write.csv(iris[iris$Species == "setosa",], file = "iris.csv")
  drop_upload("iris.csv")
  x <- drop_history("iris.csv")
  expect_equal(ncol(x), 15)
  expect_is(x, "data.frame")
  drop_delete("/iris.csv")
  unlink("iris.csv")
})

# drop_exists

context("testing Dropbox exists")
test_that("We can verify that a file exists on Dropbox", {
  skip_on_cran()

  drop_create("existential_test")
  expect_true(drop_exists("existential_test"))
  expect_false(drop_exists(paste0(uuid::UUIDgenerate(), uuid::UUIDgenerate(), ".csv")))
  # Now test files inside subfolders
  write.csv(iris, file = "iris.csv")
  drop_upload("iris.csv", path = "existential_test")
  expect_true(drop_exists("existential_test/iris.csv"))
  drop_delete("existential_test")

})


# drop_media
context("Testing Media URLs")

test_that("Media URLs work correctly", {
  skip_on_cran()
  download.file("http://media4.giphy.com/media/YaXcVXGvBQlEI/200.gif",
                destfile = "duck_rabbit.gif")
  drop_upload("duck_rabbit.gif")
  media_url <- drop_media("duck_rabbit.gif")
  expect_match(media_url$link, "https://dl.dropboxusercontent.com")
  unlink("duck_rabbit.gif")
  drop_delete("duck_rabbit.gif")
})


context("Testing drop_read_csv")

test_that("Can read csv files directly from dropbox", {
  skip_on_cran()

  file_name <- paste0(uuid::UUIDgenerate(), ".csv")
  write.csv(iris, file = file_name)
  drop_upload(file_name)
  z <- drop_read_csv(file_name)
  expect_is(z, "data.frame")
  unlink(file_name)
  drop_delete(file_name)
})
# No stray files to this point

context("Drop delta works")

test_that("Drop delta works", {
  skip_on_cran()

  file_name <- paste0(uuid::UUIDgenerate(), ".csv")
  write.csv(iris, file = file_name)
  z <- drop_delta(path_prefix = "/")
  expected_names <- c("has_more", "cursor", "entries", "reset")
  expect_identical(names(z), expected_names)
  unlink(file_name)
})

context("drop exists")

test_that("Drop exists works", {
  skip_on_cran()
  drop_create("existential_test")
  expect_true(drop_exists("existential_test"))
  drop_delete("existential_test")
})
