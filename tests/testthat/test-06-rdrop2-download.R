context("testing drop_download")

test_that("drop_download works as expected", {
  skip_on_cran()

  # create and upload a file for testing
  file_name <- paste0("test-drop_download-", uuid::UUIDgenerate(), ".csv")
  write.csv(mtcars, file_name)
  drop_upload(file_name)

  # download to same path
  unlink(file_name)
  expect_identical(
    drop_download(file_name),
    file_name
  )

  # download to a new path
  new_path <- paste0("test-drop_download-", uuid::UUIDgenerate(), ".csv")
  expect_identical(
    drop_download(file_name, new_path),
    new_path
  )

  # dowload to an implied path
  new_dir <- paste0("test-drop_download-", uuid::UUIDgenerate())
  dir.create(new_dir)
  implied_path <- file.path(new_dir, file_name)
  expect_identical(
    drop_download(file_name, new_dir),
    implied_path
  )

  # cleanup
  unlink(file_name)
  unlink(new_path)
  unlink(new_dir, recursive = TRUE)
  drop_delete(file_name)
})

test_that("drop_get works, but is deprecated", {
  skip_on_cran()

  # create and upload a file for testing, then delete locally
  file_name <- paste0("test-drop_download-", uuid::UUIDgenerate(), ".csv")
  write.csv(mtcars, file_name)
  drop_upload(file_name)
  unlink(file_name)

  # check for deprecation warning
  expect_warning(
    drop_get(file_name),
    "is deprecated"
  )

  # make sure the file was downloaded
  expect_true(file.exists(file_name))

  # cleanup
  unlink(file_name)
  drop_delete(file_name)
})
