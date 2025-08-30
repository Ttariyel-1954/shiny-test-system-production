# init.R - Heroku üçün R paket quraşdırması
options(repos = c(CRAN = "https://cloud.r-project.org/"))

# Sizin tətbiqinizin paketləri
install.packages(c(
  "shiny",
  "DBI", 
  "RSQLite",
  "shinydashboard",
  "DT"
))

# Əlavə system dependencies (SQLite üçün)
system("apt-get update && apt-get install -y sqlite3 libsqlite3-dev")
