library(tidymodels)
library(brulee)

# ------------------------------------------------------------------------------

tidymodels_prefer()
theme_set(theme_bw())
options(pillar.advice = FALSE, pillar.min_title_chars = Inf)

# ------------------------------------------------------------------------------

set.seed(836)
sim_tr <-
 sim_regression(1e+08) %>%
 bind_cols(sim_noise(1e+08, num_vars = 500))

# ------------------------------------------------------------------------------

cpu_time <-
 system.time({
  cpu_fit <-
   brulee_mlp(outcome ~ ., data = sim_tr,
              hidden_units = 100, epochs = 500, stop_iter = 500)
 })

# ------------------------------------------------------------------------------

gpu_time <-
 system.time({
  gpu_fit <-
   brulee_mlp(outcome ~ ., data = sim_tr,
              hidden_units = 100, epochs = 500, stop_iter = 500,
              device = "mps")
 })

res <-
 tibble::tibble(
  seed = 836,
  n = 1e+08,
  extra_cols = 500,
  hidden_units = 100,
  epochs = 500,
  cpu = cpu_time[3],
  gpu = gpu_time[3]
 )

fl <- paste0("single_", 1e+08, "_", 500, "_", 100,
               "_", 500, ".RData")

save(res, file = fl)

sessioninfo::session_info()

if (!interactive()) {
 q("no")
}




