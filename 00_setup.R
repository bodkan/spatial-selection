install.packages(c("devtools", "sf", "tidyverse"))
devtools::install_github("bodkan/spammr", ref = "d6f95bf")

# locations of generated SLiM scripts and output files
dir.create("slim/")
dir.create("results/")
dir.create("figures/")
