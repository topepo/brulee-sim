library(tidymodels)
library(brulee)

# ------------------------------------------------------------------------------

tidymodels_prefer()
theme_set(theme_bw())
options(pillar.advice = FALSE, pillar.min_title_chars = Inf)

# ------------------------------------------------------------------------------

set.seed(930)
sim_tr <-
 sim_regression(1e+05) %>%
 bind_cols(sim_noise(1))

# ------------------------------------------------------------------------------

cpu_time <-
 system.time({
  cpu_fit <-
   brulee_mlp(outcome ~ ., data = sim_tr,
              hidden_units = 50, epochs = 1000, stop_iter = 1000)
 })[3]

# ------------------------------------------------------------------------------

gpu_time <-
 system.time({
  gpu_fit <-
   brulee_mlp(outcome ~ ., data = sim_tr,
              hidden_units = 50, epochs = 1000, stop_iter = 1000,
              device = "mps")
 })[3]

res <-
 tibble::tibble(
  seed = 930,
  n = 1e+05,
  extra_cols = 1,
  hidden_units = 50,
  epochs = 1000,
  cpu = cpu_time[3],
  gpu = gpu_time[3]
 )

fl <- paste0("single_", 1e+05, "_", 1, "_", 50,
               "_", 1000, ".RData")

save(res, file = fl)

sessioninfo::session_info()

if (!interactive()) {
 q("no")
}




