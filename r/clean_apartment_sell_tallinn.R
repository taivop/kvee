library(dplyr)
library(reshape2)

ads_raw <- read.csv2("../data_out/combined.csv", colClasses="character")

# Select subset of ads and columns
ads <- ads_raw %>%
  mutate(Kuupäev=as.Date(Kuupäev, "%d.%m.%y")) %>%
  filter(Kuupäev >= as.Date("2012-01-01") &
           Tüüp == "Anda üürile korter") %>%
  select(-Aadress.1, -Aadress.2, -Aadress.3, -Aadress.4)

rm(ads_raw)

# Fix data types
ads <- ads %>%
  mutate(Hind=as.numeric(Hind),
         Tube=as.numeric(Tube),
         Üldpind=as.numeric(sub(" m²", "", Üldpind)),
         Seisukord=as.factor(Seisukord),
         Energiamärgis=as.factor(ifelse(Energiamärgis=="-", NA, Energiamärgis)),
         Ehitusaasta=as.numeric(Ehitusaasta),
         Tüüp=as.factor(Tüüp),
         Korrus=as.numeric(Korrus),
         Korruseid=as.numeric(Korruseid))

# Data constraints and subsetting again
ads <- ads %>%
  mutate(Ehitusaasta=ifelse(Ehitusaasta > 1000, Ehitusaasta, NA),
         Üldpind=ifelse(Üldpind > 1000, NA, Üldpind)) %>%
  filter(Hind <= 10000000 & Hind >= 100)

# ---- Part-of-city detection, Tallinn ----
part_of_city <- ads %>%
  select(ID, Aadress) %>%
  filter(grepl("Tallinn", Aadress)) %>%  # Location is in Tallinn
  mutate(Haabersti=regexpr("Haabersti", Aadress),
         Kesklinn=regexpr("Kesklinn", Aadress),
         Kristiine=regexpr("Kristiine", Aadress),
         Lasnamäe=regexpr("Lasnamäe", Aadress),
         Mustamäe=regexpr("Mustamäe", Aadress),
         Nõmme=regexpr("Nõmme", Aadress),
         Pirita=regexpr("Pirita", Aadress),
         `Põhja-Tallinn`=regexpr("Põhja-Tallinn", Aadress),
         Vanalinn=regexpr("Vanalinn", Aadress)
  ) %>%
  melt(measure.vars=3:11, variable.name="Linnaosa", value.name="Positsioon") %>%
  # Assign only one part-of-city to each ad
  filter(Positsioon > -1) %>%
  group_by(ID, Linnaosa) %>%
  top_n(n=1, wt=Positsioon) %>%
  summarise()

# Join back part-of-city info
ads <- ads %>%
  right_join(part_of_city, by="ID")
  
# ---- Remove weird 'Seisukord' values ----
ads <- ads %>%
  filter(Seisukord != "post-USSR constructure")

# ---- Add index values ----
source("load_index.R")

# Get index of reference date
indeks_reference <- indeks_lookup %>%
  filter(Kuupäev == as.Date("2015-08-01")) %>%
  .[["Indeks"]]

# Calculate adjusted price
ads <- ads %>%
  left_join(indeks_lookup, by="Kuupäev") %>%
  mutate(HindKohandatud = (Hind * indeks_reference / Indeks))

# Select only useful variables and drop rows with missing data
cleaned <- ads %>%
  select(ID, Hind, HindKohandatud, Linnaosa, Üldpind, Seisukord, Tube, Korrus, Korruseid,
         Kuupäev) %>%
  na.omit()

# ---- Save ----
write.csv2(cleaned, "../data_cleaned/apartment_rent_tallinn.csv")


  