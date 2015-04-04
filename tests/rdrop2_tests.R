options("httr_oauth_cache" = TRUE)

context("Testing that acc info works correctly")
test_that("Account information works correctly", {
expect_is("data.frame", drop_acc())
expect_is("list", drop_acc(verbose = TRUE))
})


context("File ops")

test_that("Test that basic file ops work correctly",{
    write.csv(mtcars, "mtcars.csv")
    # Check to see if file uploads are successful
    expect_message(drop_upload("mtcars.csv"), "successfully")
    expect_message(drop_delete("mtcars.csv"), "successfully deleted")
    unlink("mtcars.csv")
})
