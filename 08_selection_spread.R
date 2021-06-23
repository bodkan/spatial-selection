# Plot snapshots of the spread of the beneficial allele through the population
# (not plotted with a map on the background because the geo-package I need for this
# doesn't work on the cluster... will happily create specific figures of this
# for the paper later)

library(spammr)
library(data.table)
library(ggplot2)
library(magrittr)

model <- read("model-europe/")

# maximum number of points to plot in each
# mutation-present/mutation-absent category
MAX_POINTS <- 1000

files <- list.files("results", "selection_.*_geolocations.tsv.gz$", full.names = T)

for (f in files) {
  message("Processing ", f)
  loc_df <- fread(f)

  all_times <- unique(loc_df$time)
  keep_times <- unique(c(all_times[1],
                         all_times[all_times %% 200 == 0],
                         all_times[length(all_times)]))

  s <- gsub("^.*selection_.*_s(.*)_time.*.tsv.gz", "\\1", f)
  t <- gsub("^.*selection_.*_s.*_time(.*)_ind.*.tsv.gz", "\\1", f)
  loc <- gsub("^.*selection_(.*)_s.*.tsv.gz", "\\1", f)

  pdf_path <- basename(f) %>%
    gsub("^selection_", "selection_spread_", .) %>%
    gsub("_ind_gt_geolocations.tsv.gz", "", .) %>%
    paste0("_3colors.pdf") %>%
    file.path("figures", .)

  pdf(pdf_path, width = 12, height = 8)

  for (tslice in keep_times) {

    p <- ggplot() +
      geom_sf(data = model$world) +
      coord_sf(crs = "EPSG:4326", xlim = c(-10, 75), ylim = c(30, 70)) +
      theme_minimal() +
      ggtitle(
        sprintf("20,000 individuals, origin: %s, selection coefficient: %s, time of origin: %s years ago", loc, s, t),
        subtitle = sprintf("time snapshot: %d years ago (maximum %dk out of 20k individuals shown for each genotype category)", tslice, MAX_POINTS / 1000)
      ) +
      labs(x = "longitude", y = "latitude") +
      guides(color = guide_legend("genotype")) +
      scale_color_manual(values = c("black", "blue", "red"),
                         labels = c("0/0", "0/1", "1/1"), drop = FALSE)
    
    # there's a bug in SLiM output code which doesn't always save all
    # individuals in the first generation
    present_df <- loc_df[time == tslice & gt > 0][
      sample(.N, if (.N > MAX_POINTS) MAX_POINTS else .N)]
    absent_df <- loc_df[time == tslice & gt == 0][
      sample(.N, if (.N > MAX_POINTS) MAX_POINTS else .N)]

    if (nrow(present_df) > 0) {
      p <- p + geom_point(data = present_df,
                          aes(lon, lat, color = factor(gt)), alpha = 0.75, size = 1)
    } else {
      warning(sprintf("Problem in time slice %d in file %s\n", tslice, f))
    }

    # if an allele is fixed, there won't be any "absent" cases
    if (nrow(absent_df) > 0) {
      p <- p + geom_point(data = absent_df,
                          aes(lon, lat, color = "0/1"), alpha = 0.5, size = 1)
    }

    print(p)

  }

  dev.off()
}
