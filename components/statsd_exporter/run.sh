#!/bin/bash

image=beekman9527/statsd_exporter
conf=`pwd`/conf
# if it gets metrics from statsd, then it will listen on host port 9125. 
#    (statsd will listen on port 8125, and send metrics to port 9125.)
ports="-p 9125:9125/udp -p 9102:9102"
#docker run -d $ports -v $conf:/etc/statsd_exporter/ $image --debug=true --interval=10

# else, if it gets metrics directly from envoy, then it will listen on host port 8125.
#    (envoy will send metrics to port 8125.)
ports="-p 8125:9125/udp -p 9102:9102"
docker run -d  $ports -v $conf:/etc/statsd_exporter/ $image --debug=true --interval=10

