library(dplyr)

# Get files
sells <- read.csv2("data_cleaned/apartment_sell_tallinn.csv")
rentals <- read.csv2("data_cleaned/apartment_rent_tallinn.csv")

# Add type of ad
sells <- sells %>%
  mutate(Tüüp="Müüa")
rentals <- rentals %>%
  mutate(Tüüp="Anda üürile") %>%
  filter(Hind <= 10000)

# Combine tables
combined <- rbind(sells, rentals) %>%
  # Remove unnecessary column
  select(-X)

# Save results
write.csv2(combined, file="data_cleaned/apartment_both_tallinn.csv", row.names=FALSE)