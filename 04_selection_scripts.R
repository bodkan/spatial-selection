# This script generates SLiM simulation scripts for generating data of
# the spread of a beneficial allele throughout a population. The
# parameters `max_distance` and `max_spread` were selected based on
# neutral simulation runs performed by `02_neutral_scripts.R` and
# `03_neutral_run.sh`.

#library(spammr)
devtools::load_all("~/projects/spammr")

model <- load("europe/")

# spatial distribution parameters established via `02_neutral_scripts.R`
max_interaction <- 500; spread <- 50

# iterate over:
# - selection coefficient (s) of the beneficial mutation
# - time of the appearance of the beneficial mutation (time, years ago)
for (s in c(0.01, 0.02, 0.03, 0.05, 0.1)) {
  for (time in c(20000, 15000, 10000, 5000)) {
    prefix <- sprintf("selection_s%.2f_time%d", s, time)

    # substitute parameters into the selection script template
    # (provided by the spammer R package)
    selection_script <- script(
      system.file("extdata", "selection.slim", package = "spammr"), 
      s = s, time = time,
      coord = convert(lat = 10, lon = 45, model), # location of origin
      origin = "pop"
    )

    run(
      model, sim_length = 30000,
      recomb_rate = 0, seq_length = 1, # single locus
      max_interaction = max_interaction, spread = spread,
      include = selection_script,
      output_prefix = file.path("results", prefix),
      script_path = file.path("slim", paste0(prefix, ".slim")),
      how = "dry-run"
    )
  }
}
