#!/usr/bin/env bash

parallel -j20 'slim {} > results/{/.}.log' ::: slim/selection_*.slim
