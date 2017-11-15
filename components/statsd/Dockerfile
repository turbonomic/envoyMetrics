FROM node:5-onbuild

COPY ./config.js /etc/statsd/config.js

EXPOSE 8125/udp
EXPOSE 8126
EXPOSE 9125/udp

ENTRYPOINT [ "node", "stats.js", "/etc/statsd/config.js" ]
