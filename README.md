It turned out to be quite a pain to install all compiled dependencies
of the *spammr* package on a computing cluster (I tried both our CPH
servers and MPI EVA servers).

In the meantime, while I'm working on that, I have added a new
functionality to the package which allows splitting the model
generating code (`01_define_model.R`) and SLiM script generating code
(`02_neutral_scripts.R`, `05_selection_scripts.R`) - both of which can
be run on any machine with a working *spammr* installation - from
actually running those simulations (`03_run_neutral.sh`,
`06_run_selection.sh`). The last part only requires working SLiM
installation and can be done on any cluster, even without *spammr*
being present.

One would ideally run everything from a single R script, but I guess
there are situations where the user would prefer to do things one step
at a time (such as in our case, where different phases need to be run
on different machines).

I will most definitely change this because I feel adding one
unnecessary step (i.e. separating the R code from runnig the
simulations from the generated SLiM code) actually hinders
reproducibility. However, for now I'm making this concession in order
to generate simulated data for the projet as quickly as possible.

(UPDATE: After hours of manually compiling C/C++ dependencies, my R package now finally runs on the computing nodes and splitting the R and SLiM phases into different scripts is no longer necessary. The R package can run everything in one go on our servers, but I kept things separated in individual scripts as it makes it a bit clearer as to what's going one when.)

## Output file format

The simulations were run across a grid of the following
scenarios/parameters:

- [location of origin](figures/selection_origins.pdf) of the beneficial allele: Iberia, Central Europe, Near East, Siberia
- time of the introduction of the beneficial allele: 20, 15, 10, and 5 thousand years ago
- selection coefficient: .001, .002, ..., .005 and .01, .02, ..., .05

Each simulation run for each combination of parameters has an associated output file in the `results/` directory. For instance, the file
`selection_CentralEurope_s0.001_time10000_ind_gt_geolocations.tsv.gz` is named using a scheme which directly indicates which parameters were used.

Each file has the following format (which is the same across all files):

```
gen     time    x       y       lon               lat               gt
166     4980    436.225 127.177 38.7392516237089  39.5905096971483  0
166     4980    583.393 160.759 55.6119814751389  35.861243630723   0
166     4980    258.109 249.061 19.8256830453205  54.3525408080406  0
166     4980    292.957 273.528 25.9056899989735  55.9514066710974  0
166     4980    177.917 147.215 7.89711409354133  45.5809315169121  0
166     4980    478.16  115.937 42.7785733753268  37.1586661103656  0
166     4980    496.111 99.198  43.9350053775148  35.1047195055321  0
166     4980    603.665 218.216 61.078230660545   38.7753640234362  0
166     4980    364.968 411.175 48.0583267462175  64.9588315247394  0
166     4980    596.997 139.377 55.7523302349701  33.5901839680292  0
```

Each row represents a single individual and the columns have the following meaning:

- `gen` and `time` indicate at which time point (in generations ago or years ago, respectively) was that individual sampled
- `x` and `y` specify the sampling location of that individual in raster-based coordinates (pixel "units") - note that the simulations were run on a map corresponding to the [ETRS89-extended / LAEA Europe](https://epsg.io/3035) projected coordinate reference system
- `lon` and `lat` columns indicate coordinates converted (see `07_convert_locations.R`) from the ETRS89-extended / LAEA Europe coordinates to geographical coordinate system (longitude and latitude)
- `gt` indicates genotype of each individual: `2` - homozygous carrier of the beneficial allele, `1` - heterozygote, `0` - individual carrying no copies of the beneficial allele

Note that the files are gigantic - the population has 20,000 individual and I saved the location of every individual that ever lived. This is on purpose - I figured you might want to make your own decisions as how to filter the data for testing (density of "ancient DNA sampling" etc.).

## Figures

The directory `figures/` contains many diagnostic plots I generated from the simulations. Most notably:

- [`figures/selection_origins.pdf`](figures/selection_origins.pdf) - where the beneficial allele was first introduced in different scenarios
- [`figures/neutral_spread.pdf`](figures/neutral_spread.pdf) - very rough evaluation of the parameters influencing how well spread or "clumpy" the individuals are across their spatial range
- `figures/selection_spread_*` - "animated" snapshots of the spread of the beneficial allele throughout the population over time (each file corresponds to one of the `results/selection_{location}_s{selection_coefficient}_time{time}_ind_gt_geolocations.tsv.gz` files described above)
- 
