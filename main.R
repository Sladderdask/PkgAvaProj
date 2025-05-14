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
dbWriteTable(conn, "sgRNA_data", selected_data, overwrite = TRUE, column.names=FALSE)

selected_data <- sgRNA_A[, c("UID", "seq")]
dbWriteTable(conn, "GeCKO", selected_data, overwrite = TRUE, column.names=FALSE)

selected_data <- sgRNA_B[, c("UID", "seq")]
dbWriteTable(conn, "GeCKO", selected_data, append = TRUE, column.names=FALSE)


# Peek into database
head(dbReadTable(conn, "GeCKO"))
tail(dbReadTable(conn, "GeCKO"))

# Reqrite seqeunces into Binary seqs to one hot encoding
gecko_df <- dbGetQuery(conn, "SELECT * FROM GeCKO")
# Take the sequences from the column seq
sequences <- gecko_df$seq
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
onehotresult <- dna_to_one_hot(sequences)

# Add to dataframe gecko_df
new_dataframe <- cbind(gecko_df, onehotseq=onehotresult)
# Add to datbase table GeCKO
dbWriteTable(conn, "GeCKO", new_dataframe, overwrite = TRUE, column.names=FALSE)
# Verify the update
gecko_df <- dbGetQuery(conn, "SELECT * FROM GeCKO")
head(gecko_df)






# Disconnect from database
dbDisconnect(conn)





