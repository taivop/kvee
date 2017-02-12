library(dplyr)
library(reshape2)

ads_raw <- read.csv2("../data_out/combined.csv", colClasses="character")

# Select subset of ads and columns
ads <- ads_raw %>%
  mutate(Kuupäev=as.Date(Kuupäev, "%d.%m.%y")) %>%
  filter(Kuupäev >= as.Date("2012-01-01") &
           Tüüp == "Anda üürile korter") %>%
  filter(grepl("Tartu", Aadress)) %>%
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
  filter(Hind <= 10000 & Hind >= 100)

# ---- Part-of-city detection, Tartu ----
part_of_city <- ads %>%
  select(ID, Aadress) %>%
  filter(grepl("Tartu", Aadress)) %>%
  mutate(Annelinn=regexpr("Annelinn", Aadress),
         Ihaste=regexpr("Ihaste", Aadress),
         Jaamamõisa=regexpr("Jaamamõisa", Aadress),
         Karlova=regexpr("Karlova", Aadress),
         Kesklinn=regexpr("Kesklinn", Aadress),
         Maarjamõisa=regexpr("Maarjamõisa", Aadress),
         `Raadi-Kruusamäe`=regexpr("Raadi-Kruusamäe", Aadress),
         Ropka=regexpr("Ropka", Aadress),
         `Ropka tööstusrajoon`=regexpr("Ropka tööstusrajoon", Aadress),
         Ränilinn=regexpr("Ränilinn", Aadress),
         Supilinn=regexpr("Supilinn", Aadress),
         Tammelinn=regexpr("Tammelinn", Aadress),
         Tähtvere=regexpr("Tähtvere", Aadress),
         Vaksali=regexpr("Vaksali", Aadress),
         Variku=regexpr("Variku", Aadress),
         Veeriku=regexpr("Veeriku", Aadress),
         Ülejõe=regexpr("Ülejõe", Aadress)
         ) %>%
  melt(measure.vars=3:19, variable.name="Linnaosa", value.name="Positsioon") %>%
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

indeks_lookup <- indeks_lookup %>%
  rename(Kuupaev=Kuupäev)

# Calculate adjusted price
ads <- ads %>%
  rename(Kuupaev=Kuupäev) %>%
  left_join(indeks_lookup, by="Kuupaev") %>%
  mutate(HindKohandatud = (Hind * indeks_reference / Indeks)) %>%
  rename(Kuupäev=Kuupaev)
# Select only useful variables and drop rows with missing data
cleaned <- ads %>%
  select(ID, Hind, HindKohandatud, Linnaosa, Üldpind, Seisukord, Tube, Korrus, Korruseid,
         Kuupäev) %>%
  na.omit()

# ---- Save ----
write.csv2(cleaned, "../data_cleaned/apartment_rent_tartu.csv")


