library(afex)
library(emmeans)
library(BayesFactor)

source(here::here("preprocessing", "preprocessing_e2.R"))
source(here::here("other", "dz_calculator.R"))
source(here::here("other", "summarySEwithin2.R"))


single_df <- processed_data_df %>%
  filter(timeout == 0, trialType <= 6) %>%
  group_by(subnum, trial_label) %>%
  summarise(mean_gaze_on_dist = mean(omissionTrial1))

double_df <- processed_data_df %>%
  filter(timeout == 0, trialType > 6) %>%
  group_by(subnum, trial_label) %>%
  summarise(
    mean_gaze_on_d1 = mean(omissionTrial1),
    mean_gaze_on_d2 = mean(omissionTrial2)
  )

single_aov <- aov_ez(
  id = "subnum",
  dv = "mean_gaze_on_dist",
  within = "trial_label",
  data = single_df,
  anova_table = list(es = "pes")
)

single_posthoc <- emmeans(single_aov, ~trial_label)
single_posthoc_bonf <- pairs(single_posthoc, adj = "bonf")

dz_hv_lv <- dz_calculator(
  x = single_df %>% filter(trial_label == "HV") %>% pull(mean_gaze_on_dist),
  y = single_df %>% filter(trial_label == "LV") %>% pull(mean_gaze_on_dist)
)

dz_hv_nv <- dz_calculator(
  x = single_df %>% filter(trial_label == "HV") %>% pull(mean_gaze_on_dist),
  y = single_df %>% filter(trial_label == "NV") %>% pull(mean_gaze_on_dist)
)

dz_lv_nv <- dz_calculator(
  x = single_df %>% filter(trial_label == "LV") %>% pull(mean_gaze_on_dist),
  y = single_df %>% filter(trial_label == "NV") %>% pull(mean_gaze_on_dist)
)

bf_lv_nv <- ttestBF(
  x = single_df %>% filter(trial_label == "LV") %>% pull(mean_gaze_on_dist),
  y = single_df %>% filter(trial_label == "NV") %>% pull(mean_gaze_on_dist),
  paired = TRUE
)

# double distractor t tests
double_hv_lv <- t.test(
  x = double_df %>% filter(trial_label == "HV_v_LV") %>% pull(mean_gaze_on_d1),
  y = double_df %>% filter(trial_label == "HV_v_LV") %>% pull(mean_gaze_on_d2),
  paired = TRUE
)

double_dz_hv_lv <- dz_calculator(
  x = double_df %>% filter(trial_label == "HV_v_LV") %>% pull(mean_gaze_on_d1),
  y = double_df %>% filter(trial_label == "HV_v_LV") %>% pull(mean_gaze_on_d2)
)

double_hv_nv <- t.test(
  x = double_df %>% filter(trial_label == "HV_v_NV") %>% pull(mean_gaze_on_d1),
  y = double_df %>% filter(trial_label == "HV_v_NV") %>% pull(mean_gaze_on_d2),
  paired = TRUE
)

double_dz_hv_nv <- dz_calculator(
  x = double_df %>% filter(trial_label == "HV_v_NV") %>% pull(mean_gaze_on_d1),
  y = double_df %>% filter(trial_label == "HV_v_NV") %>% pull(mean_gaze_on_d2)
)

double_lv_nv <- t.test(
  x = double_df %>% filter(trial_label == "LV_v_NV") %>% pull(mean_gaze_on_d1),
  y = double_df %>% filter(trial_label == "LV_v_NV") %>% pull(mean_gaze_on_d2),
  paired = TRUE
)

double_dz_lv_nv <- dz_calculator(
  x = double_df %>% filter(trial_label == "LV_v_NV") %>% pull(mean_gaze_on_d1),
  y = double_df %>% filter(trial_label == "LV_v_NV") %>% pull(mean_gaze_on_d2)
)

double_bf_lv_nv <- ttestBF(
  x = double_df %>% filter(trial_label == "LV_v_NV") %>% pull(mean_gaze_on_d1),
  y = double_df %>% filter(trial_label == "LV_v_NV") %>% pull(mean_gaze_on_d2),
  paired = TRUE
)

# choice trials
choice_df_averaged <- choice_df %>%
  group_by(subnum, trial_label) %>%
  summarise(mean_choice = mean(choice_recoded))

wilcox_chce_HV_LV <- wilcox.test(x = choice_df_averaged %>%
  filter(trial_label == "HV vs LV") %>%
  pull(mean_choice), mu = 0)
z_chce_HV_LV <- qnorm(wilcox_chce_HV_LV$p.value / 2)
diff <- choice_df_averaged %>%
  filter(trial_label == "HV vs LV") %>%
  pull(mean_choice) - 0
diff <- diff[diff != 0]
diff.rank <- rank(abs(diff))
diff.rank.sign <- diff.rank * sign(diff)
ranks.pos <- sum(diff.rank.sign[diff.rank.sign > 0])
ranks.neg <- -sum(diff.rank.sign[diff.rank.sign < 0])

w_hv_lv <- min(c(ranks.pos, ranks.neg))

wilcox_chce_HV_NV <- wilcox.test(x = choice_df_averaged %>%
  filter(trial_label == "HV vs NV") %>%
  pull(mean_choice), mu = 0)
z_chce_HV_NV <- qnorm(wilcox_chce_HV_NV$p.value / 2)
diff <- choice_df_averaged %>%
  filter(trial_label == "HV vs NV") %>%
  pull(mean_choice) - 0
diff <- diff[diff != 0]
diff.rank <- rank(abs(diff))
diff.rank.sign <- diff.rank * sign(diff)
ranks.pos <- sum(diff.rank.sign[diff.rank.sign > 0])
ranks.neg <- -sum(diff.rank.sign[diff.rank.sign < 0])

w_hv_nv <- min(c(ranks.pos, ranks.neg))

wilcox_chce_LV_NV <- wilcox.test(x = choice_df_averaged %>%
  filter(trial_label == "LV vs NV") %>%
  pull(mean_choice), mu = 0)
z_chce_LV_NV <- qnorm(wilcox_chce_LV_NV$p.value / 2)
diff <- choice_df_averaged %>%
  filter(trial_label == "LV vs NV") %>%
  pull(mean_choice) - 0
diff <- diff[diff != 0]
diff.rank <- rank(abs(diff))
diff.rank.sign <- diff.rank * sign(diff)
ranks.pos <- sum(diff.rank.sign[diff.rank.sign > 0])
ranks.neg <- -sum(diff.rank.sign[diff.rank.sign < 0])

w_lv_nv <- min(c(ranks.pos, ranks.neg))

# estimation data

estimation_aov <- aov_ez(
  id = "subnum", dv = "estimate", within = "d_type", data = estimation_df,
  anova_table = list(es = "pes")
)

estimation_posthoc <- emmeans(estimation_aov, ~d_type)
estimation_posthoc_bonf <- pairs(estimation_posthoc, adj = "bon")

dz_estimate_hv_lv <- dz_calculator(
  x = estimation_df %>% filter(d_type == "HV") %>% pull(estimate),
  y = estimation_df %>% filter(d_type == "LV") %>% pull(estimate)
)

dz_estimate_lv_nv <- dz_calculator(
  x = estimation_df %>% filter(d_type == "LV") %>% pull(estimate),
  y = estimation_df %>% filter(d_type == "NV") %>% pull(estimate)
)

dz_estimate_hv_nv <- dz_calculator(
  x = estimation_df %>% filter(d_type == "HV") %>% pull(estimate),
  y = estimation_df %>% filter(d_type == "NV") %>% pull(estimate)
)

bf_estimate_hv_nv <- ttestBF(
  x = estimation_df %>% filter(d_type == "HV") %>% pull(estimate),
  y = estimation_df %>% filter(d_type == "NV") %>% pull(estimate),
  paired = TRUE
)
