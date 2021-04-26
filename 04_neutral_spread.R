library(spammr)
library(data.table)
library(ggplot2)
library(sf)

model <- load("model-europe/")

pdf(file.path("figures", "neutral_spread.pdf"), width = 12, height = 8)

for (max_interaction in c(250, 500, 750, 1000)) {
  for (spread in c(25, 50, 75, 100)) {

    max_interaction <- 250
    spread <- 25
    
    prefix <- sprintf("neutral_distance%d_spread%d", max_interaction, spread)
    f <- file.path("results/", paste0(prefix, "_ind_locations.tsv.gz"))

    loc_df <- fread(f)
    loc_df <- add_real_locations(loc_df, model)

    p <- ggplot(loc_df[t == 0], aes(x, y)) +
      geom_point(alpha = 0.5) +
      expand_limits(x = 0, y = 0) +
      theme_minimal() +
      ggtitle(sprintf("maximum competition/mate choice distance: %d km, parent-offspring distance distribution stdev.: %d km", max_interaction, spread)) +
      labs(x = "x [pixel]", y = "y [pixel]")

    q <- plot(model$world) +
      geom_point(data = loc_df[t == 0], aes(realx, realy)) +
      theme_minimal() +
      ggtitle(sprintf("maximum competition/mate choice distance: %d km, parent-offspring distance distribution stdev.: %d km", max_interaction, spread)) +
      labs(x = "longitude", y = "latitude")

    print(p)
  }
}

dev.off()

