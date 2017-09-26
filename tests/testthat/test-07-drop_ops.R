# !diagnostics off

context("Testing drop copy")
# For now I haven't used traceless to make these tests more readable
# while we work through them

expect_that("drop_copy works correctly", {
# Copying files to files only
# ------------------------
# We need to start with a clean slate
expect_equal(nrow(drop_dir()), 0)
# Copy a file to a new name
write.csv(iris, "iris.csv")
drop_upload("iris.csv")
expect_equal(nrow(drop_dir()), 1)
# Copy to a new name, same folder
drop_copy("iris.csv", "iris2.csv")
expect_equal(nrow(drop_dir()), 2)
exp_2 <- sort(c("iris2.csv", "iris.csv" ))
server_exp_2 <- drop_dir() %>% dplyr::select(name) %>% pull %>% sort
expect_identical(exp_2, server_exp_2)
# Copy to same name, but autorename is TRUE
drop_copy('iris.csv', "iris.csv", autorename = TRUE)
expect_equal(nrow(drop_dir()), 3)
exp_3 <- sort(c("iris2.csv", "iris.csv", "iris (1).csv"))
server_exp_3 <- drop_dir() %>% dplyr::select(name) %>% pull %>% sort
expect_identical(exp_3, server_exp_3)

# Copying files to folders
# ------------------------
drop_create("copy_folder")
drop_copy("iris.csv", "copy_folder")
dc_dir <-  drop_dir("copy_folder") %>% dplyr::select(name) %>% pull
expect_equal(dc_dir, "iris.csv")

# Copying folders to existing folders
# ------------------------
drop_create("copy_folder_2")
drop_copy("copy_folder", "copy_folder_2")
copy_folder_2_contents <- drop_dir("copy_folder_2/copy_folder") %>% dplyr::select(name) %>% pull
expect_equal(copy_folder_2_contents, "iris.csv")

# Copying files to new folders
# ------------------------
drop_copy("copy_folder", "kerfuffle")
d1 <- drop_dir("copy_folder")  %>% dplyr::select(name) %>% pull %>% sort
d2 <- drop_dir("kerfuffle")  %>% dplyr::select(name) %>% pull %>% sort
expect_identical(d1, d2)

drop_delete("kerfuffle")
drop_delete("copy_folder")
drop_delete("copy_folder_2")
drop_delete("iris.csv")
drop_delete("iris2.csv")
drop_delete("iris (1).csv")
})

# TODO
# We need to traceless() these files and folders
# For now, I just wanted to keep them readable

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
  expect_equal(nrow(drop_dir()), 1)
  drop_delete(file_name)
  expect_equal(nrow(drop_dir()), 0)
  fake_file <- traceless("delete.csv")
  # Fails
  expect_error(drop_delete(fake_file))
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



