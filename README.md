[![Build Status](https://travis-ci.org/karthik/rDrop2.svg)](https://travis-ci.org/ropensci/rDrop2) 


# rDrop2 - Dropbox interface from R  ![](drop.png)  


This package provides programmatic access to Dropbox from R. The package provides a full suite of file operations, including directory listing, copy/move/delete operations, account information and the ability to upload and download files from any Dropbox account. This package replaces the old [rDrop](https://github.com/karthik/rDrop). _Note: This is a new package and functionality will change or get updated over the coming weeks before a stable CRAN release._


__Installation__  

```r
devtools::install_github('karthik/rdrop2')
```

__Basic Usage__

```r
library(rDrop2)
drop_auth()
# This will launch your browser and request access to your Dropbox account. 
# Once completed, close your browser window and return to R to complete authentication.
```

__Account information__

```r
library(dplyr)
drop_acc() %>% 
    select(uid, name_details.given_name)
```

__Directory listing__

```r
drop_dir()
# or specify a path
drop_dir('public/gifs')
```

__Filter dir listing by filetype (e.g. png files)__

```r
drop_dir() %>% 
    filter(mime_type == "image/png")
```

__Create folders__


```r
drop_create('drop_test')
```

__Upload a file__

```r
write.csv(mtcars, 'mtcars.csv')
drop_upload('mtcars.csv')
# or upload to a specific folder
drop_upload('mtcars.csv', dest = "drop_test")
```

__Download a file__

```r
drop_get(path = 'mtcars.csv')
```

__Delete a file__

```r
drop_delete('mtcars.csv')
```

__Move files__

```r
drop_create("new_folder")
drop_move("mtcars.csv", "new_folder/mtcars.csv")
```

__Copy files__

```r
drop_create("new_folder2")
drop_copy("mtcars.csv", "new_folder2/mtcars.csv")
```

__Search your Dropbox__

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
#            rev thumb_exists                                                    #                                               path is_dir
# 1  1b206e7f519         TRUE                                                   # /obscure_path/themes/style/bgnoise.gif  FALSE
# 2  1d906e7f519         TRUE                                                  # /obscure_path/images/logos/ploslogo.gif  FALSE
# 3  1da06e7f519         TRUE                                             # /obscure_path/images/logos/treebase_logo.gif  FALSE
# 4  1db06e7f519         TRUE                                              # /obscure_path/images/logos/fishbaselogo.gif  FALSE
# Variables not shown: client_mtime (chr), icon (chr), read_only (lgl), bytes (# int), modified (chr), size (chr), root (chr), mime_type
#  (chr), revision (int), parent_shared_folder_id (chr)
```

__Search and download files__

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

__Share links__

```r
gifs <- drop_search("rabbit")
drop_share(gifs$path)
# url = https://db.tt/PnNKg99G 
# expires = Tue, 01 Jan 2030 00:00:00 +0000 
# visibility = PUBLIC 
```
The shared URL resolves here https://www.dropbox.com/s/aikiaug0x2013dp/duck_rabbit.gif?dl=0

__Read csv files directly from Dropbox__

```r
write.csv(iris, file = "iris.csv")
drop_upload("iris.csv")
# Now let's read this back into an R session
# Note that there is a quiet download happening to your temp dir
new_iris <- drop_read_csv("iris.csv")
```


__Known issues__

* There are currently no known bugs.
* For any other issues, please file an [issue](https://github.com/karthik/rDrop2/issues).
