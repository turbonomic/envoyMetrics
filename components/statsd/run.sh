#!/bin/bash

img=beekman9527/statsd
ports="-p 8125:8125/udp"
ports="$ports -p 8126:8126"

conf=`pwd`/conf
docker run -d $ports -v $conf:/etc/statsd/ $img
