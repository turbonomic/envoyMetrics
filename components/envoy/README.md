# Envoy 
Here provides a way to build envoy docker image, which can load our customized configuration file.

### build docker image of statsd

The `build.sh` script will build a docker image.

```bash
sh build.sh
```

### run the docker image

At least, two ports shold be exposed:
  the port(80) for listener, 
   and the port(8001) to access the metrics (timer metrics are not included).
```bash
sh run.sh
```

