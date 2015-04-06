options("httr_oauth_cache" = TRUE)

context("Testing that acc info works correctly")
test_that("Account information works correctly", {
skip_on_cran()
library(dplyr)
expect_is(drop_acc(), "data.frame")
expect_is(drop_acc(verbose = TRUE), "list")
acc_info <- drop_acc()
identical("Karthik Ram", as.character(acc_info$display_name))
})


context("File ops")

test_that("Test that basic file ops work correctly",{
    skip_on_cran()
    write.csv(mtcars, "mtcars.csv")
    # Check to see if file uploads are successful
    expect_message(drop_upload("mtcars.csv"), "successfully")
    expect_message(drop_delete("mtcars.csv"), "successfully deleted")
    unlink("mtcars.csv")
})

context("testing search")

test_that("Search works correctly", {
    skip_on_cran()
    library(dplyr)
    my_gifs <- drop_search('gif')
    expect_is(my_gifs, "tbl_df")
})
