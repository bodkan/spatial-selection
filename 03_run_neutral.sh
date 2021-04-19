#!/usr/bin/env bash

parallel -j 1 slim {} ::: slim/neutral_*.slim
