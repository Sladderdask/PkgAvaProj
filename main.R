library(readxl)
library(readr)
library(DBI)

# Import excel files
sgRNA_data <- read_excel("sgRNA_data.xlsx")
sgRNA_A <- read.csv("Library_A.csv")
sgRNA_B <- read.csv("Library_B.csv")

# Open excel files
View(sgRNA_data)
View(sgRNA_A)
View(sgRNA_B)

# Connect to database
conn <- DBI::dbConnect(RSQLite::SQLite(), dbname = "DatabasLite.db")

# Verify database
dbListTables(conn)


# Adding data to database
selected_data <- sgRNA_data[, c("sgrna", "LFC", "score")]
dbWriteTable(conn, "sgRNA_data", selected_data, overwrite = TRUE)

selected_data <- sgRNA_A[, c("UID", "seq")]
dbWriteTable(conn, "GeCKO", selected_data, overwrite = TRUE)

selected_data <- sgRNA_B[, c("UID", "seq")]
dbWriteTable(conn, "GeCKO", selected_data, append = TRUE)

# Peek into database
head(dbReadTable(conn, "GeCKO"))
tail(dbReadTable(conn, "GeCKO"))

# Disconnect from database
dbDisconnect(conn)