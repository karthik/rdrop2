context("drop_exists")

test_that("title case", {

  test_path <- traceless("Test Drop Exists")

  expect_message(
    drop_create(test_path),
    "created successfully")

  expect_true(
    drop_exists(test_path))

  drop_delete(test_path)

})

test_that("case insensitivity", {

  test_path <- traceless("Test Drop Exists")

  expect_message(
    drop_create(test_path),
    "created successfully")

  expect_true(
    drop_exists(
      tolower(test_path)))

  expect_true(
    drop_exists(
      toupper(test_path)))

  drop_delete(test_path)

})
