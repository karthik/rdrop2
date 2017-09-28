# rdrop2 - Dropbox interface from R  ![a_box](drop_thumbnail.png)  



[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)
 [![Build Status](https://travis-ci.org/karthik/rdrop2.svg)](https://travis-ci.org/karthik/rdrop2)  [![Coverage Status](https://coveralls.io./repos/karthik/rdrop2/badge.svg)](https://coveralls.io/r/karthik/rdrop2) [![](http://cranlogs.r-pkg.org/badges/rdrop2)](http://cran.rstudio.com/web/packages/rdrop2/index.html)  [![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/rdrop2)](http://cran.r-project.org/web/packages/rdrop2) [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.998912.svg)](https://doi.org/10.5281/zenodo.998912)

__Maintainers:__ Karthik Ram (@karthik) and Clayton Yochum (@ClaytonJY)


This package provides programmatic access to Dropbox from R. The functions in this package provide access to a full suite of file operations, including dir/copy/move/delete operations, account information and the ability to upload and download files from any Dropbox account.  


### Installation  

**Important:** The Dropbox API migrates to V2 on September 28th, 2017. After that date, `0.7.0` and lower versions (ones currently on CRAN) of this package will no longer work. You will need to install `0.8` or above from GitHub till this newer version becomes available on CRAN.

```
devtools::install_github("karthik/rdrop2")
```

### Authentication

```r
library(rdrop2)
drop_auth()
# This will launch your browser and request access to your Dropbox account. You will be prompted to log in if you aren't already logged in.
# Once completed, close your browser window and return to R to complete authentication. 
# The credentials are automatically cached (you can prevent this) for future use.

# If you wish to save the tokens, for local/remote use

token <- drop_auth()
saveRDS(token, file = "token.rds")

# Then in any drop_* function, pass `dtoken = token
# Tokens are valid until revoked.

```

#### Retrieve Dropbox account information

```r
library(dplyr)
drop_acc() %>% data.frame()
# Returns the following fields
# [1] "account_id"            "name.given_name"      
#  [3] "name.surname"          "name.familiar_name"   
#  [5] "name.display_name"     "name.abbreviated_name"
#  [7] "email"                 "email_verified"       
#  [9] "disabled"              "country"              
# [11] "locale"                "referral_link"        
# [13] "is_paired"             ".tag"        
```

#### Dropbox directory listing

```r
write.csv(mtcars, "mtcars.csv")
drop_upload("mtcars.csv")
drop_dir()
# If your account is not empty, it returns the following fields
#  [1] ".tag"            "name"            "path_lower"     
#  [4] "path_display"    "id"              "client_modified"
#  [7] "server_modified" "rev"             "size"           
# [10] "content_hash"   
#
# 
# or specify a path
drop_dir('public/gifs')
```

|.tag |name       |path_lower  |path_display |id                        |client_modified      |server_modified      |rev          | size|content_hash                                                     |
|:----|:----------|:-----------|:------------|:-------------------------|:--------------------|:--------------------|:------------|----:|:----------------------------------------------------------------|
|file |mtcars.csv |/mtcars.csv |/mtcars.csv  |id:b-ac9BwzYUAAAAAAAAAxFQ |2017-09-27T16:21:56Z |2017-09-27T16:21:57Z |691634207848 | 1783|8c00dcec5f3e6bf58a42dcf354f0d5199a43567e88a9d80291bd2b85f53a54a5 |

#### Filter directory listing by object type (file/folder)

```r
drop_dir() %>% 
    filter(.tag == "folder")
```

#### Create folders on Dropbox


```r
drop_create('drop_test')
# or provide the full path where it needs to be created
drop_create('public/drop_test')
```

#### Upload a file into Dropbox

__csv files__  
```r
write.csv(mtcars, 'mtcars.csv')
drop_upload('mtcars.csv')
# or upload to a specific folder
drop_upload('mtcars.csv', dest = "drop_test")
```

You can also do this for any other file type and large files are supported regardless of your memory.


#### Download a file

```r
drop_download('mtcars.csv')
# or add path if file is not in root
drop_download("test_folder/mtcars.csv")
```

#### Delete a file

```r
drop_delete('mtcars.csv')
```

#### Move files

```r
drop_create("new_folder")
drop_move("mtcars.csv", "new_folder/mtcars.csv")
```

__Copy files__

```r
drop_create("new_folder2")
drop_copy("new_folder/mtcars.csv", "new_folder2/mtcars.csv")
```


#### Search and download files

I frequently use a duck season rabbit season gif. This is how I could search and download from my public Dropbox account. 

```r
x <- drop_search("rabbit")
drop_download(x$matches[[1]]$metadata$path_lower, local_path = '~/Desktop/bugs.gif')

# Downloaded /public/gifs/duck_rabbit.gif to ~/Desktop/bugs.gif: 329.2 Kb on disk
```

####  Read csv files directly from Dropbox

```r
write.csv(iris, file = "iris.csv")
drop_upload("iris.csv")
# Now let's read this back into an R session
# Note that there is a quiet download happening to your temp dir
new_iris <- drop_read_csv("iris.csv")
```

#### Accessing Dropbox on Shiny and remote servers

If you expect to access a Dropbox account via Shiny or on a remote cluster, EC2, Digital Ocean etc, you can leave the cached `oauth` file in the same directory, or pass the `token` explicitly to `drop_auth`. You can also save the output of `drop_auth` into an R object, sink that to disk, and pass that as a token. If using on Travis or similar, you should consider [encrypting the oauth cache file](http://docs.travis-ci.com/user/encrypting-files/) to prevent unauthorized access to your Dropbox account. If you have multiple tokens and accounts, it is also possible to override the environment token and explicitly pass a specific token for each `drop_` function.

```r
token <- drop_auth()
saveRDS(token, "droptoken.rds")
# Upload droptoken to your server
# ******** WARNING ********
# Losing this file will give anyone 
# complete control of your Dropbox account
# You can then revoke the rdrop2 app from your
# dropbox account and start over.
# ******** WARNING ********
# read it back with readRDS
token <- readRDS("droptoken.rds")
# Then pass the token to each drop_ function
drop_acc(dtoken = token)
```


__Meta__

* Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.

* For bug reports and known problems, please look over the [issues](https://github.com/karthik/rdrop2/issues) before filing a new report.
