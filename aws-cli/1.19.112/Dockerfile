FROM devitools/node:14

ENV NODE_ENV production

# https://pypi.org/project/awscli

RUN apt-get update \
  && apt-get install -y python python-pip \
  && rm -rf /var/lib/apt/lists/* \
  && python -m pip install awscli==1.19.112
