library(gtsummary)
library(tidyverse)
library(car)
library(glmmTMB)
library(readxl)
library(broom)
library(dplyr)
library(purrr)

# Table C Logistic Regressions -- PTSD symptomology outcome

noah_gent_cd4 <- read.csv("C:/Users/Ethan/Box/SJS EAS NOAH_POL_CD4/clean_data/gent_pat_cd4_final_060225.csv")
full395 <- read_xlsx("C:/Users/Ethan/Box/SJS EAS NOAH_POL_CD4/clean_data/Data.xlsx")
dat <- read.csv("C:/Users/Ethan/Box/SJS EAS NOAH_POL_CD4/clean_data/gent_pat_cd4_geo_restr_051525.csv")

# View the loadings with a cutoff
#print(fit$loadings, digits = 2, cutoff = 0.3, sort = TRUE)


# Merging NOAH Baseline with recoded set to get scales: 
dat_sub <- dat %>% dplyr::select(carc_study_id, ptsd_score)
full <- left_join(dat_sub, noah_gent_cd4, by = 'carc_study_id')

# Cutpoint of 3 
full$ptsd <- ifelse(full$ptsd_score>3,1,0)

# Census-tract based rates per 10k for police stops and violent crime rate (911 calls)
full$pd_rate <- (full$patdown_count/full$pop)*10000
full$vc_rate <- (full$ViolentCrime_conf_count/full$pop)*10000


### check ML1 ML

sub <- full %>% dplyr::select(ML1, ML2,ulss1:ulss21)


### Model C - crude 



crude_model <- function(pred){
  form <- as.formula(paste("ptsd ~", pred))
  
  glm(
    form,
    family = binomial(link = "logit"),
    data = full
  )
}

crude_model("current_neighborhood_yrs")

crude_pred <- c("current_neighborhood_yrs", "as.factor(age60)", "ML1", "ML2",
                "race___4", "gender", "as.factor(gen_cat18)",
                "pd_call_010m", "pd_call_025m", "pd_call_050m", "pd_rate", "vc_rate",
                "vc_call_010m", "vc_call_025m", "vc_call_050m", "ice_race",
                "ice_race_inc", "sdi")

crude_models <- lapply(crude_pred, crude_model)

crude_results <- map2_dfr(
  crude_models,
  crude_pred,
  ~ tidy(.x, conf.int = TRUE, exponentiate = TRUE) %>%
    mutate(predictor = .y)
)

crude_results


crude_table <- crude_results %>%
  filter(term != "(Intercept)") %>%
  mutate(
    OR_CI = sprintf("%.2f (%.2f, %.2f)",
                    estimate, conf.low, conf.high),
    p.value = round(p.value, 2)
  ) %>%
  select(predictor, term, OR_CI, p.value)

crude_table

#### Adjusted Model  - Individual 


logistic_model_adj <- glm(
  ptsd ~ ML1 + ML2 + pd_call_010m + vc_call_010m + as.factor(age60) + as.factor(gender) + as.factor(race___4), 
  family = binomial(link = "logit"),
  data = full
)

logistic_model_adj %>%
  tbl_regression(exponentiate = TRUE)

vif(logistic_model_adj)

#### Adjusted Model  - Census Tract  

logistic_model_adj <- glm(
  ptsd ~ pd_rate + vc_rate + ice_race + as.factor(gen_cat18), 
  family = binomial(link = "logit"),
  data = full
)

logistic_model_adj %>%
  tbl_regression(exponentiate = TRUE)


vif(logistic_model_adj)
summary(logistic_model_adj)

#### Adjusted Model  - Multilevel  

logistic_model_adj <- glm(
  ptsd ~ ML1 +  
    ML2  +  
    ice_race +
    pd_call_010m + 
    vc_call_010m +
    as.factor(age60) + 
    as.factor(race___4) + 
    gender +
    as.factor(gen_cat18), 
  family = binomial(link = "logit"),
  data = full
)

logistic_model_adj %>%
  tbl_regression(exponentiate = TRUE)

logistic_model_adj %>%
  tbl_regression(
    exponentiate = TRUE,
    estimate_fun = ~style_number(.x, digits = 6)
  )

summary(logistic_model_adj)
vif(logistic_model_adj)
