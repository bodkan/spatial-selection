#!/usr/bin/env bash

rsync -avz --progress candy:~/shared/rasa/spatial-selection/results .
rsync -avz --progress candy:~/shared/rasa/spatial-selection/figures .
