#!/usr/bin/env bash

parallel -j 8 slim {} ::: slim/neutral_*.slim
