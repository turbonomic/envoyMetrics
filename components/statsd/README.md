# statsd 
Envoy will send timer metrics (such as response time) to statsd.

Here provides a way to build statsd docker image and run the image.

### build docker image of statsd

The `build.sh` script will build a docker image:
First, it will pull statsd from github.
Second, it will provide a customized config.js for statsd.
Third, expose the ports.

```bash
sh build.sh
```

### run the docker image

At least, two ports shold be exposed:
  the port(8125/udp) to receive metrics, 
   and the port(9125/udp) to access these metrics.

```bash
sh run.sh
```

