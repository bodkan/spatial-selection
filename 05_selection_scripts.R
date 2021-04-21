# This script generates SLiM simulation scripts for generating data
# for the spread of a beneficial allele throughout a population. The
# parameters `max_interaction` and `spread` were selected based on
# neutral simulation runs performed by `02_neutral_scripts.R` and
# `03_run_neutral.sh`.

library(spammr)
library(sf)
library(magrittr)
library(ggplot2)

model <- load("model-europe/")

# define locations of origin of beneficial mutations
locations_df <- dplyr::tribble(
  ~name,          ~lon, ~lat,
  "Iberia",         -5,   40,
  "Central Europe", 10,   49,
  "Siberia",        75,   50,
  "Near East",      40,   38
)

# save the locations on a map of Europe
locations_sf <- locations_df %>%
  st_as_sf(coords = c("lon", "lat"), crs = 4326) %>%
  st_transform(crs = st_crs(model$world))
pdf(file.path("figures", "selection_origins.pdf"), width = 12, height = 8)
ggplot() +
  geom_sf(data = model$world) +
  geom_sf(data = locations_sf, aes(color = name), size = 5) +
  guides(color = guide_legend("")) +
  theme_minimal() +
  ggtitle("Locations of the origins of beneficial alleles")
dev.off()

# spatial distribution parameters established via `02_neutral_scripts.R`
max_interaction <- 250; spread <- 25

# iterate over:
# - selection coefficient (s) of the beneficial mutation
# - time of the appearance of the beneficial mutation (time, years ago)
# - locations of origins of the mutation
for (s in c(.001, .002, .003, .004, .005, .01, .02, .03, .04, .05)) {
  for (time in c(20000, 15000, 10000, 5000)) {
    for (i in 1:nrow(locations_df)) {
      prefix <- sprintf("selection_%s_s%.3f_time%d",
                        gsub(" ", "", locations_df[i, ]$name), s, time)

      # convert geographic coordinates into pixel coordinates
      lon <- locations_df[i, ]$lon
      lat <- locations_df[i, ]$lat
      coord <- convert(lat = lon, lon = lat, model)

      # substitute parameters into the selection script template
      # (provided by the spammer R package)
      selection_script <- script(
        system.file("extdata", "selection.slim", package = "spammr"), 
        s = s, time = time,
        coord = coord,
        origin = "pop"
      )

      # save the SLiM scripts for running on the computing node
      run(
        model, burnin = 1000, sim_length = time,
        recomb_rate = 0, seq_length = 1, # single locus
        max_interaction = max_interaction, spread = spread,
        output_prefix = file.path("results", prefix),
        script_path = file.path("slim", paste0(prefix, ".slim")),
        include = selection_script,
        how = "dry-run"
      )
    }
  }
}
