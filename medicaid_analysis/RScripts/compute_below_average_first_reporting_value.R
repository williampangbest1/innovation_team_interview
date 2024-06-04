library(tidyverse)

########## SET VARIABLES ########## 
measure_name = 'PPC-AD'
####################################   
quality_measures_ranking <- read_csv("quality_measures_prepostcovid_rank.csv")

allQualityData <- read_csv("2014_to_2022_Child_and_Adult_Health_Care_Quality_Measures_Quality.csv")
allQualityData <- subset(allQualityData, state %in% quality_measures_ranking$state)

measure <- allQualityData[allQualityData$measure_abbreviation == measure_name, ]

starting_vals <- measure %>% group_by(state) %>% arrange(reporting_date) %>% filter(row_number()==1)
alabama <- as.numeric(subset(starting_vals, state == "Alabama")$state_rate)
mean <- mean(as.numeric(starting_vals$state_rate))
print(alabama - mean)