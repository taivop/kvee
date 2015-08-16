library(logging)

# Setup logging to console
basicConfig()

# Get dir contents
dir_path <- "data_out/"
files <- list.files(dir_path, pattern="data_.*")

for(i in 1:length(files)) {
  csv_file <- sprintf("%s%s", dir_path, files[i])
  # Handle escaped quotes because read.table cannot
  #http://stackoverflow.com/questions/7066664/how-to-read-double-quote-escaped-values-with-read-table-in-r
  p <- pipe(paste0('sed \'s/\\\\"/""/g\' "', csv_file, '"'))
  new_tbl <- read.table(p, sep=";", header=TRUE, row.names=NULL,
                         quote="\"", colClasses="character")
  rm(p)
  
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
combined_file_path <- sprintf("%s%s", dir_path, "combined.csv")
loginfo(sprintf("Saving combined table to %s...", combined_file_path))
write.table(combined, file=file_path, sep=";")
loginfo(sprintf("Done."))

