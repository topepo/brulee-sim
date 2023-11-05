library(tidymodels)
library(brulee)

# ------------------------------------------------------------------------------

tidymodels_prefer()
theme_set(theme_bw())
options(pillar.advice = FALSE, pillar.min_title_chars = Inf)

# ------------------------------------------------------------------------------

set.seed(836)
sim_tr <-
 sim_regression(1e+06) %>%
 bind_cols(sim_noise(1e+06, num_vars = 100))

# ------------------------------------------------------------------------------

cpu_time <-
 system.time({
  cpu_fit <-
   brulee_mlp(outcome ~ ., data = sim_tr,
              hidden_units = 1000, epochs = 1000, stop_iter = 1000)
 })

# ------------------------------------------------------------------------------

gpu_time <-
 system.time({
  gpu_fit <-
   brulee_mlp(outcome ~ ., data = sim_tr,
              hidden_units = 1000, epochs = 1000, stop_iter = 1000,
              device = "mps")
 })

res <-
 tibble::tibble(
  seed = 836,
  n = 1e+06,
  extra_cols = 100,
  hidden_units = 1000,
  epochs = 1000,
  cpu = cpu_time[3],
  gpu = gpu_time[3]
 )

fl <- paste0("single_", 1e+06, "_", 100, "_", 1000,
               "_", 1000, ".RData")

save(res, file = fl)

sessioninfo::session_info()

if (!interactive()) {
 q("no")
}




