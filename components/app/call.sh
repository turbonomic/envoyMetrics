#!/bin/bash

#url=http://a57b092a7a93111e79ecb0615046e67d-1203545620.us-west-2.elb.amazonaws.com/cpuwork.php/?cpu=10
#url=http://localhost:9090/cpuwork.php/?cpu=10

## value=100, means the latency of this call is around 100 ms
url=http://localhost:9090/workload.php/?value=100

while true
do
    curl $url
    sleep 2
done

