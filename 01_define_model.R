devtools::install_github("bodkan/spammr", ref = "624b567")

library(spammr)

world <- map(
  xrange = c(-10, 65), # min-max longitude
  yrange = c(30, 67),  # min-max latitude
  crs = "EPSG:3035"    # real projected CRS used internally
)

# restrict individual movement only to this regions
europe <- region("Europe", world, coords = list(
  c(-8, 35), c(-5, 36), c(10, 38), c(20, 35), c(35, 30),
  c(60, 30), c(70, 40), c(80, 50), c(50, 70), c(40, 70),
  c(0, 70), c(-15, 50)
))

# create a single population
pop <- population(
  "pop", parent = "ancestor", N = 20000,
  world = world, region = europe
)

# compile the model specification and the single spatial map
model <- compile(
  pop,
  model_dir = "europe",
  resolution = 10, # 10 km per pixel
  gen_time = 30,   # 30 years per generation
  overwrite = TRUE
)
