# FREEDOM HOUSE FREEDOM IN THE WORLD (fiw)
# 2014-09-03

# Source: http://www.freedomhouse.org/report-types/freedom-world#.VAdNqPk7u-M
# Click "Country ratings and status, FIW 1973-2014 (EXCEL)" to download

# Clear workspace
rm(list=ls(all=TRUE))

# Get working directory
wd <- getwd()

# Load requisite packages and functions
require(readxl)
require(reshape)
source("R/f.pitfcodeit.R")
source("R/f.countryyearrackit.R")

# Ingest and reshape data into desired country-year format
fiw <- read_excel("data.in/FH_Country_and_Territory_Ratings_and_Statuses_1972-2016.xls",
  sheet = 2, skip = 2)[1:212,]
fhyrs <- c(1972:1980,1982:2016)
var_years <- expand.grid(x=c('PR', 'CL', 'Status'), y = fhyrs)
names(fiw) <- c('country', paste(var_years$x, var_years$y, sep = "_"))
fiw_m <- melt(fiw, id = 'country')
fiw_m <- cbind(fiw_m, colsplit(fiw_m$variable, "_", names = c('indicator', 'year')))
fiw_m$variable <- NULL
fiw.pr <- subset(fiw_m, indicator=="PR")
fiw.pr$indicator <- NULL
names(fiw.pr) <- c("country", "fiw.pr", "year")
fiw.cl <- subset(fiw_m, indicator=="CL")
fiw.cl$indicator <- NULL
names(fiw.cl) <- c("country", "fiw.cl", "year")
fiw.status <- subset(fiw_m, indicator=="Status")
fiw.status$indicator <- NULL
names(fiw.status) <- c("country", "fiw.status", "year")
fiw <- merge(fiw.pr, fiw.cl)
fiw <- merge(fiw, fiw.status)
fiw$country <- as.character(fiw$country)
fiw$fiw.pr <- as.numeric(as.character(fiw$fiw.pr))
fiw$fiw.cl <- as.numeric(as.character(fiw$fiw.cl))
fiw$fiw.status <- as.character(fiw$fiw.status)
fiw$fiw.status[fiw$fiw.status==".."] <- fiw$fiw.status[fiw$fiw.status=="F (NF)"] <- NA

# Add PITF country codes for merging and get rid of country names
fiw <- pitfcodeit(fiw, "country")
fiw$country <- NULL

# Delete missing values
fiw <- na.omit(fiw)

write.csv(fiw, file = paste0(wd, "/data.out/fiw.csv"), row.names = FALSE)
