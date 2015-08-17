library(dplyr)

ads <- read.csv2("data_out/combined.csv", quote="\"",
                 colClasses=c(NULL, "character", "character", NULL,
                              rep(c("character"), 16)))

# Fix data types
ads <- ads %>%
  mutate(Hind=as.numeric(Hind),
         Tube=as.numeric(Tube),
         Üldpind=as.numeric(sub(" m²", "", Üldpind)),
         Seisukord=as.factor(Seisukord),
         Energiamärgis=as.factor(ifelse(Energiamärgis=="-", NA, Energiamärgis)),
         Korrus=as.numeric(Korrus),
         Korruseid=as.numeric(Korruseid),
         Ehitusaasta=as.numeric(Ehitusaasta),
         Tüüp=as.factor(Tüüp),
         Kuupäev=as.Date(Kuupäev, "%d.%m.%y")) %>%
  mutate_each(funs(as.factor), Aadress.1:Aadress.4)

# Data constraints
ads <- ads %>%
  mutate(Ehitusaasta=ifelse(Ehitusaasta < 1000, NA, Ehitusaasta),
         Üldpind=ifelse(Üldpind > 5000, NA, Üldpind))