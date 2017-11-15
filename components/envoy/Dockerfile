FROM lyft/envoy-alpine

COPY ./conf/envoy.json /etc/envoy/envoy.json

## listener port
EXPOSE 80

## admin port
EXPOSE 8001

ENTRYPOINT ["/usr/local/bin/envoy"]
CMD ["-c /etc/envoy/envoy.json", "-l debug"]
