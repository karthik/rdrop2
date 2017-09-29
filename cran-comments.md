Comments to CRAN maintainers:

The package has no live examples or tests that run on CRAN because the package is a live interface to the Dropbox data storage platform. No API calls can be made to the API without authenticating into a live account. 

On Travis CI, an encrypted token allows the maintainers to decrypt and run extensive tests on each commit/pull request.

Several issues were caught by users shortly after 0.8 was released; 0.8.1 addresses these issues.

Questions on most recent update from Svetlana:

> Thanks, please write package names and software names in single quotes (e.g. 'Dropbox').

We thought this was only necessary for the title but also fixed it in the description.

> Please write URLs in the form
<http:...> or <https:...>
with angle brackets for auto-linking and no space after 'http:' and 'https:'.

We updated both. 

> We see code lines such as
 Author: Akhil S Bhel.

> Please add all authors and copyright holders in the Authors@R field with the appropriate roles.

Done.

> You examples are all wrapped in \dontrun{}. Please unwrap, if possible.

This is impossible for the package and the reasons are preemptively noted at the top.