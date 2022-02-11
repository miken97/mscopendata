
# Step 0: Resources -------------------------------------------------------

# pkg development resources

# <https://www.pipinghotdata.com/posts/2020-10-25-your-first-r-package-in-1-hour>
# <https://rtask.thinkr.fr/when-development-starts-with-documentation>
# <https://github.com/ThinkR-open/attachment/blob/master/devstuff_history.R>
# <https://cran.r-project.org/web/packages/roxygen2/vignettes/rd.html>


# Step 1: Create Pkg ------------------------------------------------------

# create pkg (<<https://www.pipinghotdata.com/posts/2020-10-25-your-first-r-package-in-1-hour>)
usethis::create_package("C:/mike_nanos/r_files/mscopendata")


# Step 2: Development History ---------------------------------------------

# create dev_history.R and hide from pkg build
# > save dev_history.R in project root
usethis::use_build_ignore("dev_history.R")


# Step 3: Git Connection --------------------------------------------------

# connect local pkg to git repo
usethis::use_git()
usethis::use_github()


# Step 4: Description & License -------------------------------------------

# add mit license and update description file
usethis::use_mit_license("Mike Nanos")
#> Update description file manually. Ensure 'LazyData: true'

# add pipe
# usethis::use_pipe()

# add tidy eval and put fields in standard order
usethis::use_tidy_eval()
usethis::use_tidy_description()

# add tibble print method
usethis::use_tibble()

# add readme
usethis::use_readme_rmd()
#> run after updating README.Rmd
# devtools::build_readme()


# document and run first check
devtools::document()
devtools::check()


# Step 5: Functions & Dependencies ----------------------------------------

## Functions and Utilities ----

### global variables and functions ----

r_files <- c(
  "globals",
  "geomet-ogc-api"
)

usethis::use_r(r_files[2])


### pkg datasets ----

# pkg_data <- c(
#   "eccc_station_db"
# )

# usethis::use_data_raw(pkg_data[1])


### pkg dependencies ----

pkg_deps <- c(
#   "dplyr",
  "httr2"
#   "purrr",
#   "rlang",
#   "stringr",
#   "tibble",
#   "tidyr"
)

usethis::use_package(pkg_deps[1])


# Step 6: Vignettes ---------------------------------------------------

usethis::use_vignette("msc-opendata-services", "MSC Open Data")


## Documentation ----
#
# see: <Section 10.3: https://r-pkgs.org/man.html>
# - first sentence:
#   - becomes title of the documentation
#   - should fit on one line, be written in sentence case, but not end in a full stop.
#
# - second paragraph:
#   - is the description
#   - should briefly describe what the function does.
#
# - third (and subsequent) paragraphs:
#   - section that is shown after the argument description
#   - should go into detail about how the function works.
#
# - tags:
#
#   - `@section` add arbitrary sections to the documentation
#
#   - `@seealso` point to other useful resources:
#     - on the web, `\url{site_url}`
#     - in your package `\code{\link{fn_name}}`
#     - another package `\code{\link[pkg_name]{fn_name}}`
#
#   - `@family` link to every other function in the family
#
#   - `@keywords` adds standardized keywords
#      - Keywords are optional, but if present, must be taken from a predefined list found in file.path(R.home("doc"), "KEYWORDS")
#      - use `@keywords internal` to remove function from pkg index and disable (some) automated tests.
#        - common to use for functions that are of interest to other developers extending your pkg but not most users.
#
#   - `@param name description` describes the function’s inputs or parameters
#      - description should provide a succinct summary of the type of the parameter (e.g., string, numeric vector)
#      - if not obvious from the name, what the parameter does
#      - should start with a capital letter and end with a full stop.
#
#   - `@return description` describes the output from the function
#      - description
#      - #' @return a [tibble][tibble::tibble-package]
