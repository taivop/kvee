library(readxl)
library(dplyr)

indeks <- read_excel("../indeks/kvindeks.xlsx") %>%
  select(Kuupäev, Indeks) %>%
  mutate(Kuupäev=as.Date(Kuupäev, "%d.%m.%y"),
         Indeks=as.numeric(Indeks))

indeks_lookup <- indeks

# For each index data point, create 6 more dates for lookup
for(shift in 1:6) {
  shifted <- indeks %>%
    mutate(Kuupäev=Kuupäev+shift)
  
  indeks_lookup <- rbind(indeks_lookup, shifted)
}