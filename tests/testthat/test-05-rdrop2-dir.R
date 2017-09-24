context("testing drop_dir")

test_that("drop_dir works as expected", {
  skip_on_cran()

  # create folders and objects
  folder_name <- paste0("test-drop_dir-", uuid::UUIDgenerate())
  drop_create(folder_name)

  file_name <- paste0("test-drop_dir-", uuid::UUIDgenerate(), ".csv")
  write.csv(mtcars, file_name)
  drop_upload(file_name, path = folder_name)

  # list contents
  results <- drop_dir(folder_name)

  expect_is(results, "tbl_df")
  expect_equal(nrow(results), 1)

  # add more things
  subfolder_name <- paste0(folder_name, "/", "test-drop_dir-", uuid::UUIDgenerate())
  drop_create(subfolder_name)

  subfile_name <- paste0("test-drop_dir-", uuid::UUIDgenerate(), ".csv")
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
