# Download the required libraries
library(readxl)
library(readr)
library(DBI)
library(RSQLite)
library(biomaRt)
library(dplyr)
library(stringr)
library(ggplot2)
library(glue)

# Import data files
sgRNA_data <- read_excel("data/sgRNA_data.xlsx")
sgRNA_A <- read.csv("data/Library_A.csv")
sgRNA_B <- read.csv("data/Library_B.csv")
ensemble_ids <- read.delim("data/RNA_seq_data.gz")

# Add A and B libraridataframe together and rename correctly
gecko_df <- bind_rows(sgRNA_A, sgRNA_B)
gecko_df <- gecko_df[, c("UID", "seq")]
gecko_df <- rename(gecko_df, Sequence = seq)
sgRNA_data <- rename(sgRNA_data, sgRNAid = sgrna, gene_name = Gene)

# Connect to database
conn <- dbConnect(SQLite(), dbname = "src/DatabasLite.db")
# Verify database
dbListFields(conn, "sgRNA_data")
dbListFields(conn, "GeCKO")
dbListFields(conn, "RNA_seq")


####################### S4 class ##################################

# Define the S4 class -> Define what the class should include
# Define prototype -> If nothing is sent in go to default
setClass("Dataformation_Insertion_Db",
         slots = list(
           db = "DBIConnection",
           sequences = "character",
           data = "data.frame",
           onehotresults = "data.frame",
           one_hot_map = "character",
           datatable = "character",
           append = "logical",
           set_command = "character",
           where_command = "character"
         ),
         prototype = list(
           db = NULL,
           sequences = character(),
           data = data.frame(),
           onehotresults = data.frame(),
           one_hot_map = c(A="0001", C="0010", G="0100", T="1000"),
           datatable = character(),
           append = TRUE,
           set_command = character(),
           where_command = character()
         )
)

# Create generic functions
setGeneric("OneHotEncoding", function(object, sequence) {
  standardGeneric("OneHotEncoding")
})
setGeneric("insert_data_to_db", function(object, data, datatable, db_connection, append, overwrite=FALSE) {
  standardGeneric("insert_data_to_db")
})
setGeneric("update_db", function(object) {
  standardGeneric("update_db")
})

# Create methods -> Functions
# Method that takes in DNA sequences, split each nucleotide into separate column And translate the nucleotide to binaryform
setMethod("OneHotEncoding", "Dataformation_Insertion_Db", function(object) {
  # Split each sequence into individual characters
  split_seqs <- strsplit(object@sequences, "")
  # Number of positions (should be 20)
  n_pos <- length(split_seqs[[1]])
  # Preallocate list of columns, vectors made of lists
  columns <- vector("list", n_pos)
  # For each position 1:20, extract that base from all sequences and one-hot encode,
  for (nucleotide in 1:n_pos) {
    # Go through position i for each row -> function(row)
    bases <- sapply(split_seqs, function(row) row[nucleotide])
    columns[[nucleotide]] <- object@one_hot_map[bases]
  }
  # Converting list into data frame and combine with name columns
  df <- as.data.frame(columns, stringsAsFactors = FALSE)
  colnames(df) <- paste0("nt", 1:n_pos)
  
  # Store the onehotencoding results
  object@onehotresults <- df
  return (object)
})

# Method to insert data from dataframes into database
setMethod("insert_data_to_db", "Dataformation_Insertion_Db", function(object, overwrite =FALSE) {
  dbWriteTable(conn = object@db, 
               name = object@datatable, 
               value = object@data,
               overwrite = overwrite,
               append = object@append)
})

# Method that uses basic UPDATE commands to update a database
setMethod ("update_db", "Dataformation_Insertion_Db", function(object) {
  
  query <- glue("
                UPDATE {object@datatable}
                SET {object@set_command}
                WHERE {object@where_command}
                ")
  dbExecute(object@db,query)
  
})

########################## One hot encoding ####################################

# Construct a new object for onehotencoding
onehotencoding <- new("Dataformation_Insertion_Db", 
                      db = conn,
                      sequences = gecko_df$Sequence)

# Call on the method för onehotencoding
onehotencoding <- OneHotEncoding(onehotencoding)
# Add onehotresult to the gecko dataframe
gecko_df[,3:22] <- onehotencoding@onehotresults
# Add GC content to the gecko dataframe
gecko_df <- gecko_df %>%
  mutate(gc_content = str_count(Sequence, "[GCgc]") / str_length(Sequence))


############################## RNA-seq data ####################################

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
merged_RNA_df <- merge(external_gene_names,
                       ensemble_ids[, c("geneName", "fpkm.counted")],
                       by.x = "ensembl_gene_id",
                       by.y = "geneName")
merged_RNA_df  <- rename(merged_RNA_df , ensemble_id = ensembl_gene_id, gene_name = external_gene_name, fpkm_counted=fpkm.counted)


########################## Insert into database ################################

# Construct a new object for Inserting sgRNA data to database table sgRNA_data
insertiontodb <- new("Dataformation_Insertion_Db",
                     db = conn,
                     datatable = "sgRNA_data",
                     data = sgRNA_data[, c("sgRNAid", "gene_name", "LFC", "score")],
                     append = TRUE
)

# Call on the method for insertiontodb
insert_data_to_db(insertiontodb)

# Construct a new object for Inserting gecko data to database table GeCKO
insertiontodb <- new("Dataformation_Insertion_Db",
                     db = conn,
                     datatable = "GeCKO",
                     data = gecko_df,
                     append = TRUE
)
insert_data_to_db(insertiontodb)

#Construct a new object for Inserting RNA data to database table RNA_seq
insertiontodb <- new("Dataformation_Insertion_Db",
                     db = conn,
                     datatable = "RNA_seq",
                     data = merged_RNA_df,
                     append = TRUE
)
insert_data_to_db(insertiontodb)

#################### Updating existing data in database ########################

# Construct new objects for updating the database
updatedb <- new("Dataformation_Insertion_Db", 
                db = conn,
                datatable = "sgRNA_data",
                set_command = "LFC_binary = 1",
                where_command = "ABS(LFC) > 1")
# Call on the method for updating the database 
update_db(updatedb)

updatedb <- new("Dataformation_Insertion_Db", 
                db = conn,
                datatable = "sgRNA_data",
                set_command = "LFC_binary = 0",
                where_command = "ABS(LFC) = 1 OR ABS(LFC) < 1")

update_db(updatedb)

# Choose threshold... In RShiny let the user change this threshold
updatedb <- new("Dataformation_Insertion_Db", 
                db = conn,
                datatable = "RNA_seq",
                set_command = "fpkm_binary = 1",
                where_command = "fpkm_counted > 3")

update_db(updatedb)

updatedb <- new("Dataformation_Insertion_Db", 
                db = conn,
                datatable = "RNA_seq",
                set_command = "fpkm_binary = 0",
                where_command = "fpkm_counted < 3 OR fpkm_counted = 3")

update_db(updatedb)



# Peek into database
head(dbReadTable(conn, "sgRNA_data"))
head(dbReadTable(conn, "GeCKO"))
head(dbReadTable(conn, "RNA_seq"))







################# Filtering the data depending on the RNA seq threshold ##################
# More or less no difference between threshold 1 and 3


all_genes <- dbGetQuery(conn, "SELECT RNA_seq.gene_name, LFC 
                             FROM GeCKO
                             INNER JOIN sgRNA_data ON sgRNA_data.sgRNAid = GeCKO.UID
                             INNER JOIN RNA_seq ON RNA_seq.gene_name = sgRNA_data.gene_name
                             ")

not_activated_genes <- dbGetQuery(conn, "SELECT RNA_seq.gene_name, LFC 
                             FROM GeCKO
                             INNER JOIN sgRNA_data ON sgRNA_data.sgRNAid = GeCKO.UID
                             INNER JOIN RNA_seq ON RNA_seq.gene_name = sgRNA_data.gene_name
                             WHERE fpkm_binary = 0
                             ")


activated_genes <- dbGetQuery(conn, "SELECT RNA_seq.gene_name, LFC
                             FROM GeCKO
                             INNER JOIN sgRNA_data ON sgRNA_data.sgRNAid = GeCKO.UID
                             INNER JOIN RNA_seq ON RNA_seq.gene_name = sgRNA_data.gene_name
                             WHERE fpkm_binary = 1
                             ")


###################   Plot the LFC values for all_genes vs activated genes to see if there is a difference


# Add group labels
all_genes$category <- "All Genes"
not_activated_genes$category <- "Not Activated Genes"
activated_genes$category <- "Activated Genes"

# Combine all into one dataframe
combined_df <- bind_rows(all_genes, not_activated_genes, activated_genes)

ggplot(combined_df, aes(x = category, y = LFC, color = category)) +
  geom_jitter(width = 0.2, height = 0, size = 2, alpha = 0.7) +
  theme_minimal() +
  labs(title = "Scatterplot of Log Fold Change values",
       x = "Gene Category",
       y = "LFC") +
  scale_color_manual(values = c("All Genes" = "blue", 
                                "Not Activated Genes" = "red", 
                                "Activated Genes" = "green")) +
  theme(legend.position = "none")  # hide legend if you want



# Disconnect from database
dbDisconnect(conn)

