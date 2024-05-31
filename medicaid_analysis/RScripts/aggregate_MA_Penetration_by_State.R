########################################################################################
# Purpose: To generate Medicare Advantage(MA) Penetration Statistics, by state
# Author: William Pang
# Source: CMS
#https://www.cms.gov/data-research/statistics-trends-and-reports/medicare-advantagepart-d-contract-\
#and-enrollment-data/ma-state/county-penetration
########################################################################################

setwd("C:/Users/WPang/OneDrive - Apollo Medical Management/Projects/Medicaid")
library(tidyverse)

# Read in files
MA_2022_12 <- read_csv("State_County_Penetration_MA_2022_12.csv")
# Recode * into NA
MA_2022_12$Enrolled[MA_2022_12$Enrolled == "*"] <- NA


# Group by state and sum
MA_2022_12_by_state <- MA_2022_12 %>%
  group_by(`State Name`) %>%
  summarise(total_enrolled = sum(Enrolled, na.rm = TRUE),
            total_eligibles = sum(Eligibles, na.rm = TRUE))
