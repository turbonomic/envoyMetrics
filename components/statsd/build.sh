#!/bin/bash

git clone https://github.com/etsy/statsd.git

cd statsd
cp ../Dockerfile ./
cp ../config.js ./

set -x
img=beekman9527/statsd
docker build -t $img . 
