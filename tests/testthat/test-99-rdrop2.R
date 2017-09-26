# These are the remaining tests after auth and upload.If the tests are getting
# to be more than 30 lines, split them off into a separate file. Execution order
# is is all of the `helper-*.R` files and then all of the `test-*.R` files

context("old tests")

# drop_copy
test_that("Copying files works correctly", {
  skip_on_cran()

  file_name <- traceless("copy.csv")
  folder_name <- traceless("drop_copy")
  write.csv(iris, file = file_name)
  drop_upload(file_name)
  drop_create(folder_name)

  # Try a duplicate create. This should fail
  expect_error(drop_create(folder_name))
  drop_upload(file_name)
  drop_copy(file_name, paste0("/",folder_name, "/", file_name))

  res <- drop_dir(folder_name)
  expect_identical(basename(file_name), basename(res$path_lower))

  # cleanup
  drop_delete(folder_name)
  unlink(file_name)
  drop_delete(file_name)
})


# drop_move
test_that("Moving files works correctly", {
  skip_on_cran()

  file_name <- traceless("move.csv")
  write.csv(iris, file = file_name)
  drop_upload(file_name)

  mtest <- traceless("move_test")
  drop_create(mtest)
  drop_move(file_name, paste0("/", mtest, "/", file_name))
  res <- drop_dir(mtest)
  # problem
  expect_identical(basename(file_name), basename(res$path_lower))
  # Now test that the file is there.
  # do a search for the path/file
  # the make sure it exists

  # cleanup
  drop_delete(mtest)
  unlink(file_name)
})


# drop_shared
test_that("drop_share works correctly", {
  skip_on_cran()

  file_name <- traceless("share.csv")
  write.csv(iris, file = file_name)
  drop_upload(file_name)
  res <- drop_share(file_name)
  expect_equal(length(res), 10)
  share_names <- sort(c(".tag", "url", "id", "name", "path_lower", "link_permissions",
                        "client_modified", "server_modified", "rev", "size"))
  res_names <- sort(names(res))
  expect_identical(share_names, res_names)

  # cleanup
  unlink(file_name)
  drop_delete(file_name)
})


# drop_search
test_that("drop_search works correctly", {
  skip_on_cran()

  folder_name <- traceless("test-drop_search")
    #paste0("test-drop_search-", uuid::UUIDgenerate())
  drop_create(folder_name)

  write.csv(mtcars, "mtcars.csv")
  drop_upload("mtcars.csv", path = folder_name)

  x <- drop_search("mt")

  expect_equal(x$matches[[1]]$metadata$name, "mtcars.csv")

  # A search with no query should fail
  expect_error(drop_search())

  #cleanup
  drop_delete(folder_name)
  unlink("mtcars.csv")
})


# drop_history
test_that("drop_history works correctly", {
  skip_on_cran()

  # upload once
  file_name <- traceless("drop_history_iris.csv")
  write.csv(iris, file_name)
  drop_upload(file_name)

  revisions <- drop_history(file_name)

  expect_is(revisions, "tbl_df")
  expect_equal(nrow(revisions), 1)

  # delete, edit, upload again
  # TODO: add proper revision once drop_upload supports it
  drop_delete(file_name)
  write.csv(iris[iris$Species == "setosa",], file_name)
  drop_upload(file_name)

  revisions <- drop_history(file_name)
  expect_equal(nrow(revisions), 2)

  # test limit arguments
  revisions <- drop_history(file_name, limit = 1)
  expect_equal(nrow(revisions), 1)

  # cleanup
  drop_delete(file_name)
  unlink(file_name)
})


# drop_exists
test_that("drop_exists works correctly", {
  skip_on_cran()

  folder_name <- traceless("drop_exists")
  drop_create(folder_name)

  expect_true(drop_exists(folder_name))
  expect_false(drop_exists(traceless("stuffnthings")))

  # Now test files inside subfolders
  write.csv(iris, file = "iris.csv")
  drop_upload("iris.csv", path = folder_name)
  expect_true(drop_exists(paste0(folder_name, "/iris.csv")))

  #cleanup
  drop_delete(folder_name)
  unlink("iris.csv")
})


# drop_media
test_that("drop_media works correctly", {
  skip_on_cran()

  file_name <- traceless("drop_media")
  download.file("http://media4.giphy.com/media/YaXcVXGvBQlEI/200.gif",
                destfile = file_name)
  drop_upload(file_name)

  media_url <- drop_media(file_name)
  expect_match(media_url$link, "https://dl.dropboxusercontent.com")

  # cleanup
  unlink(file_name)
  drop_delete(file_name)
})


# drop_read_csv
test_that("drop_read_csv works correctly", {
  skip_on_cran()

  file_name <- traceless("drop_read.csv")
  write.csv(iris, file = file_name)
  drop_upload(file_name)
  z <- drop_read_csv(file_name)
  expect_is(z, "data.frame")

  # cleanup
  unlink(file_name)
  drop_delete(file_name)
})


# drop_delta
test_that("drop_delta works correctly", {
  skip_on_cran()

  file_name <- traceless("drop-delta.csv")
  write.csv(iris, file = file_name)
  z <- drop_delta(path_prefix = "/")
  expected_names <- c("has_more", "cursor", "entries", "reset")
  expect_identical(names(z), expected_names)

  # unlink
  unlink(file_name)
})
