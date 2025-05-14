library(readxl)
library(readr)
library(DBI)
library(RSQLite)

# Import excel files
sgRNA_data <- read_excel("sgRNA_data.xlsx")
sgRNA_A <- read.csv("Library_A.csv")
sgRNA_B <- read.csv("Library_B.csv")

# Open excel files
View(sgRNA_data)
View(sgRNA_A)
View(sgRNA_B)

# Connect to database
conn <- dbConnect(SQLite(), dbname = "DatabasLite.db")

# Verify database
dbListTables(conn)
dbListFields(conn, "GeCKO")


# Adding data to database
selected_data <- sgRNA_data[, c("sgrna", "LFC", "score")]
dbWriteTable(conn, "sgRNA_data", selected_data, overwrite = TRUE, row.names=FALSE)

selected_data <- sgRNA_A[, c("UID", "seq")]
dbWriteTable(conn, "GeCKO", selected_data, overwrite = TRUE, row.names=FALSE)

selected_data <- sgRNA_B[, c("UID", "seq")]
dbWriteTable(conn, "GeCKO", selected_data, append = TRUE, row.names=FALSE)


# Peek into database
head(dbReadTable(conn, "GeCKO"))
tail(dbReadTable(conn, "GeCKO"))

# Reqrite seqeunces into Binary seqs to one hot encoding
sequences <- dbGetQuery(conn, "SELECT seq FROM GeCKO")
# Take the sequences from the column seq
sequences <- sequences$seq
# Create dictionary
one_hot_map <- c("0001", "0010", "0100", "1000")
names(one_hot_map) <- c("A", "C", "G", "T")

# Function that creates a binary seqeuence
dna_to_one_hot <- function(seqs){
  # Split sequences into characters
  split_seqs <- strsplit(sequences, "")
  # Convert each base using the map
  sapply(split_seqs, function(bases) paste(one_hot_map[bases], collapse = ""))
}
# Call on the function
binary_results <- dna_to_one_hot(sequences)
print(binary_results)

# Disconnect from database
dbDisconnect(conn)





