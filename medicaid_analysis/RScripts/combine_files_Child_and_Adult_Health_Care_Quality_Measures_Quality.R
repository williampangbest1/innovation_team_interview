########################################################################################
# Purpose: To merge Adult Healthcare Quality Measure Files together
# Author: William Pang
# Source: CMS
# https://www.medicaid.gov/medicaid/quality-of-care/performance-measurement/
# adult-and-child-health-care-quality-measures/adult-health-care-quality-measures/index.html
########################################################################################

setwd("/Users/williampang/Desktop/innovation_team_interview/innovation_team_interview/medicaid_analysis")
library(tidyverse)

# Define Function
tidy_table <- function(file, measure = NULL){
  cols_to_keep <- c("State", "Population", "Measure Abbreviation", "Median")
  
  file <- file[, cols_to_keep]
  file <- file[file$Population == "Medicaid", ]
  
  if (!is.null(measure)){
    file <- file[file$`Measure Abbreviation` == measure, ]
  }
    
  return(file)
}


# Read in files
file_2022 <- read_csv("raw_data/2022_Child_and_Adult_Health_Care_Quality_Measures_Quality.csv")
file_2022 <- tidy_table(file_2022)
file_2022$ffy <- "2022"

file_2021 <- read_csv("raw_data/2021_Child_and_Adult_Health_Care_Quality_Measures_Quality.csv")
file_2021 <- tidy_table(file_2021)
file_2021$ffy <- "2021"

file_2020 <- read_csv("raw_data/2020_Child_and_Adult_Health_Care_Quality_Measures_Quality.csv")
file_2020 <- tidy_table(file_2020)
file_2020$ffy <- "2020"

file_2019 <- read_csv("raw_data/2019_Child_and_Adult_Health_Care_Quality_Measures_Quality.csv")
file_2019 <- tidy_table(file_2019)
file_2019$ffy <- "2019"

file_2018 <- read_csv("raw_data/2018_Child_and_Adult_Health_Care_Quality_Measures_Quality.csv")
file_2018 <- tidy_table(file_2018)
file_2018$ffy <- "2018"

file_2017 <- read_csv("raw_data/2017_Child_and_Adult_Health_Care_Quality_Measures_Quality.csv")
file_2017 <- tidy_table(file_2017)
file_2017$ffy <- "2017"

file_2016 <- read_csv("raw_data/2016_Child_and_Adult_Health_Care_Quality_Measures_Quality.csv")
file_2016 <- tidy_table(file_2016)
file_2016$ffy <- "2016"

file_2015 <- read_csv("raw_data/2015_Child_and_Adult_Health_Care_Quality_Measures_Quality.csv")
file_2015 <- tidy_table(file_2015)
file_2015$ffy <- "2015"

file_2014 <- read_csv("raw_data/2014_Child_and_Adult_Health_Care_Quality_Measures_Quality.csv")
file_2014 <- tidy_table(file_2014)
file_2014$ffy <- "2014"

df_combined <- rbind(file_2014, file_2015, file_2016, file_2017, file_2018, file_2019,
                     file_2020, file_2021, file_2022)

# Write to CSV
write.csv(df_combined, "2014_to_2022_Child_and_Adult_Health_Care_Quality_Measures_Quality.csv", row.names = FALSE)