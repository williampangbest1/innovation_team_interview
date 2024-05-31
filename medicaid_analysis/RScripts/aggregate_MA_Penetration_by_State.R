########################################################################################
# Purpose: To generate Medicare Advantage(MA) Penetration Statistics, by state
# Author: William Pang
# Source: CMS
#https://www.cms.gov/data-research/statistics-trends-and-reports/medicare-advantagepart-d-contract-\
#and-enrollment-data/ma-state/county-penetration
########################################################################################

setwd("/Users/williampang/Desktop/innovation_team_interview/medicaid_analysis")
library(tidyverse)

# Read in files
MA_2022_12 <- read_csv("raw_data/State_County_Penetration_MA_2022_12.csv")
# Recode * (which denotes less than 10 enrollees) into 0
MA_2022_12$Enrolled[MA_2022_12$Enrolled == "*"] <- "0"
MA_2022_12$Enrolled <- gsub(",", "", MA_2022_12$Enrolled)  
MA_2022_12$Enrolled <- as.numeric(MA_2022_12$Enrolled)


# Group by state and sum
MA_2022_12_by_state <- MA_2022_12 %>%
  group_by(`State Name`) %>%
  summarise(total_enrolled = sum(Enrolled, na.rm = TRUE),
            total_eligibles = sum(Eligibles, na.rm = TRUE))
MA_2022_12_by_state$Penetration = round(100*(MA_2022_12_by_state$total_enrolled/MA_2022_12_by_state$total_eligibles),2)
colnames(MA_2022_12_by_state) <- c("State", "total_enrolled", "total_eligible", "penetration")

# Write to CSV
write.csv(MA_2022_12_by_state, "MA_2022_12_by_state.csv", row.names = FALSE)