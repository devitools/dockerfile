FROM mockoon/cli:8

EXPOSE 3000

COPY ./rxmg.json /data

CMD ["--data", "/data", "--port", "3000", "--hostname", "127.0.0.1", "0.0.0.0", "--log-transaction"]
