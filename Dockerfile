FROM ruby:3.1.2 AS base

RUN apt-get update -qq && apt-get install -y nodejs default-mysql-client pv awscli
RUN apt-get install libjemalloc2 && rm -rf /var/lib/apt/lists/*
ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2


ENV GEM_PATH /bundle
ENV GEM_HOME /bundle
ENV BUNDLE_PATH /bundle

WORKDIR /app
COPY Gemfile Gemfile.lock ./


RUN bundle install

COPY . /app

FROM base AS server

CMD bundle install && bin/rails server -b 0.0.0.0
