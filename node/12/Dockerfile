FROM node:12-alpine

RUN apk --update add openssh-client git

RUN mkdir /home/node/app
USER root

VOLUME [ "/home/node/app" ]
WORKDIR /home/node/app

CMD /bin/sh
