![](drop.png) 

rDrop2 - Dropbox interface from R
=================================

This package provides programmatic access to Dropbox from R. The package
provides a full suite of file operations, including directory listing,
copy/move/delete operations, account information and the ability to
upload and download files from any Dropbox account. Current version is
0.4.0.99.

**Installation**

```r
devtools::install_github('karthik/rDrop2')
```

**Basic Usage**

```r
library(rDrop2)
drop_auth()
# This will launch your browser and request access to your Dropbox account. 
# Once completed, close your browser window and return to R to complete authentication.
```

**Directory listing**

```r
library(dplyr)
acc_info() %>% 
    select(uid, name_details.given_name)
```

    #>       uid name_details.given_name
    #> 1 2223411                 Karthik

**Retrieve only pngs**

```r
drop_dir() %>% 
    .$contents %>% 
    filter(mime_type == "image/png")
```

**Create a folder**

```r
drop_create('drop_test')
```

    #> $read_only
    #> [1] FALSE
    #> 
    #> $revision
    #> [1] 144699718
    #> 
    #> $bytes
    #> [1] 0
    #> 
    #> $thumb_exists
    #> [1] FALSE
    #> 
    #> $rev
    #> [1] "89ff1460037fcc7"
    #> 
    #> $modified
    #> [1] "Sat, 04 Apr 2015 00:37:17 +0000"
    #> 
    #> $size
    #> [1] "0 bytes"
    #> 
    #> $path
    #> [1] "/drop_test"
    #> 
    #> $is_dir
    #> [1] TRUE
    #> 
    #> $modifier
    #> NULL
    #> 
    #> $root
    #> [1] "dropbox"
    #> 
    #> $icon
    #> [1] "folder"

**Upload a file**

```r
write.csv(mtcars, 'mtcars.csv')
drop_put('mtcars.csv')
```

    #> Response [https://api-content.dropbox.com/1/files_put/auto/mtcars.csv]
    #>   Date: 2015-04-03 17:37
    #>   Status: 200
    #>   Content-Type: application/json
    #>   Size: 329 B

**Download a file**

```r
dir(pattern = "csv")
```

    #> [1] "mtcars.csv"

```r
unlink('mtcars.csv')
dir(pattern = "csv")
```

    #> character(0)

```r
drop_get(path = '/mtcars.csv')
```

    #> Response [https://api-content.dropbox.com/1/files/auto//mtcars.csv]
    #>   Date: 2015-04-03 17:37
    #>   Status: 200
    #>   Content-Type: text/csv; charset=utf-8
    #>   Size: 1.98 kB
    #> <ON DISK>  mtcars.csv

```r
dir(pattern = "csv")
```

    #> [1] "mtcars.csv"

**Delete a file**

```r
drop_delete('mtcars.csv')
```

    #> $read_only
    #> [1] FALSE
    #> 
    #> $is_deleted
    #> [1] TRUE
    #> 
    #> $revision
    #> [1] 144699720
    #> 
    #> $bytes
    #> [1] 0
    #> 
    #> $thumb_exists
    #> [1] FALSE
    #> 
    #> $rev
    #> [1] "89ff1480037fcc7"
    #> 
    #> $modified
    #> [1] "Sat, 04 Apr 2015 00:37:19 +0000"
    #> 
    #> $mime_type
    #> [1] "text/csv"
    #> 
    #> $size
    #> [1] "0 bytes"
    #> 
    #> $path
    #> [1] "/mtcars.csv"
    #> 
    #> $is_dir
    #> [1] FALSE
    #> 
    #> $modifier
    #> NULL
    #> 
    #> $root
    #> [1] "dropbox"
    #> 
    #> $client_mtime
    #> [1] "Wed, 31 Dec 1969 23:59:59 +0000"
    #> 
    #> $icon
    #> [1] "page_white"
 
 
