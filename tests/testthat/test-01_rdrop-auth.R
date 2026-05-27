context("authorization")
test_that("Able to authenticate from saved RDS token", {
  skip_on_cran()

  # read cached token and check it has an access_token field
  token <- drop_auth(rdstoken = "token.rds")
  expect_true(!is.null(token$access_token))
  expect_is(token, "httr2_token")
})


# drop_acc
# ......................................

context("Testing that acc info works correctly")

test_that("Account information works correctly", {
  skip_on_cran()

  acc_info <- drop_acc()
  # expect list
  expect_is(acc_info, "list")
  # name element should be its own list
  expect_is(acc_info$name, "list")
})
