FROM ruby:2.4.0

RUN apt-get update

ENV SYSTEM_MODE development
ENV HOME=/opt/app/culturaaccesible-system

RUN mkdir -p $HOME
ADD . $HOME
WORKDIR $HOME
RUN gem install bundler
RUN bundle install
