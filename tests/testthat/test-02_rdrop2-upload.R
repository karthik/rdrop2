# !diagnostics off
context("Testing drop_upload")

# Test a basic file upload
# -------------------------
test_that("Test that basic file ops work correctly", {
  skip_on_cran()

  # This is a simple test to see if we can upload a csv file successfully

  file_name <- traceless("file-ops.csv")

  write.csv(mtcars, file_name)
  row_count <- nrow(mtcars)
  print(file_name)
  # Check to see if file uploads are successful
  expect_message(drop_upload(file_name), "successfully at")
  unlink(file_name)
  drop_download(file_name)
  y <- utils::read.csv(file_name)
  server_row_count <- nrow(y)
  # Make sure the downloaded csv has the same number of rows
  expect_equal(row_count, server_row_count)
  # expect_message(drop_delete(file_name), "successfully deleted")
  unlink(file_name)
  drop_delete(file_name)
})

# Test upload of an image
# ------------------------

test_that("Image upload works correctly", {
  skip_on_cran()
  # This test is to see if we can upload an image (a png in this case) and make sure that it maintains file integrity.
  # We compare hashes of local file, then the roundtrip copy.
  dest <- traceless("rdrop2_package_test_drop.png")
  download.file("https://www.dropbox.com/s/k61p0mvapf285cf/business_card.png?dl=0",
                destfile = dest)
  local_file_hash <- digest::digest(dest)
  drop_upload(dest)
  unlink(dest)
  drop_download(dest)
  roundtrip_file_hash <-  digest::digest(dest)
  expect_equal(local_file_hash, roundtrip_file_hash)
  drop_delete(dest)
  unlink(dest)
})

# Test upload of a non existent file
# ----------------------------------

test_that("Upload of a non-existent file fails", {
  skip_on_cran()

  expect_error(drop_upload("higgledy-piggledy.csv"))
  expect_error(drop_upload("higgledy-piggledy.csv", mode = "stuff"))
})

# Test autorename
# ------------------
test_that("Autorename upload works correctly", {
  skip_on_cran()

  autorename_folder <- traceless("autorename_test")
  drop_create(autorename_folder)
  blank <- drop_dir(autorename_folder)
  expect_equal(nrow(blank), 0)
  write.csv(iris, file = "iris.csv")
  drop_upload("iris.csv", path = autorename_folder)
  one_file <- drop_dir(autorename_folder)
  expect_equal(nrow(one_file), 1)
  expect_identical(one_file[1,]$path_lower, paste0("/", autorename_folder, "/iris.csv"))
  # Write a slightly different object to the same filename
  write.csv(iris[1:6, ], file = "iris.csv")
  drop_upload("iris.csv", path = autorename_folder, mode = "add")
  two_files <- drop_dir(autorename_folder)
  expect_equal(nrow(two_files), 2)
  # This is what I should expect
  expected_files <-
    c(paste0("/", autorename_folder, "/iris.csv"),
      paste0("/", autorename_folder, "/iris (1).csv"))
  expect_identical(two_files$path_lower, expected_files)
  write.csv(iris[1:5, ], file = "iris.csv")
  drop_upload("iris.csv", path = autorename_folder, mode = "add")
  three_files <- drop_dir(autorename_folder)
  e_3files <-
    c(
      paste0("/", autorename_folder, "/iris.csv"),
      paste0("/", autorename_folder,"/iris (1).csv"),
      paste0("/", autorename_folder,"/iris (2).csv")
    )
  expect_identical(three_files$path_lower, e_3files)
  drop_delete(autorename_folder)
  unlink("iris.csv")
})

