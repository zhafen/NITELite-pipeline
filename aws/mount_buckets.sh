#!/bin/bash

# Base directories
mkdir /data
mkdir /data/input
mkdir /data/output

# Specific input directories
mkdir /data/input/nitelite.referenced-images
mount-s3 nitelite.referenced-images /data/input/nitelite.referenced-images
mkdir /data/input/nitelite.metadata
mount-s3 nitelite.metadata /data/input/nitelite.metadata
mkdir /data/input/nitelite.images
mount-s3 nitelite.images /data/input/nitelite.images
mkdir /data/input/nitelite.pipeline-output
mount-s3 nitelite.pipeline-output /data/input/nitelite.pipeline-output