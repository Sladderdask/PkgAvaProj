library(readxl)
library(readr)
library(DBI)
library(RSQLite)
library(biomaRt)

# Import excel files
sgRNA_data <- read_excel("data/sgRNA_data.xlsx")
sgRNA_A <- read.csv("data/Library_A.csv")
sgRNA_B <- read.csv("data/Library_B.csv")

# Open excel files
View(sgRNA_data)
View(sgRNA_A)
View(sgRNA_B)

# Connect to database
conn <- dbConnect(SQLite(), dbname = "src/DatabasLite.db")

# Verify database
dbListTables(conn, "sgRNA_data")
dbListFields(conn, "sgRNA_data")
dbListFields(conn, "GeCKO")
dbListFields(conn, "RNA_seq")

colnames(sgRNA_data)



# Adding data to database
selected_data <- sgRNA_data[, c("sgrna", "LFC", "score")]

colnames(selected_data) <- c("sgRNAid", "LFC", "score")
dbWriteTable(conn, "sgRNA_data", selected_data, append = TRUE)

selected_data <- sgRNA_A[, c("UID", "seq")]
colnames(selected_data) <- c("UID", "Sequence")
dbWriteTable(conn, "GeCKO", selected_data, append = TRUE)

selected_data <- sgRNA_B[, c("UID", "seq")]
colnames(selected_data) <- c("UID", "Sequence")
dbWriteTable(conn, "GeCKO", selected_data, append = TRUE)

# Peek into database
head(dbReadTable(conn, "sgRNA_data"))
dbListFields(conn, "sgRNA_data")
head(dbReadTable(conn, "GeCKO"))
tail(dbReadTable(conn, "GeCKO"))

# Reqrite seqeunces into Binary seqs to one hot encoding
gecko_df <- dbGetQuery(conn, "SELECT * FROM GeCKO")
# Take the sequences from the column seq

sequences <- gecko_df$Sequence

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

onehotresult[1:5,1:20]

# Add to onehotresult gecko_df
gecko_df[,3:22] <- onehotresult

gecko_df[1:5,1:ncol(gecko_df)]

# Add to datbase table GeCKO
dbWriteTable(conn, "GeCKO", gecko_df, overwrite = TRUE)

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


############################## RNA-seq data ####################################


# Read the RNA seq data file -> Needs to be converted to corresponding gene names
ensemble_ids <- read.delim("data/RNA_seq_data.gz")
# Check ensemble choices
listEnsembl()
# Choose genes as ensemble and dataset: hsapiens_gene_ensembl
ensemble_connect <- useEnsembl(biomart = "genes", dataset = "hsapiens_gene_ensembl", mirror = "asia")
# Check for available attributes
attribute <- listAttributes(ensemble_connect)
# Translate the Ensemble Gene Id to the corresponding gene name
external_gene_names <- getBM(
                              attributes = c("ensembl_gene_id", "external_gene_name"),
                              filters ="ensembl_gene_id",
                              values = ensemble_ids$geneName,
                              mart = ensemble_connect
                              )
# Merge the dataframes so the genename has its corresponding fpkm.counted value
merged_df <- merge(external_gene_names,
                   ensemble_ids[, c("geneName", "fpkm.counted")],
                   by.x = "ensemble_id",
                   by.y = "geneName")



# Add to database
colnames(merged_df ) <- c("ensemble_id", "gene_name", "fpkm_counted")
dbWriteTable(conn, "RNA_seq",merged_df, append = TRUE)
test <- dbGetQuery(conn, "SELECT * FROM RNA_seq")


# Choose threshold...
dbExecute(conn,
          "
                UPDATE RNA_seq
                SET fpkm_binary = 1
                WHERE fpkm_counted > 1
                "
)








# Disconnect from database
dbDisconnect(conn)
                         
                         