FROM ruby:3.1.2-slim-buster

RUN apt-get update -qq && apt-get install -y build-essential
# TODO remove when gem is published
RUN apt-get install -y git

RUN mkdir /app
WORKDIR /app
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install
COPY . /app

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
