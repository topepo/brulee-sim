library(tidymodels)
library(glue)
library(stringr)

# ------------------------------------------------------------------------------

tidymodels_prefer()
theme_set(theme_bw())
options(pillar.advice = FALSE, pillar.min_title_chars = Inf)

# ------------------------------------------------------------------------------

template <- readLines("template-single.R")

# ------------------------------------------------------------------------------

num_sim <- 3

set.seed(1)

combinations <-
 crossing(
  seed = sample.int(1000, num_sim),
  num_rows = 10^(6:8),
  num_extra = c(100, 500, 1000),
  units = c(10, 50, 100, 1000),
  epochs = c(100, 500, 1000)
  ) %>%
 mutate(
  chr_seed = format(1:1000)[seed],
  chr_seed = gsub(" ", "0", chr_seed),
  file = glue("files-single/sim_{num_rows}_{num_extra}_{units}_{epochs}.R")
 )

new_file <- function(x, template) {
 template <- gsub("SEED", x$seed, template)
 template <- gsub("NUM_ROWS", x$num_rows, template)
 template <- gsub("NUM_EXTRA", x$num_extra, template)
 template <- gsub("UNITS", x$units, template)
 template <- gsub("EPOCHS", x$epochs, template)
 cat(template, sep = "\n", file = x$file)
 invisible(NULL)
}

for (i in 1:nrow(combinations)) {
 new_file(combinations[i,], template)
}

# ------------------------------------------------------------------------------

r_files <- list.files("files-single", pattern = "*.R$")
cmds <- paste("R CMD BATCH --vanilla", r_files)

cat("#!/bin/sh\n", file = "files-single/run.sh")
cat(cmds, sep = "\n", file = "files-single/run.sh", append = TRUE)

# ------------------------------------------------------------------------------


