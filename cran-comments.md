Comments to CRAN maintainers:

The package has no live examples or tests that run on CRAN because the package is a live interface to the Dropbox data storage platform. No API calls can be made to the API without authenticating into a live account. 

On Travis CI, an encrypted token allows the maintainers to decrypt and run extensive tests on each commit/pull request.

Several issues were caught by users shortly after 0.8 was released; 0.8.1 addresses these issues.
