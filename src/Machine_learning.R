# Download required libraries
library(reticulate)
py_run_file("src/imports.py")


# Connect to database
conn <- dbConnect(SQLite(), dbname = "src/DatabasLite.db")

# Importera data from database and divide up in X and y
y <- dbGetQuery(conn, "SELECT LFC
                       FROM GeCKO
                       INNER JOIN sgRNA_data ON sgRNA_data.sgRNAid = GeCKO.UID
                       INNER JOIN RNA_seq ON RNA_seq.gene_name = sgRNA_data.gene_name
                       WHERE fpkm_binary = 1
                       ")

X <- dbGetQuery(conn, "SELECT nt1, nt2, nt3, nt4, nt5, nt6, nt7, nt8, nt9, nt10, nt11, nt12, nt13, nt14, nt15, nt16 ,nt17 ,nt18 nt19, nt20, gc_content
                       FROM GeCKO
                       INNER JOIN sgRNA_data ON sgRNA_data.sgRNAid = GeCKO.UID
                       INNER JOIN RNA_seq ON RNA_seq.gene_name = sgRNA_data.gene_name
                       WHERE fpkm_binary = 1
                       ")


# Reticulate data from R to python (python equivalents that is Pandas DataFrame)
y <- r_to_py(y)
X <- r_to_py(X)


# Disconnect from database
dbDisconnect(conn)













# Workflow
# Take in the data using R
# Cover to python
# Do the python code for Machine learning -> Maybe making classes also
# Convert back to R
# Plot using R

# In dataformatig create S4 classes


