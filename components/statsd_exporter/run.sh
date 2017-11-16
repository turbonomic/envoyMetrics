#!/bin/bash

# if it gets metrics from statsd, then forward port to 9125
#docker run -d -p 9125:9125/udp -p 9102:9102 beekman9527/statsd_exporter --debug=true --interval=10

# else, if it gets metrics directly from envoy, then forward port to 8125
docker run -d -p 8125:9125/udp -p 9102:9102 beekman9527/statsd_exporter --debug=true --interval=10

