FROM node:5-onbuild

COPY ./config.js /etc/statsd/config.js

EXPOSE 8125/udp
EXPOSE 8126

ENTRYPOINT [ "node", "stats.js", "/etc/statsd/config.js" ]
