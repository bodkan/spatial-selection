#!/usr/bin/env bash

parallel -j5 'slim {} > results/{/.}.log' ::: slim/neutral_*.slim
