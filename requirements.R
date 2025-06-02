# Set CRAN repo globally to avoid repeated lookups
options(repos = c(CRAN = "https://cloud.r-project.org"))

# To run Python
install.packages("reticulate")

# Database management packages
install.packages(c("RSQLite", "DBI", "glue"))

# Interactive representations
install.packages("shiny", "ggplot2")

# Data formatting
install.packages(c("readxl", "readr", "seqinr", "dplyr", "stringr"))

# RNA seq
install.packages("BiocManager")
# For translating gene id to gene name ???   
BiocManager::install("biomaRt")


# Use py_install(packages = c("tensorflow", "scikit-learn", "shap"))

