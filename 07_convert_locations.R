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
  loc_df <- convert(
    coords = loc_df,
    from = "raster", to = "EPSG:4326",
    model = model, add = T
  )

  # save the processed locations to a different file
  output_file <- gsub("_locations.tsv.gz", "_geolocations.tsv.gz", f)
  fwrite(loc_df, output_file, sep = "\t")
}
