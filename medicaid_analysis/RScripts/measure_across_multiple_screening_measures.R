# Load libraries
library(tidyverse)
library(broom)

# Set Working Directory
setwd("/Users/williampang/Desktop/innovation_team_interview/medicaid_analysis")

###### Define Measures to Run ####
measure_names <- c("BCS-AD", "CCS-AD", "PPC-AD", "CHL-AD")
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
  
  ###
  # QA: Check to make sure each state only has one unique year 
  qaDistinctYear <- quality_measures_subset %>%
    group_by(state) %>%
    summarize(unique_years = n_distinct(ffy),
              row_count = n())
  
  different_rows <- qaDistinctYear %>% filter(unique_years != row_count)
  if (nrow(different_rows) == 0) {
    print("No rows with duplicate years.")
  }
  else{
  stop("Detected rows with duplicate years")
  }
  ###
  
  models <- quality_measures_subset %>%
    group_by(state) %>%
    do(model = lm(state_rate ~ reporting_date + postcovid + reporting_date * postcovid, data = .))
  
  # Extract coefficients from the models
  coefficients <- models %>%
    summarise(state = first(state),
              beta1 = coef(model)[2], 
              beta3 = ifelse(length(coef(model)) > 3, coef(model)[4], NA)) 
  
  # Remove rows with nulls and rank
  coefficients <- coefficients[!is.na(coefficients$beta3), ]
  coefficients$beta3rank <- rank(coefficients$beta3)
  
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

# Remove states with more than 1 measure being NA
na_count <- data.frame(store$state, cnt = rowSums(is.na(store)))
na_count <- na_count %>% filter(cnt > 4)
states_to_remove <- na_count$store.state
store <- store %>%
  filter(!state %in% states_to_remove)


# Rank average of ranks
store$final_ranking <- rank(store$mean_rank)

write.csv(store, "quality_measures_prepostcovid_rank.csv", row.names = FALSE)