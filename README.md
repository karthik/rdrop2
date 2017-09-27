# rdrop2 - Dropbox interface from R  ![a_box](drop_thumbnail.png)  


[![Build Status](https://travis-ci.org/karthik/rdrop2.svg)](https://travis-ci.org/karthik/rdrop2)  [![Coverage Status](https://coveralls.io./repos/karthik/rdrop2/badge.svg)](https://coveralls.io/r/karthik/rdrop2) [![](http://cranlogs.r-pkg.org/badges/rdrop2)](http://cran.rstudio.com/web/packages/rdrop2/index.html)  [![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/rdrop2)](http://cran.r-project.org/web/packages/rdrop2)



This package provides programmatic access to Dropbox from R. The functions in this package provide access to a full suite of file operations, including dir/copy/move/delete operations, account information (including quotas) and the ability to upload and download files from any Dropbox account.  


__Installation__  

**Important:** The Dropbox API migrates to V2 on September 28th, 2017. After that date, `0.7.0` and lower versions (ones currently on CRAN) of this package will no longer work. You will need to install `0.8` or above from GitHub till this newer version becomes available on CRAN.

```
devtools::install_github("karthik/rdrop2")
```

__Authentication__

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
drop_acc() %>% 
    select(uid, display_name, email_verified, quota_info.quota)
```

#### Dropbox directory listing

```r
drop_dir()
# or specify a path
drop_dir('public/gifs')
```

#### Filter directory listing by filetype (e.g. png files)

```r
drop_dir() %>% 
    filter(mime_type == "image/png")
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
drop_get('mtcars.csv')
# or add path if file is not in root
drop_get("test_folder/mtcars.csv")
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

#### Search your Dropbox

```r
foo <- drop_search('gif')
dim(foo)
# Yes I know I hoard gifs.
# This isn't even the entire lot.
# [1] 751  14
tail(foo)
Source: local data frame [6 x 14]
```

```r
# rev thumb_exists path is_dir
# 1  1b206e7f519 TRUE # /obscure_path/bgnoise.gif  FALSE
# 2  1d906e7f519 TRUE # /obscure_path/images/ploslogo.gif  FALSE
# 3  1da06e7f519 TRUE # /obscure_path/images/treebase_logo.gif  FALSE
# 4  1db06e7f519 TRUE # /obscure_path/images/fishbaselogo.gif  FALSE
# Variables not shown: client_mtime (chr), icon (chr), read_only (lgl), bytes (# int), modified (chr), size (chr), root (chr), mime_type
#  (chr), revision (int), parent_shared_folder_id (chr)
```

#### Search and download files

I frequently use a duck season rabbit season gif. This is how I could search and download from my public Dropbox account. 

```r
x <- drop_search("rabbit")
drop_get(x$path, local_file = '~/Desktop/bugs.gif')

# Response [https://api-content.dropbox.com/1/files/auto//Public/gifs/duck_rabbit.gif]
#   Date: 2015-04-04 15:34
#   Status: 200
#   Content-Type: image/gif
#   Size: 337 kB
# <ON DISK>  ~/Desktop/bugs.gif
```

#### Share links

```r
gifs <- drop_search("rabbit")
drop_share(gifs$path)
# url = https://db.tt/PnNKg99G 
# expires = Tue, 01 Jan 2030 00:00:00 +0000 
# visibility = PUBLIC 
```
The shared URL resolves here https://www.dropbox.com/s/aikiaug0x2013dp/duck_rabbit.gif?dl=0

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
