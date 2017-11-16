# statsd_exporter
`statsd_exporter` is used to receive the metrics (in `statsd` format) from [`Envoy`](https://www.envoyproxy.io/docs/envoy/latest/operations/admin), 
and transform the metrics into [`Prometheus`](https://prometheus.io) format.

We will build a docker image for `stats_exporter` with some customerization:
* Providing a debug mode: log the number of metrics;
* Setting the default mapping for timer metrics to `Prometheus` histogram.

# Run the docker image

In debug mode:
```bash
docker run -d -p 8125:9125/udp -p 9102:9102 beekman9527/statsd_exporter --debug=true --interval=10
```
`interval=10` means that it will print the counter every 10 metrics.

In non-debug mode:
```bash
docker run -d -p 8125:9125/udp -p 9102:9102 beekman9527/statsd_exporter
```
