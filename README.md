# jira-epic-import

This project takes an xlsx spreadsheet of stories and imports it into Jira using the V2 API.

Import fields
* summary
* description
* labels (might not work with V2 api)
* acceptance
* size
* team
* epic_link (story ID like xx-xxx)

You will need docker and docker-compose installed.

## To clone an epic with stories ##

In jira navigate to
* All Issues 
* In Jira, clone the old epic (stories won't be cloned), take note of the epic id
* Export stories in old epic
  * Go to Advanced Search (top right of search)
  * Switch to JQL - `project = "MY PROJECT" and "Epic Link" in (xx-xxx) ORDER BY created DESC`
  * Export - Export HTML (all fields) (Excel can't handle a CSV with line breaks!)
* Prep downloaded file for re-import
  * Open downloaded HTML file with excel
  * Remove 3 header rows (not the table header), and keep the following columns
  * Rename these column headers, and delete the rest; 
    * summary
    * description
    * labels (might not work with V2 api)
    * acceptance
    * size
    * team
    * epic_link (story ID like xx-xxx)
    * (Alternatively you could update process_sheet() to map your columns)
* Look over the epic and clean up
  * Remove the word done
  * Remove references to specific version and dates
  * Try to remove strike throughs if you can
* Save as my-file.xlsx (name not important)

To import
* Clone this jira-import repo
  * Create .env from .env.example file with JIRA API config
* `./go my-file.xlsx` (use your file name)
* The importer will output some JSON that include the jira ids 
* You'll likely have to update the template

## To debug locally

As above.  You need to hang the container so you can exec into it and debug.  To do this make a docker-compose.override.yml file from the example file.  Be aware ruby may take a couple minutes to be functional on the first run because bundler will be installing in the background.

* Clone this repo
* `cp docker-compose-override.yml.example docker-compose-override.yml`
* `docker-compose up -d app && docker-compose exec app /bin/bash`
* $ `bundle exec ruby start.rb -f import.xlsx`

To step through running code, set a breakpoint by inserting `byebug` into the source.
