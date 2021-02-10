FROM devitools/node:12

ENV NODE_ENV production

RUN apt-get update \
  && apt-get install -y python py-pip \
  && rm -rf /var/lib/apt/lists/* \
  && python -m pip install awscli==1.18.218
