library(gtsummary)
library(tidyverse)
library(car)
library(readxl)

# Table C Logistic Regressions

noah_gent_cd4 <- read.csv("C:/Users/Ethan/...gent_pat_cd4_final_060225.csv")
full395 <- read_xlsx("C:/Users/Ethan/...data.xlsx")
dat <- read.csv("C:/Users/Ethan/...gent_pat_cd4_geo_restr_051525.csv")

# View the loadings with a cutoff
#print(fit$loadings, digits = 2, cutoff = 0.3, sort = TRUE)


table(dat$ptsd_score)

dat_sub <- dat %>% dplyr::select(carc_study_id, ptsd_score)
full <- left_join(dat_sub, noah_gent_cd4, by = 'carc_study_id')

full$ptsd <- ifelse(full$ptsd_score>3,1,0)

full$pd_rate <- (full$patdown_count/full$pop)*10000
full$vc_rate <- (full$ViolentCrime_conf_count/full$pop)*10000


### check ML1 ML

sub <- full %>% dplyr::select(ML1, ML2,ulss1:ulss21)


### Model C

full_blk <- full %>% filter(race___4 == 1)

logistic_model_adj <- glm(
  ptsd ~ current_neighborhood_yrs +
    ML1 +  
    ML2 + as.factor(race___4) +  
    pd_call_010m + 
    vc_call_010m +
    age_current + 
    gender +
    as.factor(gen_cat18), 
  family = binomial(link = "logit"),
  data = full_blk
)

logistic_model_adj %>%
  tbl_regression(exponentiate = TRUE)


  
  ##
  
  logistic_model <- glm(
    ptsd ~ current_neighborhood_yrs +
      ML1 +  
      ML2 + as.factor(race___4) +
      pd_call_010m + 
      vc_call_010m +
      age_current + 
      gender +
      as.factor(gen_cat18), 
    family = binomial(link = "logit"),
    data = full
  )

logistic_model %>%
  tbl_regression(exponentiate = TRUE)


logistic_model <- glm(
  ptsd ~ current_neighborhood_yrs +
    ML1 +  
    ML2 + race___4 + 
    pd_call_025m +
    vc_call_025m +
    age_current + 
    gender +
    as.factor(gen_cat18), 
  family = binomial(link = "logit"),
  data = full
)

logistic_model %>%
  tbl_regression(exponentiate = TRUE)

logistic_model <- glm(
  ptsd ~ current_neighborhood_yrs +
    ML1 +  
    ML2 + race___4 +  
    pd_call_050m +
    vc_call_050m +
    age_current + 
    gender +
    as.factor(gen_cat18), 
  family = binomial(link = "logit"),
  data = full
)

logistic_model %>%
  tbl_regression(exponentiate = TRUE)



logistic_model <- glm(
  ptsd ~  
    pd_call_050m +
    vc_call_050m +
    age_current + 
    gender +
    as.factor(gen_cat18), 
  family = binomial(link = "logit"),
  data = full
)

logistic_model %>%
  tbl_regression(exponentiate = TRUE)



############

#Alt models 

logistic_model_adj <- glm(
  bi_dep ~ current_neighborhood_yrs +
    ML1 +  
    ML2 + as.factor(race___4) +  
    pd_rate +
    vc_rate +
    age_current + 
    gender +
    as.factor(gen_cat18), 
  family = binomial(link = "logit"),
  data = full
)

logistic_model_adj %>%
  tbl_regression(exponentiate = TRUE)

logistic_model <- glm(
  bi_dep ~ current_neighborhood_yrs +
    ML1 +  
    ML2 + as.factor(race___4) +
    pd_call_010m + 
    vc_call_010m +
    age_current + 
    gender +
    as.factor(gen_cat18), 
  family = binomial(link = "logit"),
  data = full
)

logistic_model %>%
  tbl_regression(exponentiate = TRUE)


logistic_model <- glm(
  bi_dep ~ current_neighborhood_yrs +
    ML1 +  
    ML2 + race___4 + 
    pd_call_025m +
    vc_call_025m +
    age_current + 
    gender +
    as.factor(gen_cat18), 
  family = binomial(link = "logit"),
  data = full
)

logistic_model %>%
  tbl_regression(exponentiate = TRUE)

logistic_model <- glm(
  bi_dep ~ current_neighborhood_yrs +
    ML1 +  
    ML2 + race___4 +  
    pd_call_050m +
    vc_call_050m +
    age_current + 
    gender +
    as.factor(gen_cat18), 
  family = binomial(link = "logit"),
  data = full
)

logistic_model %>%
  tbl_regression(exponentiate = TRUE)

vif(logistic_model)


### CD4 outcome 

table(full$cd4cat)

full$cd4_low <- ifelse(full$cd4cat==1,1,0)
full$cd4_med <- ifelse(full$cd4cat==3,0,1)


logistic_model_adj <- glm(
  cd4_med ~ current_neighborhood_yrs +
    ML1 +  
    ML2 + as.factor(race___4) +  
    pd_rate +
    vc_rate +
    age_current + 
    gender +
    as.factor(gen_cat18), 
  family = binomial(link = "logit"),
  data = full
)

logistic_model_adj %>%
  tbl_regression(exponentiate = TRUE)

logistic_model <- glm(
  cd4_med ~ current_neighborhood_yrs +
    ML1 +  
    ML2 + as.factor(race___4) +
    pd_call_010m + 
    vc_call_010m +
    age_current + 
    gender +
    as.factor(gen_cat18), 
  family = binomial(link = "logit"),
  data = full
)

logistic_model %>%
  tbl_regression(exponentiate = TRUE)


logistic_model <- glm(
  cd4_med ~ current_neighborhood_yrs +
    ML1 +  
    ML2 + race___4 + 
    pd_call_025m +
    vc_call_025m +
    age_current + 
    gender +
    as.factor(gen_cat18), 
  family = binomial(link = "logit"),
  data = full
)

logistic_model %>%
  tbl_regression(exponentiate = TRUE)

logistic_model <- glm(
  cd4_med ~ current_neighborhood_yrs +
    ML1 +  
    ML2 + race___4 +  
    pd_call_050m +
    vc_call_050m +
    age_current + 
    gender +
    as.factor(gen_cat18), 
  family = binomial(link = "logit"),
  data = full
)

logistic_model %>%
  tbl_regression(exponentiate = TRUE)

vif(logistic_model)
