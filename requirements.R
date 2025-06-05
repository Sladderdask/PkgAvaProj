# Set CRAN repo globally to avoid repeated lookups
options(repos = c(CRAN = "https://cloud.r-project.org"))

# To run Python
install.packages("reticulate")

# Database management packages
install.packages(c("RSQLite", "DBI", "glue"))

# Interactive representations
install.packages(c("shiny", "ggplot2"))

# Data formatting
install.packages(c("readxl", "readr", "dplyr", "stringr"))

# RNA seq
install.packages("BiocManager")
BiocManager::install("biomaRt")

