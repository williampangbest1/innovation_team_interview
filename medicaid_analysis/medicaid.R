# Load libraries
library(tidyverse)
library(broom)

# Set Working Directory
setwd("/Users/williampang/Desktop/innovation_team_interview/medicaid_analysis")

# Grab BCS Dataset
bcs <- read_csv("data/2014_to_2022_Child_and_Adult_Health_Care_Quality_Measures_Quality.csv")

bcs <- bcs[bcs$measure_abbreviation == 'BCS-AD', ]
bcs <- mutate(bcs, reporting_date = as.character(ffy + 1))
# Mathematica analysis of the Quality Measure Reporting (QMR) system reports for the FFY 2022 reporting cycle as of June 1, 2023.
bcs$reporting_date <- paste0(bcs$reporting_date, "-06-01")
bcs$reporting_date <- as.Date(bcs$reporting_date)

# Add indicator variable to distinguish between pre-covid and post-covid
bcs <- bcs %>%
  mutate(postcovid = ifelse(format(reporting_date, "%Y") > 2020, 1, 0))

models <- bcs %>%
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
bcs$postcovid <- as.factor(bcs$postcovid)

p <- ggplot(bcs, aes(x = reporting_date, y = state_rate, color = postcovid)) +
  ggtitle("Breast Cancer Screening Trends by State") +
  geom_point(color = 'black') +
  geom_smooth(method = 'lm') + 
  facet_wrap(~state, ncol = 5)

p + labs(x = "Year", y = "BCS State Rate")