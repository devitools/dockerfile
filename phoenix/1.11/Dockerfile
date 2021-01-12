FROM elixir:1.11

RUN mix local.hex --force \
  && mix archive.install --force hex phx_new 1.5.7 \
  && apt-get update \
  && curl -sL https://deb.nodesource.com/setup_12.x | bash \
  && apt-get install -y apt-utils \
  && apt-get install -y nodejs \
  && apt-get install -y build-essential \
  && apt-get install -y inotify-tools \
  && mix local.rebar --force

ENV WEB_ROOT /app
RUN mkdir -p $WEB_ROOT
WORKDIR $WEB_ROOT

EXPOSE 4000

CMD ["mix", "phx.server"]