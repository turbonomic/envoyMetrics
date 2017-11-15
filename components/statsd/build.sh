#!/bin/bash

img=beekman9527/statsd

git clone https://github.com/etsy/statsd.git

cd statsd
cp ../Dockerfile ./
cp ../config.js ./

docker build -t $img . 
