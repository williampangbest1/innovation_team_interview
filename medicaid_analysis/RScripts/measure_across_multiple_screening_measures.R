# Load libraries
library(tidyverse)
library(broom)

# Set Working Directory
setwd("/Users/williampang/Desktop/innovation_team_interview/medicaid_analysis")

###### Define Measures to Run ####
measure_names <- c("BCS-AD")
##################################

# Grab quality_measures dataset
quality_measures <- read_csv("2014_to_2022_Child_and_Adult_Health_Care_Quality_Measures_Quality.csv")
# Remove state rates with weird coding
quality_measures <- quality_measures[quality_measures$state_rate != "NR", ]
quality_measures <- quality_measures[quality_measures$state_rate != "DS", ]

iteration = 1
store <- data.frame()
for (measure in measure_names){
  quality_measures_subset <- quality_measures[quality_measures$measure_abbreviation == measure, ]
  
  models <- quality_measures_subset %>%
    group_by(state) %>%
    do(model = lm(state_rate ~ reporting_date + postcovid + reporting_date * postcovid, data = .))
  
  # Extract coefficients from the models
  coefficients <- models %>%
    summarise(state = first(state),
              beta1 = coef(model)[2], # reporting_date_coef
              beta3 = ifelse(length(coef(model)) > 3, coef(model)[4], NA)) # interaction_coef
  
  # Remove rows with nulls and rank
  coefficients <- coefficients[!is.na(coefficients$beta3), ]
  coefficients$beta3rank <- rank(-coefficients$beta3)
  
  # Rename
  beta1 <- paste0(measure, "_beta1")
  beta3 <- paste0(measure, "_beta3")
  beta3rank <- paste0(measure, "_beta3rank")
  
  colnames(coefficients) <- c("state", beta1, beta3, beta3rank)
  
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
beta3_rank_measure_names <- paste0(measure_names, "_beta3rank")
store$mean_rank <- rowMeans(store[beta3_rank_measure_names], na.rm = TRUE)

# Remove states with two small N
store <- store[store$state != "Delaware", ]
store <- store[store$state != "Maryland", ]
store <- store[store$state != "West Virginia", ]
store <- store[store$state != "Georgia", ]

# Rank average of ranks
store$final_ranking <- rank(store$mean_rank)

write.csv(store, "quality_measures_prepostcovid_rank.csv", row.names = FALSE)