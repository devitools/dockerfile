FROM devitools/node:12

RUN apk add --update --no-cache \
        openssh-client \
        git \
        python3 \
        py-pip \
        build-base \
    && pip install awscli==1.18.69 --upgrade --user \
    && apk --purge -v del py-pip \
    && rm -rf /var/cache/apk/*
