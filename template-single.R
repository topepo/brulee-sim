library(tidymodels)
library(brulee)

# ------------------------------------------------------------------------------

tidymodels_prefer()
theme_set(theme_bw())
options(pillar.advice = FALSE, pillar.min_title_chars = Inf)

# ------------------------------------------------------------------------------

set.seed(SEED)
sim_tr <-
 sim_regression(NUM_ROWS) %>%
 bind_cols(sim_noise(NUM_EXTRA))

# ------------------------------------------------------------------------------

cpu_time <-
 system.time({
  cpu_fit <-
   brulee_mlp(outcome ~ ., data = sim_tr,
              hidden_units = UNITS, epochs = EPOCHS, stop_iter = EPOCHS)
 })[3]

# ------------------------------------------------------------------------------

gpu_time <-
 system.time({
  gpu_fit <-
   brulee_mlp(outcome ~ ., data = sim_tr,
              hidden_units = UNITS, epochs = EPOCHS, stop_iter = EPOCHS,
              device = "mps")
 })[3]

res <-
 tibble::tibble(
  seed = SEED,
  n = NUM_ROWS,
  extra_cols = NUM_EXTRA,
  hidden_units = UNITS,
  epochs = EPOCHS,
  cpu = cpu_time[3],
  gpu = gpu_time[3]
 )

fl <- paste0("single_", NUM_ROWS, "_", NUM_EXTRA, "_", UNITS,
               "_", EPOCHS, ".RData")

save(res, file = fl)

sessioninfo::session_info()

if (!interactive()) {
 q("no")
}




