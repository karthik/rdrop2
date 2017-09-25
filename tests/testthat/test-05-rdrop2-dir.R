context("testing drop_dir")

test_that("drop_dir works as expected", {
  skip_on_cran()

  # create folders and objects
  #1
  # folder_name <- paste0("test-drop_dir-", uuid::UUIDgenerate())
  folder_name <- traceless("test-drop_dir")
  drop_create(folder_name)

  # 2
  file_name <- traceless("test-drop_dir.csv")
  write.csv(mtcars, file_name)
  drop_upload(file_name, path = folder_name)

  # list contents
  results <- drop_dir(folder_name)

  expect_is(results, "tbl_df")
  expect_equal(nrow(results), 1)

  # add more things
  # 3
  subfolder_name <- paste0(folder_name, "/", traceless("test-drop_subdir"))
  drop_create(subfolder_name)

  # 4
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
