FROM node:12-alpine

RUN apk --update add openssh-client git

RUN npm install -g @vue/cli@3.0.5 && \
    npm install -g @vue/cli-init@3.0.5

RUN mkdir /home/node/app
USER root

VOLUME [ "/home/node/app" ]
WORKDIR /home/node/app

CMD /bin/sh
