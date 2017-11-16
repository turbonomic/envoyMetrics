# envoyMetrics
In this project, We will demo how to expose the http response time in [Prometheus] format through [Envoy](https://www.envoyproxy.io).

This demo has three components: [App](https://github.com/songbinliu/envoyMetrics/tree/master/components/app), [Envoy](https://github.com/songbinliu/envoyMetrics/tree/master/components/envoy) and [statsd_exporter](https://github.com/songbinliu/envoyMetrics/tree/master/components/statsd_exporter). These three components will deployed in three docker containers.

Hwo to deploy this demo in Kubernetes can be found [here](https://github.com/songbinliu/envoyMetrics).

# Overview of the deployment of the demo
<img width="567" alt="envoy-metrics" src="https://user-images.githubusercontent.com/27221807/32904808-3db96434-cac6-11e7-8ed6-231f6166295c.png">
