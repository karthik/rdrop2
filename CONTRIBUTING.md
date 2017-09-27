
# Contributing to rdrop2


* Before filing an issue, make sure it's not already on the queue or something listed for a future milestone. Please be sure to include package version (`packageVersion("rdrop2")` or your `devtools::session_info()` output) in your issue report.
*  If you have a feature update or fix to contribute, fork the repo and send a pull request with detailed enough notes so we can quickly understand what you have added. 

⚠ __IMPORTANT INFORMATION REGARDING TESTING__ ⚠ 

- Travis checks will likely pass on your pull request because the credentials are only decrypted on Travis for the maintainers (@karthik, @ClaytonJY). 

- Before sending a PR, make sure tests pass for you locally. To test:

```r
# first authenticate into your own account
token <- drop_auth(new_user = TRUE)
saveRDS(token, "tests/testthat/token.rds")
# Now run the tests as usual
```

Since `token.rds` is git ignored (as is `.httr-oauth`) your credentials will NOT end up on this repository. But you must have tests pass (and make a note of that) when you PR. A maintainer will checkout your request, make sure everything passes, and following comments, re-trigger Travis before merging.


