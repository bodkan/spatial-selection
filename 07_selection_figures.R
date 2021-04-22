library(data.table)
library(ggplot2)

GEN_TIME <- 30

# get locations of neutral simulation outputs
files <- list.files("results", "selection_.*.tsv.gz$", full.names = T)

coefs <- unique(gsub("results\\/.*selection_.*_s(.*)_time.*.tsv.gz", "\\1", files))
times <- unique(gsub("results\\/.*selection_.*_s.*_time(.*)_ind.*.tsv.gz", "\\1", files))
locations <- unique(gsub("results\\/.*selection_(.*)_s.*.tsv.gz", "\\1", files))

i <- 1
s <- coefs[i]; t <- times[i]; loc <- "CentralEurope"

prefix <- sprintf("selection_%s_s%s_time%s", loc, s, t)
f <- file.path("results/", paste0(prefix, "_ind_gt_locations.tsv.gz"))
loc_df <- fread(f)

loc_df[, time := gen * GEN_TIME]

all_times <- unique(loc_df$time)
keep_times <- c(all_times[1], all_times[all_times %% 100 == 0])

pdf(file.path("figures", paste0(prefix, ".pdf")), width = 12, height = 8)
for (tslice in keep_times) {
  p <- ggplot() +
    geom_point(data = loc_df[time == tslice & gt > 0],
               aes(x, y, color = "present"), alpha = 1, size = 2) +
    geom_point(data = loc_df[time == tslice & gt == 0],
               aes(x, y, color = "absent"), alpha = 0.2, size = 1) +
    expand_limits(x = 0, y = 0) +
    theme_minimal() +
    ggtitle(
      sprintf("origin: %s, selection coefficient: %s, time of origin: %s years ago", loc, s, t),
      subtitle = sprintf("time snapshot: %d", tslice)
    ) +
    labs(x = "x [pixel]", y = "y [pixel]") +
    guides(color = guide_legend("mutation"))
  print(p)
}
dev.off()
