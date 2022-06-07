FROM node:14

RUN mkdir -p /var/www/app \
  && chown -R node:node /var/www \
  && apt-get update \
  && apt-get install -y git openssh-client \
  && rm -rf /var/lib/apt/lists/* \
  && wget -O /tini https://github.com/krallin/tini/releases/download/v0.19.0/tini-static \
  && chmod +x /tini

WORKDIR /var/www/app

ENTRYPOINT ["/tini", "--"]
