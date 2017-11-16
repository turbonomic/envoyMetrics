# Envoy 
Here provides a way to build a customized docker image of `Envoy`, which can load specified configuration file.

`Envoy` can be deployed in two layers of the service mesh:
* Edege Envoy: which is deployed standalone (a pod of itself in k8s). edge Envoy is to give the rest of the world a single point of ingress. 

* Sevice Envoy: which is deployed along with each service instance (sidecar container with service container in k8s).

In this demo, `Envoy` will be deployed as a *Service Envoy*: proxy the service of the single App instance.

### configuration for envoy
In this demo, `Envoy` will work as a http proxy for our service. As a proxy, the configuration of it at least has two components:
* Network setting for incoming requests : which is about the `Listener` in Envoy's word.

* Address of the real service: how this proxy can access the service it proxies for. In Envoy's world, it is `Cluster`.

In addition, there are two more settings which is interesting in out demo:
* Address of statsd server: `Envoy` will send metrics to this [`statsd`](https://github.com/etsy/statsd) server.
   
   In this demo, we will replace `statsd` with a [`statsd_exporter`](https://github.com/songbinliu/statsd_exporter) server.

* Network settings of Admin interface: We can manage envoy through this interface, as well as to access some primitive metrics (not including the timer metrics).

[Here](https://www.datawire.io/guide/traffic/getting-started-lyft-envoy-microservices-resilience/) is a better explaination of the Envoy's configuration file.


#### Configuration for Listener

#### Configuration for cluster

#### Address of statsd

#### Configuration for the Admin interface


### build docker image of statsd

The `build.sh` script will build a docker image.

```bash
FROM lyft/envoy-alpine

COPY ./conf/envoy.json /etc/envoy/envoy.json

## listener port
EXPOSE 80

## admin port
EXPOSE 8001

ENTRYPOINT ["/usr/local/bin/envoy"]
CMD ["-c /etc/envoy/envoy.json", "-l debug"]
```


### run the docker image

```bash
conf=`pwd`/conf
docker run -d -p 9090:80 -p 8001:8001  -v $conf:/etc/envoy beekman9527/envoy 
```
Two ports shold be exposed:
  * Port(80) for listener: which is binded to host's port 9090. 
  * Port(8001) for admin: which is binded to host's port 8001; the metrics(timer metrics are not included) can be accessed through this port.
  
  ### Access the primitive metrics
  The primitive metrics can be access via http://localhost:8001/stats. However, it does not include the timer metrics, 
  which can be [accessed by `statsd_exporter`](https://github.com/songbinliu/envoyMetrics/tree/master/components/statsd_exporter).
  
  Here are some sample metrics about the metrics via http://localhost:8001/stats.
  ```terminal
  ...
cluster.cpu_mem_service.upstream_cx_http1_total: 420
cluster.cpu_mem_service.upstream_cx_http2_total: 0
cluster.cpu_mem_service.upstream_cx_max_requests: 0
cluster.cpu_mem_service.upstream_cx_none_healthy: 0
cluster.cpu_mem_service.upstream_cx_overflow: 0
cluster.cpu_mem_service.upstream_cx_protocol_error: 0
cluster.cpu_mem_service.upstream_cx_rx_bytes_buffered: 977
cluster.cpu_mem_service.upstream_cx_rx_bytes_total: 466105
cluster.cpu_mem_service.upstream_cx_total: 420
cluster.cpu_mem_service.upstream_cx_tx_bytes_buffered: 0
cluster.cpu_mem_service.upstream_cx_tx_bytes_total: 187938
cluster.cpu_mem_service.upstream_flow_control_backed_up_total: 0
cluster.cpu_mem_service.upstream_flow_control_drained_total: 0
cluster.cpu_mem_service.upstream_flow_control_paused_reading_total: 0
cluster.cpu_mem_service.upstream_flow_control_resumed_reading_total: 0
cluster.cpu_mem_service.upstream_rq_200: 954
cluster.cpu_mem_service.upstream_rq_2xx: 954
cluster.cpu_mem_service.upstream_rq_active: 0
cluster.cpu_mem_service.upstream_rq_cancelled: 0
cluster.cpu_mem_service.upstream_rq_maintenance_mode: 0
cluster.cpu_mem_service.upstream_rq_pending_active: 0
cluster.cpu_mem_service.upstream_rq_pending_failure_eject: 0
cluster.cpu_mem_service.upstream_rq_pending_overflow: 0
cluster.cpu_mem_service.upstream_rq_pending_total: 420
cluster.cpu_mem_service.upstream_rq_per_try_timeout: 0
cluster.cpu_mem_service.upstream_rq_retry: 0
cluster.cpu_mem_service.upstream_rq_retry_overflow: 0
cluster.cpu_mem_service.upstream_rq_retry_success: 0
cluster.cpu_mem_service.upstream_rq_rx_reset: 0
cluster.cpu_mem_service.upstream_rq_timeout: 0
cluster.cpu_mem_service.upstream_rq_total: 954
cluster.cpu_mem_service.upstream_rq_tx_reset: 0
cluster.cpu_mem_service.version: 0
cluster_manager.cluster_added: 1
cluster_manager.cluster_modified: 0
cluster_manager.cluster_removed: 0
cluster_manager.total_clusters: 1
...
 ```
  
 ### Provide the correct configuration for Envoy
 Two modifications before running the docker image of `conf/envoy.json`:
 * Set the correct App address [this line](https://github.com/songbinliu/envoyMetrics/blob/7667e5718bbb23ef2b81c1610d8868172d3d3db0/components/envoy/conf/envoy.json#L52): `localhost` will not work if the two containers are not running in the same k8s Pod.
 
 * Set the correct address of `statsd` (or `statsd_exporter`) in [this line](https://github.com/songbinliu/envoyMetrics/blob/master/components/envoy/conf/envoy.json#L42): `localhost` will not work if the containers are not running in the same k8s Pod.
 
 
 
