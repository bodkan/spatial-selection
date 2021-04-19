It turned out to be quite a pain to install all compiled dependencies
of the *spammr* package on a computing cluster (I tried both our CPH
servers and MPI EVA servers).

In the meantime, while I'm working on that, I have added a new
functionality to the package which allows splitting the model
generating code (`01_define_model.R`) and SLiM script generating code
(`02_neutral_scripts.R`, `04_selection_scripts.R`) - both of which can
be run on any machine with a working *spammr* installation - from
actually running those simulations (`03_run_neutral.sh`,
`05_run_selection.sh`). The last part only requires working SLiM
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
