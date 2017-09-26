context("testing drop_dir")

test_that("drop_dir lists files normally", {
  skip_on_cran()

  # create folders and objects
  folder_name <- traceless("test-drop_dir")
  drop_create(folder_name)

  file_name <- traceless("test-drop_dir.csv")
  write.csv(mtcars, file_name)
  drop_upload(file_name, path = folder_name)

  # list contents
  results <- drop_dir(folder_name)

  expect_is(results, "tbl_df")
  expect_equal(nrow(results), 1)

  # add more things
  subfolder_name <- paste0(folder_name, "/", traceless("test-drop_subdir"))
  drop_create(subfolder_name)

  subfile_name <- traceless("test-drop-subfile.csv")
  write.csv(iris, subfile_name)
  drop_upload(subfile_name, path = subfolder_name)

  results <- drop_dir(folder_name)
  expect_equal(nrow(results), 2)

  results <- drop_dir(folder_name, recursive = TRUE)
  expect_equal(nrow(results), 4) # also returns entry for folder_name

  # cleanup
  unlink(file_name)
  unlink(subfile_name)
  drop_delete(folder_name)
})


test_that("drop_dir can detect changes in directory", {
  skip_on_cran()

  # create a folder
  folder_name <- traceless("drop_dir")
  drop_create(folder_name)

  # put a file in it
  file_name <- traceless("drop_dir.csv")
  write.csv(mtcars, file_name)
  drop_upload(file_name, paste0(folder_name, "/", file_name))

  # get a cursor
  cursor <- drop_dir(folder_name, cursor = TRUE)
  expect_is(cursor, "character")

  # add another file
  file_name2 <- traceless("drop_dir.csv")
  write.csv(iris, file_name2)
  drop_upload(file_name2, paste0(folder_name, "/", file_name2))

  # check for contents since cursor
  entries <- drop_dir(cursor = cursor)
  expect_is(entries, "tbl_df")
  expect_equal(nrow(entries), 1)
  expect_equal(entries$name[1], file_name2)

  # check whole folder
  entries <- drop_dir(folder_name)
  expect_is(entries, "tbl_df")
  expect_equal(nrow(entries), 2)
  expect_equal(entries$name, c(file_name, file_name2))

  # cleanup
  drop_delete(folder_name)
  unlink(file_name)
  unlink(file_name2)
})
