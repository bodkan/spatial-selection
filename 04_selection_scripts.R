library(spammr)

model <- load("europe/")

# substitute parameters into the selection script template
selection_script <- script(
  system.file("extdata", "selection.slim", package = "spammr"),
  s = 0.1, # selection coefficient of an additive beneficial mutation
  freq = 0.1, onset = 29500, # initial frequency and time of onset (years ago)
  coord = convert(lat = 10, lon = 45, model), # location of origin
  origin = "pop"
)

# run the demographic model, including the selection component
run(
  model, burnin = 30, sim_length = 30000,
  recomb_rate = 0, seq_length = 100,
  max_distance = 50, max_spread = 5,
  include = selection_script,
  output_dir = "outputs"
)
