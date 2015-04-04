
# rDrop2 - Dropbox interface from R  ![](drop.png)  


This package provides programmatic access to Dropbox from R. The package provides a full suite of file operations, including directory listing, copy/move/delete operations, account information and the ability to upload and download files from any Dropbox account. 


__Installation__  

```r
devtools::install_github('karthik/rDrop2')
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
dropbox_dir()
```

__Retrieve only pngs__

```r
drop_dir() %>% 
    .$contents %>% 
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
dir(pattern = "csv")
unlink('mtcars.csv')
dir(pattern = "csv")
drop_get(path = '/mtcars.csv')
dir(pattern = "csv")
```

__Delete a file__

```r
drop_delete('mtcars.csv')
```

__Searching your Dropbox__

```r
foo <- drop_search('gif')
> dim(foo)
[1] 751  14
> tail(foo)
Source: local data frame [6 x 14]
```

```r
           rev thumb_exists                                                                                                  path is_dir
1  1b206e7f519         TRUE                                                   /obscure_path/themes/style/bgnoise.gif  FALSE
2  1d906e7f519         TRUE                                                  /obscure_path/images/logos/ploslogo.gif  FALSE
3  1da06e7f519         TRUE                                             /obscure_path/images/logos/treebase_logo.gif  FALSE
4  1db06e7f519         TRUE                                              /obscure_path/images/logos/fishbaselogo.gif  FALSE
5  1df06e7f519         TRUE                                                 /obscure_path/images/logos/ritislogo.gif  FALSE
6 3b6c07dead3c         TRUE /Collaborations/DataONE-ProvWG/meetings/ahm-2013/provwgslide-final-reporting.key/Data/fp_cvi_logo.gif  FALSE
Variables not shown: client_mtime (chr), icon (chr), read_only (lgl), bytes (int), modified (chr), size (chr), root (chr), mime_type
  (chr), revision (int), parent_shared_folder_id (chr)
```