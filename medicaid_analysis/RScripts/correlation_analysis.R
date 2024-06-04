# Load libraries
library(tidyverse)
library(broom)

# Set Working Directory
setwd("/Users/williampang/Desktop/innovation_team_interview/medicaid_analysis")

quality_measures_ranking <- read_csv("quality_measures_prepostcovid_rank.csv")
quality_measures_ranking <- quality_measures_ranking[, c("state", "final_ranking")]


### Analysis 1: Correlate between Ranking and Medicaid Spending by State
medicaid_spending <- read_csv("Total_Medicaid_Spending_FY2022.csv")
medicaid_spending <- medicaid_spending[, c("State", "PMPY")]
medicaid_spending <- subset(medicaid_spending, State %in% quality_measures_ranking$state)
medicaid_spending$pmpy_rank <- rank(medicaid_spending$PMPY)

medicaid_spending_ranking <- inner_join(quality_measures_ranking, 
                                        medicaid_spending,
                                        by = c("state" = "State"))

result <- cor.test(medicaid_spending_ranking$final_ranking,
                   medicaid_spending_ranking$PMPY, method = "spearman")
print("***Analaysis 1 ***")
print(result$estimate)
print(result$p.value)

### Analysis 2: Correlate between Ranking and Medicare Advantage Penetration Rate
medicare_penetration <- read_csv("MA_Penetration_2022_12_by_state.csv")
medicare_penetration <- medicare_penetration[, c("State", "penetration")]
medicare_penetration <- subset(medicare_penetration, State %in% quality_measures_ranking$state)
medicare_penetration$penetration_rank <- rank(medicare_penetration$penetration)

medicare_penetration_ranking <- inner_join(quality_measures_ranking, 
                                        medicare_penetration,
                                        by = c("state" = "State"))

print("***Analaysis 2 ***")
result <- cor.test(medicare_penetration_ranking$final_ranking,
                   medicare_penetration_ranking$penetration, method = "spearman")
print(result$estimate)
print(result$p.value)

### Analysis 3: Correlate between Ranking and Medicaid Renewal Rate
medicaid_renewal <- read_csv("Medicaid_Renewal_Rate_05232024.csv")
medicaid_renewal <- medicaid_renewal[, c("State", "RenewalRate")]
medicaid_renewal <- subset(medicaid_renewal, State %in% quality_measures_ranking$state)
medicaid_renewal$renewalrate_rank <- rank(medicaid_renewal$RenewalRate)

medicaid_renewal_ranking <- inner_join(quality_measures_ranking, 
                                       medicaid_renewal,
                                           by = c("state" = "State"))

print("***Analaysis 3 ***")
result <- cor.test(medicaid_renewal_ranking$final_ranking,
                   medicaid_renewal_ranking$RenewalRate, method = "spearman")
print(result$estimate)
print(result$p.value)