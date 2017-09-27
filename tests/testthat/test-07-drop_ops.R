# !diagnostics off

library(dplyr)
context("Testing drop copy")
# For now I haven't used traceless to make these tests more readable
# while we work through them

test_that("drop_copy works correctly", {
# # Copying files to files only
# # ------------------------
# We need to start with a clean slate
clean_test_data("iris-test-copy")
cfile_name <- traceless("iris-test-copy.csv")
# Copy a file to a new name
write.csv(iris, cfile_name)
drop_upload(cfile_name)
# Copy to a new name, same folder
cfile_name2 <- traceless("iris-test-copy.csv")
drop_copy(cfile_name, cfile_name2)
exp_2 <- sort(c(cfile_name, cfile_name2))
server_exp_2 <- sort(drop_dir()$name)
cat("\n")
cat(exp_2)
cat("\n")
cat(server_exp_2)
expect_identical(exp_2, server_exp_2)
# Copy to same name, but autorename is TRUE
file_3 <- drop_copy(cfile_name, cfile_name, autorename = TRUE)
# There is a problem here 👇
# num_copy_files3 <- drop_file_count("iris-test-copy")
# expect_equal(num_copy_files3 , 3)
drop_delete(cfile_name2)
drop_delete(file_3$metadata$path_lower)
#
# # # Copying files to folders
# # # ------------------------
drop_create("copy_folder")
drop_copy(cfile_name, "copy_folder")
dc_dir <- drop_dir("copy_folder") %>% dplyr::select(name) %>% dplyr::pull()
expect_identical(dc_dir, cfile_name)
drop_delete(cfile_name)
#
# # Copying folders to existing folders
# # ------------------------
drop_create("copy_folder_2")
drop_copy("copy_folder", "copy_folder_2")
copy_folder_2_contents <- drop_dir("copy_folder_2/copy_folder") %>% dplyr::select(name) %>% dplyr::pull()
expect_identical(copy_folder_2_contents, cfile_name)
drop_delete("copy_folder_2")
#
# # Copying files to new folders
# # ------------------------
drop_copy("copy_folder", "kerfuffle")
d1 <- drop_dir("copy_folder") %>% dplyr::select(name) %>% dplyr::pull() %>% sort
d2 <- drop_dir("kerfuffle") %>% dplyr::select(name) %>% dplyr::pull() %>% sort
expect_identical(d1, d2)
drop_delete("kerfuffle")
drop_delete("copy_folder")
unlink(cfile_name)
unlink(cfile_name2)

})

# --------------------------
# Drop Move
# --------------------------


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

# --------------------------
# Drop Create
# --------------------------

test_that("Drop create works correctly", {
  folder_1 <- traceless("folder_1")
  drop_create(folder_1)
  expect_true(drop_is_folder(folder_1))
  expect_error(drop_create(folder_1))
  drop_create(folder_1, autorename = TRUE)
  folder_duplicate <- paste0(folder_1, " (1)")
  drop_delete(folder_1)
  drop_delete(folder_duplicate)
})

# --------------------------
# Drop Delete
# --------------------------

test_that("Drop delete works correctly", {
  file_name <- traceless("delete.csv")
  write.csv(iris, file = file_name)
  drop_upload(file_name)
  expect_equal(drop_file_count("delete.csv"), 1)
  drop_delete(file_name)
  expect_equal(drop_file_count("delete.csv"), 0)
  fake_file <- traceless("delete.csv")
  # Fails
  expect_error(drop_delete(fake_file))
  unlink(file_name)
})

# --------------------------
# Drop Exists
# --------------------------

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

# --------------------------
# Drop Misc
# --------------------------

# Nothing here yet, but we should test the misc functions
# a the bottom of the helper files.


