# BASIC INSTALL
FROM ruby:2.7.2
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs less

WORKDIR /app
COPY ./app /app
