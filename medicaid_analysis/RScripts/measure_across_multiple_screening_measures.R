# Load libraries
library(tidyverse)
library(broom)

# Set Working Directory
setwd("/Users/williampang/Desktop/innovation_team_interview/medicaid_analysis")

# Grab quality_measures dataset
quality_measures <- read_csv("data/2014_to_2022_Child_and_Adult_Health_Care_Quality_Measures_Quality.csv")
# Remove weird coding
quality_measures <- quality_measures[quality_measures$state_rate != "NR", ]
quality_measures <- quality_measures[quality_measures$state_rate != "DS", ]

measure_names <- c("CHL-AD", "FUH-AD", "PPC-AD", "SSD-AD", "SAA-AD", "BCS-AD")

iteration = 1
for (measure in measure_names){
  quality_measures_subset <- quality_measures[quality_measures$measure_abbreviation == measure, ]
  quality_measures_subset <- mutate(quality_measures_subset, reporting_date = as.character(ffy + 1))
  # Mathematica analysis of the Quality Measure Reporting (QMR) system reports for the FFY 2022 reporting cycle as of June 1, 2023.
  quality_measures_subset$reporting_date <- paste0(quality_measures_subset$reporting_date, "-06-01")
  quality_measures_subset$reporting_date <- as.Date(quality_measures_subset$reporting_date)
  
  # Add indicator variable to distinguish between pre-covid and post-covid
  quality_measures_subset <- quality_measures_subset %>%
    mutate(postcovid = ifelse(format(reporting_date, "%Y") > 2020, 1, 0))
  
  models <- quality_measures_subset %>%
    group_by(state) %>%
    do(model = lm(state_rate ~ reporting_date + postcovid + reporting_date * postcovid, data = .))
  
  # Extract coefficients from the models
  coefficients <- models %>%
    summarise(state = first(state),
              # pre_covid_slope = coef(model)[2], # reporting_date_coef
              delta = ifelse(length(coef(model)) > 3, coef(model)[4], NA)) # interaction_coef
  
  # Remove rows with nulls and rank
  coefficients <- coefficients[!is.na(coefficients$delta), ]
  coefficients$rank <- rank(-coefficients$delta)
  
  # Rename
  delta_meaure <- paste0(measure, "_delta")
  rank_measure <- paste0(measure)
  
  colnames(coefficients) <- c("state", delta_meaure, rank_measure)
  
  if (iteration == 1){
    store <- coefficients
  }
  else {
    store <- full_join(store, coefficients, by = "state")
  }
  
  # Increment
  iteration = iteration + 1
}
  
# Average
store$mean_rank <- rowMeans(store[measure_names], na.rm = TRUE)

# Remove states with two small N
store <- store[store$state != "Delaware", ]
store <- store[store$state != "Maryland", ]
store <- store[store$state != "West Virginia", ]
store <- store[store$state != "Georgia", ]

# Rank average of ranks
store$final_ranking <- rank(store$mean_rank)

write.csv(store, "multiple_measures_rank.csv", row.names = TRUE)