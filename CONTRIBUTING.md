
# Contributing to rdrop2

* Before filing an issue, make sure it's not already on the queue or something listed for a future milestone.
*  Also be sure to check known issues at the bottom of the `README`.
*  If you have a feature update or fix to contribute, fork the repo and send a pull request with detailed enough notes so I can quickly understand what you have added. 
*  NOTE: Travis checks will likely not pass on a PR because credentials to one of my (rarely used) Dropbox accounts are encrypted in the tests folder and [only decrypted for builds under my own account](http://docs.travis-ci.com/user/pull-requests/#Security-Restrictions-when-testing-Pull-Requests). So when you submit PRs, I'll have to test locally. You are also encouraged to do the same but don't commit your `.httr-oauth` file into the repository.
