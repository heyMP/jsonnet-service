
FROM openfaas/of-watchdog:0.7.2 as watchdog

# Build jsonnet
FROM alpine:latest as jsonnet

RUN apk -U add build-base curl unzip --no-cache

WORKDIR /opt

RUN curl -sSL https://github.com/google/jsonnet/archive/v0.14.0.zip > jsonnet.zip
RUN unzip jsonnet.zip
RUN mv jsonnet-0.14.0 jsonnet

RUN cd jsonnet && \
    make

FROM node:10.12.0-alpine as ship

COPY --from=watchdog /fwatchdog /usr/bin/fwatchdog
RUN chmod +x /usr/bin/fwatchdog

RUN apk --no-cache add curl ca-certificates \
    && addgroup -S app && adduser -S -g app app

WORKDIR /root/

# Turn down the verbosity to default level.
ENV NPM_CONFIG_LOGLEVEL warn

RUN mkdir -p /home/app

# Wrapper/boot-strapper
WORKDIR /home/app
COPY package.json ./

# This ordering means the npm installation is cached for the outer function handler.
RUN npm i

# Copy outer function handler
COPY index.js ./

# COPY function node packages and install, adding this as a separate
# entry allows caching of npm install
WORKDIR /home/app/function
COPY function/*.json ./
RUN npm i || :

# COPY function files and folders
COPY function/ ./

# JSONNET
COPY --from=jsonnet /opt/jsonnet/jsonnet /usr/local/bin
COPY --from=jsonnet /opt/jsonnet/jsonnetfmt /usr/local/bin

# Set correct permissions to use non root user
WORKDIR /home/app/

# chmod for tmp is for a buildkit issue (@alexellis)
RUN chown app:app -R /home/app \
    && chmod 777 /tmp

USER app

ENV cgi_headers="true"
ENV fprocess="node index.js"
ENV mode="http"
ENV upstream_url="http://127.0.0.1:3000"

ENV exec_timeout="10s"
ENV write_timeout="15s"
ENV read_timeout="15s"

HEALTHCHECK --interval=3s CMD [ -e /tmp/.lock ] || exit 1

CMD ["fwatchdog"]

