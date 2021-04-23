# Plot the frequences of beneficial alleles over time, starting from
# different times of origins and different starting geographical
# locations

library(data.table)
library(ggplot2)
library(magrittr)
library(parallel)

GEN_TIME <- 30

# get locations of neutral simulation outputs
files <- list.files("results", "selection_.*_ind_gt_locations.tsv.gz$", full.names = T)

# read all simulated genotype tables and calculate allele frequency
# trajectories
traj_df <- mclapply(files, function(f) {
  gt <- fread(f)
  # convert times to years and add columns with simulation parametersn
  gt[, time := gen * GEN_TIME]
  gt[, s := gsub("^.*selection_.*_s(.*)_time.*.tsv.gz", "\\1", f)]
  gt[, origin_time := gsub("^.*selection_.*_s.*_time(.*)_ind.*.tsv.gz", "\\1", f)]
  gt[, origin_location := gsub("^.*selection_(.*)_s.*.tsv.gz", "\\1", f)]
  # calculate allele frequency over time
  gt[, .(frequency = mean(gt)), by = .(time, s, origin_time, origin_location)]
}, mc.cores = 30) %>%
  do.call(rbind, .)

traj_df[, origin_time := factor(
  origin_time,
  levels = sort(as.integer(unique(origin_time)))
)]

pdf(file.path("figures", "selection_trajectories.pdf"), width = 10, height = 7)

p <- ggplot(traj_df, aes(time, frequency, color = s)) +
  geom_line() +
  coord_cartesian(ylim = c(0, 1.0)) +
  xlim(max(traj_df$time), 0) +
  theme_minimal() +
  facet_grid(origin_location ~ origin_time) +
  labs(
    title = "Frequency trajectories of beneficial alleles",
    subtitle = "rows - locations of origin, columns - times of origin",
    y = "allele frequency",
    x = "time [years ago]"
  ) +
  guides(color = guide_legend(reverse = T))
print(p)

dev.off()
