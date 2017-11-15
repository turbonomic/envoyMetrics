#!/bin/bash

img=beekman9527/statsd
ports="-p 8125:8125/udp"
ports="$ports -p 9125:9125/udp"
ports="$ports -p 8126:8126"

docker run -d $ports $img
