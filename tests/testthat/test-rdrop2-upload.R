context("Testing drop_upload")
library(dplyr)
sprintf("Number of files on Dropbox", nrow(drop_dir()))


# Test a basic file upload
# -------------------------
test_that("Test that basic file ops work correctly", {
  skip_on_cran()
  file_name <- paste0(uuid::UUIDgenerate(), ".csv")
  write.csv(mtcars, file_name)
  print(file_name)
  # Check to see if file uploads are successful
  expect_message(drop_upload(file_name), "successfully at")
  expect_message(drop_delete(file_name), "successfully deleted")
  unlink(file_name)
})

# Test upload of an image
# ------------------------

test_that("Image upload works correctly", {
  skip_on_cran()
  download.file("https://www.dropbox.com/s/k61p0mvapf285cf/business_card.png?dl=0",
                destfile = "drop-test-business.png")
  expect_gt(file.info("drop-test-business.png")$size, 227000)
  drop_upload("drop-test-business.png")
  x <- drop_dir()
  server_size <- x[x$path == "/drop-test-business.png",]$bytes
  expect_gt(server_size, 227000)
  drop_delete("/drop-test-business.png")
  unlink("drop-test-business.png")
})

# Test upload of a non existent file
# ----------------------------------


# Test autorename
# ------------------

# Test write modes
# ------------------

# Test file integrity
# ------------------
