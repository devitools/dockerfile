FROM devitools/node:12

ENV NODE_ENV production

RUN apt-get update \
  && apt-get install -y python py-pip \
  && rm -rf /var/lib/apt/lists/* \
  && python -m pip install awscli==1.19.0 \
  && npm install --global \
    @vue/cli@3.0.5 \
    @vue/cli-init@3.0.5
