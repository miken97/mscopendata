
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
usethis::use_build_ignore("munge.R")


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

# add readme
usethis::use_readme_rmd()

# document and run first check
devtools::document()
devtools::check()
