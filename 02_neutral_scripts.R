# This script generates SLiM simulation scripts to explore the
# parameters influencing the spatial spread of individual across their
# population boundary. There are many ways how this could be
# parametrized, but here we are trying to find a combination of
# parameters that will lead to a "reasonably uniform" spread of
# individuals.

devtools::install_github("bodkan/spammr", ref = "624b567")

library(spammr)

model <- load("europe/")

# - max_distance is the parameter used in SLiM in this context:
#     initializeInteractionType(1, "xy", reciprocal=T, maxDistance=<<here>>)
#   which is discussed in detail in the SLiM manual (basically, it influences
#   the maximum spatial competition distances and mating choice distances)
# - max_spread
for (max_interaction in c(250, 500, 750, 1000)) {
  for (spread in c(25, 50, 75, 100)) {
    prefix <- sprintf("neutral_distance%d_spread%d", max_interaction, spread)
    run(
      model, burnin = 30, sim_length = 30000,
      recomb_rate = 0, seq_length = 1, # single locus
      max_interaction = max_interaction, spread = spread,
      save_locations = TRUE,
      output_prefix = file.path("results", prefix),
      script_path = file.path("slim", paste0(prefix, ".slim")),
      how = "dry-run"
    )
  }
}
