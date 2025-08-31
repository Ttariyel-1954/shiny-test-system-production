# Heroku üçün paket quraşdırması
my_packages <- c("shiny", "shinydashboard", "DBI", "RSQLite", 
                 "RPostgreSQL", "DT", "jsonlite")

install_if_missing <- function(p) {
  if (!require(p, character.only = TRUE)) {
    install.packages(p, repos = "http://cran.rstudio.com/")
    library(p, character.only = TRUE)
  }
}

cat("Paketlər quraşdırılır...\n")
invisible(sapply(my_packages, install_if_missing))
cat("Bütün paketlər hazırdır!\n")
