### Replace State Abbreviation (Two letter abbreviation) with full name
setwd("/Users/williampang/Desktop/innovation_team_interview/medicaid_analysis")
library(tidyverse)

covid_19_mortality_rate_by_state <- read_csv("raw_data/covid19_mortality_by_state_2020_to_2022.csv")

state_abbreviations <- c("AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA",
                         "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD",
                         "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ",
                         "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC",
                         "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY", "District of Columbia")

state_names <- c("Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado",
                 "Connecticut", "Delaware", "Florida", "Georgia", "Hawaii", "Idaho",
                 "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine",
                 "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi",
                 "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey",
                 "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio",
                 "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina",
                 "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia",
                 "Washington", "West Virginia", "Wisconsin", "Wyoming", "District of Columbia")

state_map <- setNames(state_names, state_abbreviations)

covid_19_mortality_rate_by_state <- covid_19_mortality_rate_by_state %>%
  mutate(STATE = state_map[STATE])

# Write to CSV
write.csv(covid_19_mortality_rate_by_state, "covid_19_mortality_rate_by_state_2020_to_2022.csv", row.names = FALSE)