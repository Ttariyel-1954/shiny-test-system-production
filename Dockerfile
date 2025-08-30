FROM --platform=linux/amd64 rocker/shiny:4.3.1

LABEL maintainer="test-system@example.com"
LABEL description="Custom Shiny Test Application for 600 users"

# Sistem paketlərini yeniləyin (SQLite üçün də)
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libxml2-dev \
    libssl-dev \
    libsqlite3-dev \
    sqlite3 \
    && rm -rf /var/lib/apt/lists/*

# R paketlərini addım-addım quraşdırın
RUN R -e "install.packages('shiny', repos='https://cran.rstudio.com/')"
RUN R -e "install.packages('DBI', repos='https://cran.rstudio.com/')" 
RUN R -e "install.packages('RSQLite', repos='https://cran.rstudio.com/')"
RUN R -e "install.packages('shinydashboard', repos='https://cran.rstudio.com/')"
RUN R -e "install.packages('DT', repos='https://cran.rstudio.com/')"

# Paketlərin qurulduğunu test et
RUN R -e "library(shiny); library(DBI); library(RSQLite); library(shinydashboard); library(DT); cat('✅ Bütün paketlər hazır!\n')"

# Shiny Server konfiqurasiyası
RUN echo 'run_as shiny;\n\
server {\n\
  listen 3838;\n\
  location / {\n\
    site_dir /srv/shiny-server;\n\
    log_dir /var/log/shiny-server;\n\
    directory_index on;\n\
  }\n\
}' > /etc/shiny-server/shiny-server.conf

# Sizin tətbiqinizi köçürün
COPY app.R /srv/shiny-server/

# İcazələri təyin edin
RUN chown -R shiny:shiny /srv/shiny-server/

# Port 3838-i açın  
EXPOSE 3838

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:3838/ || exit 1

# Shiny Server başladın
CMD ["/usr/bin/shiny-server"]
