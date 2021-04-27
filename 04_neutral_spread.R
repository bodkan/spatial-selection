library(spammr)
library(data.table)
library(ggplot2)
library(sf)

model <- read("model-europe/")

pdf(file.path("figures", "neutral_spread.pdf"), width = 12, height = 8)

for (max_interaction in c(250, 500, 750, 1000)) {
  for (spread in c(25, 50, 75, 100)) {
    
    prefix <- sprintf("neutral_distance%d_spread%d", max_interaction, spread)
    f <- file.path("results/", paste0(prefix, "_ind_locations.tsv.gz"))

    loc_df <- fread(f)[t == 0]

    loc_df <- convert(
      coords = loc_df,
      from = "raster", to = "world",
      model = model,
      add = T
    )

    p <- plot(model$world) +
      geom_point(data = loc_df[t == 0], aes(newx, newy)) +
      theme_minimal() +
      ggtitle(sprintf("maximum competition/mate choice distance: %d km, parent-offspring distance distribution stdev.: %d km", max_interaction, spread)) +
      labs(x = "longitude", y = "latitude")

    print(p)
  }
}

dev.off()
