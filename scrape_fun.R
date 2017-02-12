library(dplyr)
library(rvest)
library(stringr)

get_coordinates = function(link) {
  page <- read_html("http://www.kv.ee/?act=object.map&object_id=2680423")
  js_text <- page %>% html_node("script") %>% html_text()
  coords <- str_extract(js_text, "(?=LatLng\\().*(?<=\\))") %>% str_sub(8, -2)
  return(coords)
}

scrape_page <- function(ad_id) {
  
  page <- read_html(sprintf("http://www.kv.ee/%d", ad_id))
  
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
    html_node("div.object-price strong") %>%
    html_text() %>%
    gsub("\\s+|€", "", .)
  
  # If coordinates exist
  ad$Koordinaadid <- NA
  tryCatch({
    gmap_link <- page %>%
      html_node("#gmap_img a") %>%
      html_attr("href")
    map_link = sprintf("http://kv.ee%s", gmap_link)
    ad$Koordinaadid <- get_coordinates(map_link)
  }, error=function(cond) {
  }, warning=function(cond) {
  }, finally={})
  
  table_rows <- page %>%
    html_nodes(".object-data-meta tbody tr")
  
  features <- list()
  for(trow in table_rows) {
    #print(trow %>% html_nodes("th"))
    feature_value <- trow %>% html_node("td") %>% html_text() %>%
      gsub("^\\s+|\\s+$", "", .) %>% gsub("\\s+", " ", .)
    #print(feature_value)
    if(feature_value == "Andmed kinnistusraamatust") {
      feature_name <- "KinnistuNr"
      lookup_link <- trow %>% html_node("td a") %>% html_attr("href")
      features[[feature_name]] <- str_extract(lookup_link, "(?<=ukn\\=)\\d*")
    } else if(feature_value == "Teata ebakorrektsest kuulutusest") {
      # Nothing to do here
    } else {
      feature_name <- trow %>% html_node("th") %>% html_text() %>%
        gsub("^\\s+|\\s+$", "", .) %>% gsub("\\s+", " ", .)
      features[[feature_name]] <- feature_value
    }
  }
  
  for(feature_name in c("Tube", "Üldpind", "Seisukord", "Energiamärgis",
                        "Ehitusaasta", "KinnistuNr")) {
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
  if(length(ad[["Kuupäev"]]) == 0) {
    ad[["Kuupäev"]] <- NA
  }
  
  # Address
  ad[["Aadress"]] <- regmatches(ad[["Pealkiri"]],
                                regexpr("(?<= - ).*(?= \\()", ad[["Pealkiri"]],
                                        perl=TRUE))
  
  if(length(ad[["Aadress"]]) == 0) { # Fallback in case we didn't get an address
    cna <- c(NA, NA, NA, NA)
    address_split <- list(cna, cna, cna, cna)
    ad["Aadress"] <- NA
  } else {
    address_split <- strsplit(ad[["Aadress"]], ", ")
  }

  for(i in 1:4) {
    if(length(address_split[[1]]) < 4) {
      print("replacing")
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
  