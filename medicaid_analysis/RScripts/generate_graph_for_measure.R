# Load libraries
library(tidyverse)
library(broom)

# Set Working Directory
setwd("/Users/williampang/Desktop/innovation_team_interview/medicaid_analysis")

########## SET VARIABLES ########## 
measure_name = 'BCS-AD'
new_name = "Breast Cancer Screening"
####################################   

generate_graph <- function(measure_name, new_name){
  # Grab BCS Dataset
  allQualityData <- read_csv("raw_data/2014_to_2022_Child_and_Adult_Health_Care_Quality_Measures_Quality.csv")
  measure <- allQualityData[allQualityData$measure_abbreviation == measure_name, ]
  
  # Process measure Datset
  measure <- mutate(measure, reporting_date = as.character(ffy + 1))
  # Techical Note: Mathematica analysis of the Quality Measure Reporting (QMR) system reports for 
  # the FFY 2022 reporting cycle as of June 1, 2023.
  measure$reporting_date <- paste0(measure$reporting_date, "-06-01")
  measure$reporting_date <- as.Date(measure$reporting_date)
  measure$state_rate <- as.numeric(measure$state_rate)
  
  
  # Add indicator variable to distinguish between pre-covid and post-covid
  measure <- measure %>%
    mutate(postcovid = ifelse(format(reporting_date, "%Y") > 2020, 1, 0))
  
  models <- measure %>%
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
  
  # Set Factor
  measure$postcovid <- as.factor(measure$postcovid)
  
  p <- ggplot(measure, aes(x = reporting_date, y = state_rate, color = postcovid)) +
    ggtitle(paste0(new_name, " Trends by State")) +
    geom_point(color = 'black') +
    geom_smooth(method = 'lm') + 
    facet_wrap(~state, ncol = 5) + 
    labs(x = "Year", y = paste0(measure_name, "State Rate"))
  
  return(p)
}

# Generate graph and save
png(filename = paste0("img/", measure_name, "_Trends_By_State.png"))
p <- generate_graph(measure_name, new_name)
p
dev.off()  # Close the device