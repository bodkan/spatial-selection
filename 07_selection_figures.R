# Plot snapshots of the spread of the beneficial allele through the population
# (not plotted with a map on the background because the geo-package I need for this
# doesn't work on the cluster... will happily create specific figures of this
# for the paper later)

library(data.table)
library(ggplot2)

GEN_TIME <- 30

# get locations of neutral simulation outputs
files <- list.files("results", "selection_.*_ind_gt_locations.tsv.gz$", full.names = T)

for (f in files) {
  loc_df <- fread(f)
  loc_df[, time := gen * GEN_TIME]

  all_times <- unique(loc_df$time)
  keep_times <- c(all_times[1], all_times[all_times %% 100 == 0])

  for (tslice in keep_times) {
    ggplot() +
      geom_point(data = loc_df[time == tslice & gt > 0],
                 aes(x, y, color = "present"), alpha = 1, size = 2) +
      geom_point(data = loc_df[time == tslice & gt == 0][sample(.N, 2000)],
                 aes(x, y, color = "absent"), alpha = 0.2, size = 1) +
      expand_limits(x = 0, y = 0) +
      theme_minimal() +
      ggtitle(
        sprintf("20,000 individuals, origin: %s, selection coefficient: %s, time of origin: %s years ago", loc, s, t),
        subtitle = sprintf("time snapshot: %d years ago", tslice)
      ) +
      labs(x = "x [pixel]", y = "y [pixel]") +
      guides(color = guide_legend("mutation"))
    ggsave(
      file.path("figures",
                paste0(gsub("_ind_gt_locations.tsv.gz", "", basename(f)), ".pdf")),
      width = 12, height = 8
    )
  }
}
