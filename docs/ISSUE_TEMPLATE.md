Please start your issue with a brief description of the problem.

Then, fill out as much as you can below, excluding parts you're not sure of or which don't apply. We'd rather know about an issue than not, so don't worry if you can't answer everything.

The rest of this applies functional issues (code); remove it for other problems, like issues about documentation.

Provide code to reproduce the issue. This will usually need to involve code to create and upload one or more files/folders. Below is an example you can edit.

```r
library(rdrop2)

drop_auth()

# create & upload some file
write.csv(mtcars, "mtcars.csv")
drop_upload("mtcars.csv")

# the problem call
drop_something("mtcars.csv")
```


## Expected Behaviour

What did you expect to happen from the above code?


## Actual Behaviour

What happened instead?


## Account Type

Are you using Dropbox Basic, Dropbox Pro, or Dropbox for Business?


## Session Info

Replace the output below (inside the backticks) with output from `devtools::session_info()` (or `sessionInfo()` if you don't have `devtools` installed)

<details><pre>

```r
> devtools::session_info()
Session info -----------------------------------------------------------------------
 setting  value
 version  R version 3.4.1 (2017-06-30)
 system   x86_64, linux-gnu
 ui       RStudio (1.0.153)
 language (EN)
 collate  en_US.UTF-8
 tz       America/New_York
 date     2017-10-01

Packages ---------------------------------------------------------------------------
 package   * version date       source
 base      * 3.4.2   2017-09-29 local
 compiler    3.4.2   2017-09-29 local
 datasets  * 3.4.2   2017-09-29 local
 devtools    1.13.3  2017-08-02 CRAN (R 3.4.1)
 digest      0.6.12  2017-01-27 CRAN (R 3.4.0)
 graphics  * 3.4.2   2017-09-29 local
 grDevices * 3.4.2   2017-09-29 local
 memoise     1.1.0   2017-04-21 CRAN (R 3.4.0)
 methods   * 3.4.2   2017-09-29 local
 stats     * 3.4.2   2017-09-29 local
 tools       3.4.2   2017-09-29 local
 utils     * 3.4.2   2017-09-29 local
 withr       2.0.0   2017-07-28 cran (@2.0.0)
```

</pre></details>
