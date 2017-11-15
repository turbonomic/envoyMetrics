#!/bin/bash

#tag=beekman9527/envoy-debug
tag=beekman9527/envoy
docker build -t $tag .
docker push $tag
