library(tidyverse)
library(here)
library(purrr)

data_files <- fs::dir_ls(here("data", "e3", "raw_data", "BehavData"),
  glob = "*.csv"
)
choice_files <- fs::dir_ls(here("data", "e3", "raw_data", "ChoiceData"),
  glob = "*.csv"
)
estimation_files <- fs::dir_ls(here("data", "e3", "raw_data", "EstimationData"),
  glob = "*.csv"
)

unprocessed_data_df <- data_files %>%
  map_dfr(read_csv) %>%
  group_by(subnum) %>%
  mutate(fullTrial = row_number())

processed_data_df <- unprocessed_data_df %>%
  filter(fullTrial > 2, trials_since_break > 2, trialPropGoodSamples >= .25) %>%
  mutate(trial_label = case_when(
    trialType == 1 | trialType == 2 ~ "HV",
    trialType == 3 | trialType == 4 ~ "LV",
    trialType == 5 | trialType == 6 ~ "NV",
    trialType == 7 ~ "HV_v_LV",
    trialType == 8 ~ "HV_v_NV",
    trialType == 9 ~ "LV_v_NV"
  ))

choice_df <- choice_files %>%
  map_dfr(read_csv) %>%
  mutate(
    trial_label = case_when(
      testType == 1 | testType == 4 ~ "HV vs LV",
      testType == 2 | testType == 5 ~ "HV vs NV",
      testType == 3 | testType == 6 ~ "LV vs NV"
    ),
    choice_recoded = case_when(
      choice == 2 ~ 1,
      TRUE ~ -1
    )
  )

estimation_df <- estimation_files %>%
  map_dfr(read_csv) %>%
  mutate(d_type = factor(testType,
    levels = c(1, 2, 3),
    labels = c("HV", "LV", "NV")
  ))
