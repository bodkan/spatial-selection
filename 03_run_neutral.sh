#!/usr/bin/env bash

parallel -j 0 slim {} ::: slim/neutral_*.slim
