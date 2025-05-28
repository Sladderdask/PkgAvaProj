#' onehotfun
#'
#' Takes in nucleotide sequences of 20 nt in lenght and returns a dataframe
#' where each row a one hot encoded version of that sequence with each
#' nucleotide on a separate column
#'
#' @param seqs sequences of 20 nt in length.
#'
#' @returns A dataframe with 20 columns where each column represents
#' a position in the sequence.
#'
#' @examples
#' seqs <- c("ATGCGTACGTAGCTAGCTAG", "CGTACGTAGCTAGCTAGCTA")
#' onehotdf <- onehotfun(seqs)
#' head(onehotdf)
#'
#' @export
onehotfun <- function(seqs) {
  # Create dictionary for onehoencoding
  one_hot_map <- c("0001", "0010", "0100", "1000")
  names(one_hot_map) <- c("A", "C", "G", "T")
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
