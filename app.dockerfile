# BASIC INSTALL
FROM ruby:2.7.2
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs less

WORKDIR /app
COPY ./app /app
COPY ./ZscalerRootCertificate-2048-SHA256.crt /usr/local/share/ca-certificates/zscaler-root-ca.pem
    
