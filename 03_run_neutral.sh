#!/usr/bin/env bash

parallel -j8 'slim {} > results/{/.}.log' ::: slim/neutral_*.slim
