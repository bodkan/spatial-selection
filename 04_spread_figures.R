library(data.table)
library(ggplot2)

# get locations of neutral simulation outputs
list.files("results", "*.tsv.gz$", full.names = T)

pdf(file.path("figures", "neutral_spread.pdf"), width = 12, height = 8)

for (max_interaction in c(250, 500, 750, 1000)) {
  for (spread in c(25, 50, 75, 100)) {
    prefix <- sprintf("neutral_distance%d_spread%d", max_interaction, spread)
    f <- file.path("results/", paste0(prefix, "_ind_locations.tsv.gz"))

    locations <- fread(f)

    p <- ggplot(locations[t == 0], aes(x, y)) +
      geom_point(alpha = 0.5) +
      expand_limits(x = 0, y = 0) +
      theme_minimal() +
      ggtitle(sprintf("competition/mate choice interaction distance: %d km, parent-offspring distance: %d km", max_interaction, spread)) +
      labs(x = "x [pixel]", y = "y [pixel]")

    print(p)
  }
}

dev.off()
