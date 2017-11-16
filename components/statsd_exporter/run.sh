#!/bin/bash

docker run -d -p 9125:9125/udp -p 9102:9102 beekman9527/statsd_exporter --debug=true
