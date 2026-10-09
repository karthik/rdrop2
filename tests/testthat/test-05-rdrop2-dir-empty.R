context("empty directory metadata")

test_that("list linearization accepts empty branches at any depth", {
  expect_equal(LinearizeNestedList(list()), list())
  expect_equal(LinearizeNestedList(list(empty = list())), list())
  expect_equal(
    LinearizeNestedList(list(outer = list(inner = list()))),
    list()
  )

  metadata <- list(
    first = list(),
    name = "example.csv",
    sharing_info = list(empty = list(), shared_folder_id = "123"),
    last = list()
  )
  expect_equal(
    LinearizeNestedList(metadata),
    list(name = "example.csv", "sharing_info/shared_folder_id" = "123")
  )
  expect_equal(
    LinearizeNestedList(metadata, ForceNames = TRUE, NameSep = "."),
    list("2" = "example.csv", "3.2" = "123")
  )
  expect_equal(
    LinearizeNestedList(list(list(), list("value"), list())),
    list("2/1" = "value")
  )
})

# Give a copy of drop_dir a local API stub; never contact Dropbox in these tests.
drop_dir_from_entries <- function(entries) {
  list_directory <- drop_dir
  api <- new.env(parent = environment(drop_dir))
  api$drop_list_folder <- function(...) {
    list(entries = entries, has_more = FALSE)
  }
  environment(list_directory) <- api
  list_directory(dtoken = NULL)
}

test_that("drop_dir keeps entries with empty nested metadata", {
  entries <- list(
    list(
      ".tag" = "file", name = "first.csv", size = 10,
      sharing_info = list(),
      property_groups = list(list(fields = list()))
    ),
    list(
      ".tag" = "file", name = "second.csv", size = 20,
      sharing_info = list(shared_folder_id = "123")
    )
  )
  result <- drop_dir_from_entries(entries)

  expect_is(result, "tbl_df")
  expect_equal(nrow(result), 2L)
  expect_equal(names(result), c(".tag", "name", "size", "sharing_info/shared_folder_id"))
  expect_equal(result$name, c("first.csv", "second.csv"))
  expect_equal(result$size, c(10, 20))
  expect_equal(result[["sharing_info/shared_folder_id"]], c(NA_character_, "123"))
})

test_that("drop_dir returns an empty tibble for an empty directory", {
  result <- drop_dir_from_entries(list())
  expect_is(result, "tbl_df")
  expect_equal(nrow(result), 0L)
})
