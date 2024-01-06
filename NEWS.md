# rdrop2 0.8.2.2
* replaced dependency package `assertive` by `assertthat`.

# rdrop2 0.8.2
* Minor update to unarchive on CRAN (archived because assertive was archived)


# rdrop2 0.8.1
* `drop_dir` now flattens nested responses so return can be coerced to `tbl_df`, e.g. if returned files/folders are shared with other (#135)
* `drop_download` now returns `TRUE` when download was successful; should mitigate errors noted by multiple users (#132)

# rdrop2 0.8 
* This version is a major update from V1 of the Dropbox API (being deprecated on September 28, 2017) to V2. 🎉
* `drop_acc` -  no longer returns quota information but still returns all other account related details. Quota retrieval will become available again on `0.9`
* `drop_auth` - now allows for specifying a saved token with `rdstoken`
* `drop_copy` and `drop_move` - no longer allow a `root` argument. These functions also now have 3 additional options. `allow_shared_folder` (allows for copying/moving shared folders), `autorename`, renames objects in cases of conflict, and `allow_ownership_transfer` allows ownership transfer if a copy/move operation results in such a change.
* `drop_create` - no longer includes a `root` argument. Function now allows for `autorename` to rename folders in case of conflicts. 
* `drop_delete` - loses the `root` argument but functionally remains unchanged.
* `drop_delta` - no longer exists and functionality has been folded into `drop_dir`. `cursor` can be passed to `drop_dir` (see below).
* `drop_dir` - now allows for `recursive` listing. In addition, one can filter by `include_has_explicit_shared_members` (has been shared explicitly), `include_mounted_folders`. `file_limit` has been changed to `limit`.
* `drop_get` - has been deprecated and replaced with `drop_download`. `drop_get` will be removed in a future version.  In `drop_download`, `local_file` has been replaced with `local_path`.
* `drop_history` - now includes a limit argument (for number of versions required)
* `drop_media` - no longer has a `locale` argument
* `drop_read_csv` - remains unchanged. However, in future versions, it will become a generic wrapper with support for custom handlers.
* `drop_search` - `file_limit` is now `max_results`. Additionally one can specify an offset with `start`. `locale` is no longer an argument. `include_deleted` is also not a function argument but returned as part of the result metadata. New option called `mode` allows for `filename`, `filename_and_content`, or for restricting search to deleted files with `deleted_filename`.
* `drop_share` - no longer has `locale` or `short_url` as arguments.  Function now allows more granularity in visibility (public, team_only, or password protected), and also allows users to set an expire time.
* `drop_upload` - `dest` is now `path`. Overwrite argument has been removed and replaced with mode, which can take overwrite or add. Additionally if `autorename` is set to TRUE, uploaded objects with conflicts will be renamed. Support for update mode will be implemented in `0.9`. Function also allows for muting upload notifications on clients.

# rdrop2 0.7  

* Added basic support for progress bars for `drop_get()`
* Added new argument `n` to `drop_dir` to control number of rows printed by `tbl_df`
* Empty folder return a empty `data.frame` instead of `NULL` (thanks @daattali)
* Fixed bug with NULL revision in `drop_get` (thanks @moggces)
* Miscellaneous bug fixes

# rdrop2 0.6

* Initial release to CRAN.
