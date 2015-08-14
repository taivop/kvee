library(dplyr)
library(rvest)

source("scrape_fun.R")

id_start <- 2270360 # 01.01.2014
id_end   <- 2595000 # 11.08.2015

sprintf("Fetching ads...")
ads <- as.data.frame(scrape_page(id_start), stringsAsFactors=FALSE)
for(ad_id_reached in (id_start+1):id_end) {
  print(sprintf("Scraping %d (%d/%d)", ad_id_reached, ad_id_reached-id_start+1,
                id_end-id_start+1))
  Sys.sleep(0.05)
  tryCatch({
    ad <- scrape_page(ad_id_reached)
    names(ad) <- names(ads)
    ads <- rbind(ads, ad)
  }, error=function(e) {
    print(sprintf("Error at %d.", ad_id_reached))
  })
}
sprintf("Done.")

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

# Data boundaries
ads2 <- ads %>%
  mutate(Ehitusaasta=ifelse(Ehitusaasta < 1000, NA, Ehitusaasta),
         Üldpind=ifelse(Üldpind > 5000, NA, Üldpind))

# Save results
file_name <- sprintf("data_%dto%d_%s", id_start, ad_id_reached)
                     #gsub(" |:", "_", as.character(Sys.time())))
save(ads, id_start, id_end, ad_id_reached, file=file_name)



