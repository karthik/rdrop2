context("Testing drop_get_metadata")

test_that("Able to retrieve metadata for file in multiple ways", {

  # upload
  file_name <- paste0(uuid::UUIDgenerate(), "-file-ops-", ".csv")
  write.csv(mtcars, file_name)
  drop_upload(file_name)

  file_path <- rdrop2:::add_slashes(file_name)

  # lookup by path
  metadata <- drop_get_metadata(file_path)

  expect_is(metadata, "list")
  expect_equal(metadata$.tag, "file")

  # lookup by id
  expect_identical(metadata, drop_get_metadata(metadata$id))

  # lookup by revision
  expect_identical(metadata, drop_get_metadata(paste0("rev:", metadata$rev)))

  # delete
  drop_delete(file_path)

  # get deleted metadata
  deleted_metadata <- drop_get_metadata(file_path, include_deleted = TRUE)

  expect_is(deleted_metadata, "list")
  expect_equal(deleted_metadata$.tag, "deleted")
  expect_identical(
    metadata[c("name", "path_lower", "path_display")],
    deleted_metadata[c("name", "path_lower", "path_display")]
  )

  # cleanup
  unlink(file_name)
})
