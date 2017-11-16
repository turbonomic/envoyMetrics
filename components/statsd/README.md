# statsd 
Envoy will send timer metrics (such as response time) to statsd.

**Update**: Since Envoy can send metrics directly to [`statsd_exporter`](https://github.com/songbinliu/statsd_exporter), we don't need `statsd` to get timer metrics.


Here provides a way to build statsd docker image and run the image.

### configuration
```yaml
{
 servers: [{server: "./servers/udp", address:"0.0.0.0", port: 8125}]
, backends: [ "./backends/repeater" ]
, debug: true
, repeater: [ { host: 'localhost', port: 9125} ]
, repeaterProtocol: "udp4"
}
```

 **servers**: define the port to receive metrics from Envoy.
 
      Here it will lisen on port 8125 for udp messages (metrics).
      
 **backends**: type of the backend. Here defines a repeater, `statsd` will send the received metrics to the repeater.
 
 **repater**: the server address of the repeater (`statsd_exporter`, or another `statsd` to receive the metrics).
     
      Here, statsd will send metrics to a repeater at *localhost:9125* through udp protocol.
      Note: make sure that the address and protocol of repeater is correct.


### build docker image of statsd

The `build.sh` script will build a docker image:
First, it will pull statsd from github.

Second, it will provide a customized config.js for statsd.

Third, expose the two ports: 
   * udp port 8125: to receive metrics from Envoy.
   * tcp port 8126: for management.

```bash
sh build.sh
```

### run the docker image

At least, one port shold be exposed:
  the port(8125/udp) to receive metrics, 

```bash
sh run.sh
```

