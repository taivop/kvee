library(logging)
library(dplyr)

# Setup logging to console
basicConfig()

# Get dir contents
dir_path <- "../data_out/"
files <- list.files(dir_path, pattern="data_.*")

for(i in 1:length(files)) {
  csv_file <- sprintf("%s%s", dir_path, files[i])
  # Handle escaped quotes because read.table cannot
  #http://stackoverflow.com/questions/7066664/how-to-read-double-quote-escaped-values-with-read-table-in-r
  p <- pipe(paste0('sed \'s/\\\\"/""/g\' "', csv_file, '"'))
  new_tbl <- read.table(p, sep=";", header=TRUE, row.names=NULL,
                         quote="\"", colClasses="character")
  rm(p)
  
  # Drop ad text from new table and remove quotes from title
  new_tbl <- new_tbl %>%
    select(-row.names,-Aadress.1, -Aadress.2, -Aadress.3, Aadress.4) %>%
    mutate(Pealkiri=gsub("\"", " ", Pealkiri))
  
  if(i == 1) {
    combined <- new_tbl
  }
  else {
    combined <- rbind(combined, new_tbl)
  }
  loginfo(sprintf("Successfully read %s. Total %d rows.",
                  csv_file, nrow(combined)))
}

# Save combined table
combined_file_path <- sprintf("%s%s", dir_path, "kvee_publish_withtext.csv")
loginfo(sprintf("Saving combined table to %s...", combined_file_path))
write.csv2(combined, file=combined_file_path, row.names=FALSE)
loginfo(sprintf("Done."))

