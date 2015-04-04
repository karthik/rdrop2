options("httr_oauth_cache" = TRUE)

context("Test that basic file ops work correctly") {
    write.csv(mtcars, "mtcars.csv")
    # Check to see if file uploads are successful
    expect_message(drop_upload("mtcars.csv"), "successfully")
    expect_message(drop_delete("mtcars.csv"), "successfully deleted")
    unlink("mtcars.csv")
}
