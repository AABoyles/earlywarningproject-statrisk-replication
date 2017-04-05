# ETHNIC FRACTIONALIZATION (elf)
# 2015-03-20

# Source: http://www.anderson.ucla.edu/faculty_pages/romain.wacziarg/papersum.html
# See Fractionalization Data link (http://www.anderson.ucla.edu/faculty_pages/romain.wacziarg/downloads/fractionalization.xls)

# Clear workspace
rm(list=ls(all=TRUE))

# Get working directory
wd <- getwd()

# Load required packages and functions
library('readxl')
source("R/f.countryyearrackit.R")
source("R/f.pitfcodeit.R")

# Ingest data
elf <- read_excel("data.in/fractionalization.xls",
  sheet = "Fractionalization Measures", skip = 3,
  col_names = c("country", "source", "year", "elf.ethnic", "elf.language", "elf.religion"),
  col_types = c("text", "text", "numeric", "numeric", "numeric", "numeric")
  )[1:215,] %>%
  select(-source)

# Add names, fix types, cut source, round, and add PITF codes
elf$elf.ethnic <- round(elf$elf.ethnic, 2)
elf$elf.language <- round(elf$elf.language, 2)
elf$elf.religion <- round(elf$elf.religion, 2)
elf <- pitfcodeit(elf, "country")
elf$sftgcode[elf$country=="Congo, Dem. Rep. (Zaire)"] <- "ZAI"
elf$sftgcode[elf$country=="Equatorial Guinea "] <- "EQG"
elf$sftgcode[elf$country=="Gambia, The "] <- "GAM"
elf$sftgcode[elf$country=="Lao People's Dem Rep"] <- "LAO"
elf$sftgcode[elf$country=="Lao People's Dem Rep"] <- "LAO"
elf$sftgcode[elf$country=="Macedonia (Former Yug. Rep)"] <- "MAC"
elf$sftgcode[elf$country=="Yugoslavia (pre 1991)"] <- "YUG"
elf$sftgcode[elf$country=="Serbia/Montenegro (Yugoslavia)"] <- "YGS"
elf <- subset(elf, is.na(elf$sftgcode)==FALSE, select = c(6,3:5))

# Write values to earlier versions of selected countries that split up
pks <- c("PKS", elf$elf.ethnic[elf$sftgcode=="PAK"], elf$elf.language[elf$sftgcode=="PAK"],
  elf$elf.religion[elf$sftgcode=="PAK"])
eti <- c("ETI", elf$elf.ethnic[elf$sftgcode=="ETH"], elf$elf.language[elf$sftgcode=="ETH"],
  elf$elf.religion[elf$sftgcode=="ETH"])
uss <- c("USS", elf$elf.ethnic[elf$sftgcode=="RUS"], elf$elf.language[elf$sftgcode=="RUS"],
  elf$elf.religion[elf$sftgcode=="RUS"])
elf <- as.data.frame(rbind(elf, pks, eti, uss))

# Fix variable types
elf$elf.ethnic <- as.numeric(elf$elf.ethnic)
elf$elf.language <- as.numeric(elf$elf.language)
elf$elf.religion <- as.numeric(elf$elf.religion)

# Put into country-year rack with 1950 as arbitrary start, last full year as end
rack <- merge(subset(pitfcodeit(countryyearrackit(1945,2014), "country"), select=c(sftgcode, year)), elf, all.x = TRUE)
rack <- rack[order(rack$sftgcode, rack$year),]

write.csv(rack, file = "data.out/elf.csv", row.names = FALSE)
