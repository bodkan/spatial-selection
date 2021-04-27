# This script converts raster-based coordinates (in pixels) into
# geographic coordinate system used by the diffusion model -
# i.e. (longitude, latitude) EPSG:4326/WGS-84 CRS

library(spammr)
library(data.table)
library(ggplot2)
library(foreach)
library(doParallel)

registerDoParallel(25) 

model <- read("model-europe/")

files <- list.files("results", "selection_.*_ind_gt_locations.tsv.gz$", full.names = T)

foreach (f = files) %dopar% {
  message("Processing ", f)

  loc_df <- fread(f)

  # "fix" a bug with SLiM keeping and saving data in some generation
  # from a previous incarnation before restarting due to allele loss
  # (by discarding everything prior to the first saved time point)
  gen_blocks <- rle(loc_df$gen < max(loc_df$gen))
  if (gen_blocks$values[1])
    loc_df <- loc_df[1:.N > gen_blocks$lengths[1]]

  loc_df[, time := gen * model$gen_time]

  loc_df <- convert(
    coords = loc_df,
    from = "raster", to = "EPSG:4326",
    model = model, add = T
  )

  # save the processed locations to a different file
  output_file <- gsub("_locations.tsv.gz", "_geolocations.tsv.gz", f)
  fwrite(loc_df, output_file, sep = "\t")
}
