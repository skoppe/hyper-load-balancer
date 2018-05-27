FROM abiosoft/caddy:builder as builder

ARG version="0.11.0"
ARG plugins="cors,realip"

RUN VERSION=${version} PLUGINS=${plugins} ENABLE_TELEMETRY=false /bin/sh /usr/bin/builder.sh

FROM mhart/alpine-node:6.3
LABEL maintainer "Sebastiaan Koppe <mail@skoppe.eu>"

LABEL caddy_version="$version"

# Let's Encrypt Agreement
ENV ACME_AGREE="true"
ENV HYPER_REGION="eu-central-1"

# install caddy
COPY --from=builder /install/caddy /usr/bin/caddy

EXPOSE 80 443
WORKDIR /app

RUN apk --no-cache add ca-certificates

ADD package.json /app/package.json
RUN npm install

ADD Caddyfile.mustache /app/Caddyfile.mustache
ADD Procfile /app/Procfile
ADD start.sh /app/start.sh
ADD index.js /app/index.js

CMD npm run foreman
