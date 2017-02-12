# Don't show code when executing
options(echo=FALSE)

library(dplyr)
library(rvest)
library(logging)

# ---- Initial setup ----
# Read scraping function
source("scrape_fun.R")
# Setup logging to console
basicConfig()
# Profiling
#profile_filename <- "profile.txt"
#Rprof(profile_filename)

# Read start and end ID from command line
args <- commandArgs(trailingOnly = TRUE)
tryCatch({
  id_start <- as.numeric(args[1])
  id_end <- as.numeric(args[2])
  
  # Setup logging to file
  addHandler(writeToFile, file=sprintf("logs/%dto%d.log", id_start, id_end))
}, warning=function(w){
  logwarn(w)
  stop()
}, error=function(e){
  logerror(e)
  stop("Arguments: id_start id_end")
})

# Track last successful ID
id_last_success <- NA

# Save every n ads
save_every_n <- 3000

# ---- Main loop ----
loginfo("Started fetching ads...")
for(ad_id_reached in id_start:id_end) {
  loginfo(sprintf("Scraping %d (%d/%d)", ad_id_reached, ad_id_reached-id_start+1,
                id_end-id_start+1))
  Sys.sleep(0.05)
  
  # Get ad
  tryCatch({
    if(!exists("ads")) {
      ads <- as.data.frame(scrape_page(id_start), stringsAsFactors=FALSE)
    } else {
      ad <- scrape_page(ad_id_reached)
      names(ad) <- names(ads)
      ads <- rbind(ads, ad)
      id_last_success
    }
  }, error=function(e) {
    logerror(sprintf("Error at %d: %s", ad_id_reached, e))
  })
  
  # Save if we are at a checkpoint
  tryCatch({
    if((ad_id_reached-id_start) %% save_every_n == 0 && ad_id_reached != id_start) {
      file_name <- sprintf("data_out/data_%dto%d.csv", id_start, id_end)
      write.table(ads, file=file_name, sep=";")
      loginfo(sprintf("Successfully saved at checkpoint %d.", ad_id_reached))
    }
  }, error=function(e) {
    logerror(sprintf("Could not save at checkpoint %d: %s", ad_id_reached, e))
  }, warning=function(w) {
    logerror(sprintf("Warning saving at checkpoint %d: %s", ad_id_reached, w))
  })
}
loginfo("Done.")

# Log some statistics
loginfo(sprintf("Last successful ID: %d.", id_last_success))
num_tried <- ad_id_reached - id_start + 1
num_success <- nrow(ads)
success_rate = 100 * num_success / num_tried
loginfo(sprintf("Scraped %d out of %d tries. Success rate %.1f%%.",
                num_success, num_tried, success_rate))

# ---- Save results ----
tryCatch({
  file_name <- sprintf("data_out/data_%dto%d.csv", id_start, ad_id_reached)
  write.table(ads, file=file_name, sep=";")
  loginfo(sprintf("Data saved to %s.", file_name))
}, error=function(e) {
  logerror(sprintf("Error saving to file: %s", e))
}, warning=function(w) {
  logwarn(w)
})

# Summarise profiling
#Rprof(NULL)
#summaryRprof(profile_filename)


