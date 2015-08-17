library(dplyr)
library(rvest)

scrape_page <- function(ad_id) {
  page <- html(sprintf("http://www.kv.ee/%d", ad_id))
  
  # Parse data points
  ad <- list()
  
  ad$ID <- ad_id
  
  ad$Pealkiri <- page %>%
    html_node("h1.title") %>%
    html_text() %>%
    gsub("\"", " ", .)
  
  ad$Tekst <- page %>%
    html_node(".object-article-body") %>%
    html_text() %>%
    gsub("\\s+", " ", .) %>%
    gsub("\"", " ", .)
  
  ad$Hind <- page %>%
    html_node("p.object-price strong") %>%
    html_text() %>%
    gsub("\\s+|€", "", .)
  
  table_rows <- page %>%
    html_nodes(".object-data-meta tbody tr")
  
  features <- list()
  for(trow in table_rows) {
    if(!is.null(trow %>% html_node("th"))) {
      feature_name <- trow %>% html_node("th") %>% html_text() %>%
        gsub("^\\s+|\\s+$", "", .) %>% gsub("\\s+", " ", .)
      feature_value <- trow %>% html_node("td") %>% html_text() %>%
        gsub("^\\s+|\\s+$", "", .) %>% gsub("\\s+", " ", .)
      features[[feature_name]] <- feature_value
    }
  }
  
  for(feature_name in c("Tube", "Üldpind", "Seisukord", "Energiamärgis",
                        "Ehitusaasta")) {
    if(is.null(features[[feature_name]]))
       ad[[feature_name]] <- NA
    else
      ad[[feature_name]] <- features[[feature_name]]
  }
  
  # Type of ad
  ad[["Tüüp"]] <- names(features)[[1]]
  
  # Floors
  ad[["Korrus"]] <- ifelse(is.null(features[["Korrus/Korruseid"]]),
                           NA,
                           strsplit(features[["Korrus/Korruseid"]], "/")[[1]][1])
  ad[["Korruseid"]] <- ifelse(is.null(features[["Korrus/Korruseid"]]),
                           NA,
                           strsplit(features[["Korrus/Korruseid"]], "/")[[1]][2])
  
  # Date of ad
  ad[["Kuupäev"]] <- regmatches(ad[["Pealkiri"]],
                                regexpr("(\\d\\d\\.\\d\\d\\.\\d\\d)",
                                        ad[["Pealkiri"]]))
  
  # Address
  ad[["Aadress"]] <- regmatches(ad[["Pealkiri"]],
                                regexpr("(?<= - ).*(?= \\()", ad[["Pealkiri"]],
                                        perl=TRUE))
  address_split <- strsplit(ad[["Aadress"]], ", ")
  address_split
  for(i in 1:4) {
    if(length(address_split[[1]]) < 4) {
      address_split[[1]] <- c(rep(c(NA), 4-length(address_split[[1]])), address_split[[1]])
    }
    field_name <- sprintf("Aadress.%d", i)
    if(!is.na(address_split[[1]][i]))
      ad[[field_name]] <- address_split[[1]][i]
    else
      ad[[field_name]] <- NA
  }
  
  return(ad)
}
  