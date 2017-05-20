FROM ruby:2.4.0

RUN mkdir -p /opt/app/culturaaccesible-system
ADD . /opt/app/culturaaccesible-system
WORKDIR /opt/app/culturaaccesible-system

ENV SYSTEM_MODE development

RUN apt-get update
RUN gem install bundler
RUN bundle install
