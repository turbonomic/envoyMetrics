#!/bin/bash

conf=`pwd`/conf/
docker run -d -p 9090:80 -p 8001:8001  -v $conf:/etc/envoy beekman9527/envoy 
