context("Testing drop copy")
# For now I haven't used traceless to make these tests more readable
# while we work through them

expect_that("drop_copy works correctly", {
# Copying files to files only
# ------------------------
# Copy a file to a new name
write.csv(iris, "iris.csv")
drop_upload("iris.csv")
expect_equal(nrow(drop_dir()), 1)
# Copy to a new name, same folder
drop_copy("iris.csv", "iris2.csv")
expect_equal(nrow(drop_dir()), 2)
exp_2 <- c("iris2.csv", "iris.csv" )
server_exp_2 <- drop_dir() %>% dplyr::select(name) %>% pull
expect_identical(exp_2, server_exp_2)
# Copy to same name, but autorename is TRUE
drop_copy('iris.csv', "iris.csv", autorename = TRUE)
expect_equal(nrow(drop_dir()), 3)
exp_3 <- c("iris2.csv", "iris.csv", "iris (1).csv")
server_exp_3 <- drop_dir() %>% dplyr::select(name) %>% pull
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
d1 <- drop_dir("copy_folder")  %>% dplyr::select(name) %>% pull
d2 <- drop_dir("kerfuffle")  %>% dplyr::select(name) %>% pull
expect_identical(d1, d2)

drop_delete("kerfuffle")
drop_delete("copy_folder")
drop_delete("copy_folder_2")
drop_delete("iris.csv")
drop_delete("iris2.csv")
})

# TODO
# We need to traceless() these files and folders
# For now, I just wanted to keep them readable