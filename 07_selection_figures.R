library(data.table)
library(ggplot2)

GEN_TIME <- 30

# get locations of neutral simulation outputs
files <- list.files("results", "selection_.*.tsv.gz$", full.names = T)

coefs <- unique(gsub("results\\/.*selection_.*_s(.*)_time.*.tsv.gz", "\\1", files))
times <- unique(gsub("results\\/.*selection_.*_s.*_time(.*)_ind.*.tsv.gz", "\\1", files))
locations <- unique(gsub("results\\/.*selection_(.*)_s.*.tsv.gz", "\\1", files))

s <- "0.050"; t <- times[1]; loc <- "CentralEurope"

prefix <- sprintf("selection_%s_s%s_time%s", loc, s, t)
f <- file.path("results/", paste0(prefix, "_ind_gt_locations.tsv.gz"))
loc_df <- fread(f)
loc_df[, gen := max(gen) - gen]
loc_df[, time := gen * GEN_TIME]
loc_df[, tblock := as.character(cut(time, breaks = seq(max(time), min(time), length.out = 20), dig.lab = 10))]
loc_df[is.na(tblock), tblock := "0"]

for (i in unique(loc_df$tblock)) {
  pdf(file.path("figures", paste0(prefix, "_", as.numeric(i), ".pdf")), width = 12, height = 8)
  p <- ggplot() +
    geom_point(data = loc_df[tblock == i & gt > 0], aes(x, y, color = "present"), alpha = 1, size = 2) +
#    geom_point(data = loc_df[tblock == i & gt == 0], aes(x, y, color = "absent"), alpha = 0.2, size = 0.5) +
    expand_limits(x = 0, y = 0) +
    theme_minimal() +
    ggtitle(sprintf("origin: %s, selection coefficient: %s, time of origin: %s years ago", loc, s, t), subtitle = sprintf("time block: %s", i)) +
    labs(x = "x [pixel]", y = "y [pixel]") +
    guides(color = guide_legend("mutation"))
  print(p)
  dev.off()
}
