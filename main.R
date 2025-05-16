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
dbListTables(conn, "sgRNA_data")
dbListFields(conn, "sgRNA_data")
dbListFields(conn, "GeCKO")
colnames(sgRNA_data)


# Adding data to database
selected_data <- sgRNA_data[, c("sgrna", "LFC", "score")]
colnames(selected_data) <- dbListFields(conn, "sgRNA_data")
dbWriteTable(conn, "sgRNA_data", selected_data, append = TRUE)

selected_data <- sgRNA_A[, c("UID", "seq")]
colnames(selected_data) <- dbListFields(conn, "GeCKO")
dbWriteTable(conn, "GeCKO", selected_data, append = TRUE)

selected_data <- sgRNA_B[, c("UID", "seq")]
colnames(selected_data) <- dbListFields(conn, "GeCKO")
dbWriteTable(conn, "GeCKO", selected_data, append = TRUE)


# Peek into database
head(dbReadTable(conn, "sgRNA_data"))
dbListFields(conn, "sgRNA_data")
head(dbReadTable(conn, "GeCKO"))
tail(dbReadTable(conn, "GeCKO"))

# Reqrite seqeunces into Binary seqs to one hot encoding
gecko_df <- dbGetQuery(conn, "SELECT * FROM GeCKO")
# Take the sequences from the column seq
sequences <- gecko_df$sequence
# Create dictionary for onehoencoding
one_hot_map <- c("0001", "0010", "0100", "1000")
names(one_hot_map) <- c("A", "C", "G", "T")


# Function that takes in DNA sequences, 
# split each nucleotide into separate column
# And translate the nucleotide to binaryform
splitfunction <- function(seqs) {
  # Split each sequence into individual characters
  split_seqs <- strsplit(seqs, "")

  # Number of positions (should be 20)
  n_pos <- length(split_seqs[[1]])
  
  # Preallocate list of columns, vectors made of lists
  columns <- vector("list", n_pos)
  
  # For each position 1:20, extract that base from all sequences and one-hot encode,
  for (nucleotide in 1:n_pos) {
    # Go through position i for each row -> function(row)
    bases_at_i <- sapply(split_seqs, function(row) row[nucleotide])
    columns[[nucleotide]] <- one_hot_map[bases_at_i]
  }
  
  # Converting list into data frame and combine with name columns
  df <- as.data.frame(columns, stringsAsFactors = FALSE)
  colnames(df) <- paste0("nt", 1:n_pos)
  
  return(df)
}
# Call on the function using the DNA seqeunces in the GaCKO table
onehotresult <- splitfunction(sequences)

# Add to dataframe gecko_df
new_dataframe <- cbind(gecko_df, onehotresult)
# Add to datbase table GeCKO
dbWriteTable(conn, "GeCKO", new_dataframe, append = TRUE)
# Verify the update
gecko_df <- dbGetQuery(conn, "SELECT * FROM GeCKO")
head(gecko_df)

# Join the two Tables sgRNA_data and GeCKO
dbExecute(conn,
                "
                UPDATE sgRNA_data
                SET LFC_binary = 1
                WHERE LFC > 0
                "
                )
dbExecute(conn,
                "
                UPDATE sgRNA_data
                SET LFC_binary = 0
                WHERE LFC = 0 OR LFC < 0
                "
                )

test <- dbGetQuery(conn, "SELECT * FROM sgRNA_data")
test[25000:25500,]




# Disconnect from database
dbDisconnect(conn)






