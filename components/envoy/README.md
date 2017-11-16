# Envoy 
Here provides a way to build a customized docker image of `Envoy`, which can load specified configuration file.

`Envoy` can be deployed in two layers of the service mesh:
* Edege Envoy: which is deployed standalone (a pod of itself in k8s). edge Envoy is to give the rest of the world a single point of ingress. 

* Sevice Envoy: which is deployed along with each service instance (sidecar container with service container in k8s).

In this demo, `Envoy` will be deployed as a *Service Envoy*: proxy the service of the single App instance.

## Configuration for envoy
In this demo, `Envoy` will work as a http proxy for our service. As a proxy, the configuration of it at least has two components:
* Network setting for incoming requests : which is about the `Listener` in Envoy's word.

* Address of the real service: how this proxy can access the service it proxies for. In Envoy's world, it is `Cluster`.

In addition, there are two more settings which is interesting in out demo:
* Address of statsd server: `Envoy` will send metrics to the [`statsd`](https://github.com/etsy/statsd) server of this address.
   
   In this demo, we will replace `statsd` with a [`statsd_exporter`](https://github.com/songbinliu/statsd_exporter) server.

* Network settings of Admin interface: We can manage envoy through this interface, as well as to access some primitive metrics (not including the timer metrics).

[Here](https://www.datawire.io/guide/traffic/getting-started-lyft-envoy-microservices-resilience/) is a better explaination of the Envoy's configuration file.


#### Configuration for Listener

The listener will listen on port 80. It has a `http_connection_manager` is used to proxy the http requests.
`http_connection_manager` works on network level, but it can also understand http protocol (by translate the raw bytes into http level messages). 
More inforation about `http_connection_manager` can be found on [Envoy's online documentation](https://www.envoyproxy.io/docs/envoy/latest/configuration/http_conn_man/http_conn_man).

In the following configuration, `Envoy` will forward the http request on port 80 to a cluster with name `video_service`.


```json
"listeners": [
    {
      "address": "tcp://0.0.0.0:80",
      "filters": [
        {
          "name": "http_connection_manager",
          "config": {
            "codec_type": "auto",
            "stat_prefix": "ingress_http",
            "route_config": {
              "virtual_hosts": [
                {
                  "name": "service",
                  "domains": ["*"],
                  "routes": [
                    {
                      "timeout_ms": 0,
                      "prefix": "/",
                      "cluster": "video_service"
                    }
                  ]
                }
              ]
            },
            "filters": [
              {
                "type": "decoder",
                "name": "router",
                "config": {}
              }
            ]
          }
        }
      ]
    }
  ],
```

#### Configuration for cluster

In the `cluster_manager`, a cluster with name `video_service` is defined. `Envoy` will forward to the http requests to one of 
the `hosts` in this cluster. 

In this demo, we have only one app instance, so there is only one host in this cluster.

```json
"cluster_manager": {
    "clusters": [
      {
        "name": "video_service",
        "connect_timeout_ms": 8000,
        "type": "static",
        "lb_type": "round_robin",
        "hosts": [
          {
            "url": "tcp://10.10.200.43:8080"
          }
        ]
      }
    ]
  }
```

**NOTE**: change the `10.10.200.43:8080` to the app's real address, and make sure `Envoy` can access it.


#### Address of statsd
Envoy will send all the metrics, including the timer metrics to the `statsd`. In this demo, we will replace `statsd` with
[`statsd_exporter`](https://github.com/songbinliu/envoyMetrics/tree/master/components/statsd_exporter), for easier integration with `Prometheus`.

```json
  "statsd_udp_ip_address": "10.10.200.43:8125",
```
**NOTE**: change the `10.10.200.43:8125` to the real `statsd_exporter` address, and make sure `Envoy` can access it.


#### Configuration for the Admin interface

`Envoy` will listen on this interface for management, and expose some metrics.

```json
"admin": {
    "access_log_path": "/tmp/envoy-access-log",
    "address": "tcp://0.0.0.0:8001"
  },
```

This interface expose following information:

```terminal
envoy admin commands:
  /certs: print certs on machine
  /clusters: upstream cluster status
  /cpuprofiler: enable/disable the CPU profiler
  /healthcheck/fail: cause the server to fail health checks
  /healthcheck/ok: cause the server to pass health checks
  /hot_restart_version: print the hot restart compatability version
  /listeners: print listener addresses
  /logging: query/change logging levels
  /quitquitquit: exit the server
  /reset_counters: reset all counters to zero
  /routes: print out currently loaded dynamic HTTP route tables
  /server_info: print server version/status information
  /stats: print server stats
```


## Build docker image of envoy

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


## Run the docker image

Make sure change the [address of statsd](https://github.com/songbinliu/envoyMetrics/blob/7667e5718bbb23ef2b81c1610d8868172d3d3db0/components/envoy/conf/envoy.json#L42) and [address of app](https://github.com/songbinliu/envoyMetrics/blob/7667e5718bbb23ef2b81c1610d8868172d3d3db0/components/envoy/conf/envoy.json#L52) in `conf/envoy.json` before running the docker image.

```bash
conf=`pwd`/conf
docker run -d -p 9090:80 -p 8001:8001  -v $conf:/etc/envoy beekman9527/envoy 
```
Two ports shold be exposed:
  * Port(80) for listener: which is binded to host's port 9090. 
  * Port(8001) for admin: which is binded to host's port 8001; the metrics(timer metrics are not included) can be accessed through this port.
  
  ### Access the proxied service
  If everything is correct, the `video service` can be accessed through `Envoy` via `http://localhost:9090/workload.php/?value=100`.
  To access the `video service` directly, go `http://localhost:8080/workload.php/?value=100`.
  
  
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
 Two modifications to `conf/envoy.json` before running the docker image.
 
  * Set the correct [App address](https://github.com/songbinliu/envoyMetrics/blob/7667e5718bbb23ef2b81c1610d8868172d3d3db0/components/envoy/conf/envoy.json#L52)
 ```json
 "hosts": [
          {
            "url": "tcp://10.10.200.43:8080"
          }
        ]
 ```
 Change the `10.10.200.43:8080` to the address, that `Envoy` running in the container can access it.
 (`localhost` will not work if the containers are not running in the same k8s Pod.)
 
 
 * Set the correct [`statsd` (or `statsd_exporter`) address](https://github.com/songbinliu/envoyMetrics/blob/master/components/envoy/conf/envoy.json#L42)
 ```json
   "statsd_udp_ip_address": "10.10.200.43:8125",
 ```
 Change the `10.10.200.43:8125` to the address, that `Envoy` running in the container can access it.
 
 
