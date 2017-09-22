context("Testing drop_upload")
library(dplyr)
sprintf("Number of files on Dropbox", nrow(drop_dir()))


# Test a basic file upload
# -------------------------
test_that("Test that basic file ops work correctly", {
  skip_on_cran()

  # This is a simple test to see if we can upload a csv file successfully

  file_name <- paste0(uuid::UUIDgenerate(), "-file-ops-", ".csv")
  write.csv(mtcars, file_name)
  row_count <- nrow(mtcars)
  print(file_name)
  # Check to see if file uploads are successful
  expect_message(drop_upload(file_name), "successfully at")
  unlink(file_name)
  drop_get(file_name)
  y <- utils::read.csv(file_name)
  server_row_count <- nrow(y)
  # Make sure the downloaded csv has the same number of rows
  expect_equal(row_count, server_row_count)
  expect_message(drop_delete(file_name), "successfully deleted")
  unlink(file_name)
})

# Test upload of an image
# ------------------------

test_that("Image upload works correctly", {
  skip_on_cran()
  # This test is to see if we can upload an image (a png in this case) and make sure that it maintains file integrity.
  # We compare hashes of local file, then the roundtrip copy.

  download.file("https://www.dropbox.com/s/k61p0mvapf285cf/business_card.png?dl=0",
                destfile = "drop-test-business.png")
  local_file_hash <- digest::digest("drop-test-business.png")
  # expect_equal(file.info("drop-test-business.png")$size, 227000, tolerance = 500)
  drop_upload("drop-test-business.png")
  unlink("drop-test-business.png")
  drop_get("drop-test-business.png")
  roundtrip_file_hash <-  digest::digest("drop-test-business.png")
  expect_equal(local_file_hash, roundtrip_file_hash)
  drop_delete("/drop-test-business.png")
  unlink("drop-test-business.png")
})

# Test upload of a non existent file
# ----------------------------------

test_that("Upload of a non-existent file fails", {
  expect_error(drop_upload("higgledy-piggledy.csv"))
  expect_error(drop_upload("higgledy-piggledy.csv", mode = "stuff"))
})

# Test autorename
# ------------------
test_that("Autorename upload works correctly", {
drop_create("add_overwrite_test")
blank <- drop_dir("add_overwrite_test")
expect_equal(nrow(blank), 0)
write.csv(iris, file = "iris.csv")
drop_upload("iris.csv", path = "add_overwrite_test")
one_file <- drop_dir("add_overwrite_test")
expect_equal(nrow(one_file), 1)
expect_identical(one_file[1,]$path, "/add_overwrite_test/iris.csv")
# Write a slightly different object to the same filename
write.csv(iris[1:6, ], file = "iris.csv")
drop_upload("iris.csv", path = "add_overwrite_test", mode = "add")
two_files <- drop_dir("add_overwrite_test")
expect_equal(nrow(two_files), 2)
# This is what I should expect
expected_files <-
  c("/add_overwrite_test/iris (1).csv",
    "/add_overwrite_test/iris.csv")
expect_identical(two_files$path, expected_files)
write.csv(iris[1:5, ], file = "iris.csv")
drop_upload("iris.csv", path = "add_overwrite_test", mode = "add")
three_files <- drop_dir("add_overwrite_test")
e_3files <-
  c(
    "/add_overwrite_test/iris (1).csv",
    "/add_overwrite_test/iris (2).csv",
    "/add_overwrite_test/iris.csv"
  )
expect_identical(three_files$path, e_3files)
drop_delete("add_overwrite_test")
unlink("iris.csv")
})

