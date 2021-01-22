FROM devitools/node:12

ENV NODE_ENV production

USER root

RUN apk add --update --no-cache \
        openssh-client \
        git \
        python \
        py-pip \
        && python -m pip install awscli==1.18.218 \
        && rm -rf /var/cache/apk/*

VOLUME [ "/home/node/app" ]
WORKDIR /home/node/app

CMD /bin/sh
