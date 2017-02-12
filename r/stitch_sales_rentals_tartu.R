library(dplyr)

# Get files
sells1 <- read.csv2("../data_cleaned/apartment_sell_tartu_1.csv")
sells2 <- read.csv2("../data_cleaned/apartment_sell_tartu_2.csv")
rentals <- read.csv2("../data_cleaned/apartment_rent_tartu.csv")

sells <- rbind(sells1, sells2)

# Add type of ad
sells <- sells %>%
  mutate(Tüüp="Müüa") %>%
  filter(Hind <= 10000000)
rentals <- rentals %>%
  mutate(Tüüp="Anda üürile") %>%
  filter(Hind <= 10000)

# Combine tables
combined <- rbind(sells, rentals) %>%
  # Remove unnecessary column
  select(-X)

# Save results
write.csv2(combined, file="../data_cleaned/apartment_both_tartu.csv", row.names=FALSE)
