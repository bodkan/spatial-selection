#!/usr/bin/env bash

parallel -j30 'slim {} > results/{/.}.log' ::: slim/selection_*.slim
