# Incognia Demo API

[![Ruby](https://github.com/inloco/incognia-demo-api/actions/workflows/ci.yml/badge.svg)](https://github.com/inloco/incognia-demo-api/actions/workflows/ci.yml)

This is a sample API that uses [Incognia Ruby library](https://github.com/inloco/incognia-ruby) to easily integrate to Incognia API.
At this repository you can better understand how can you place Incognia inside your server.

## Available endpoints

This API responds to the below endpoints:

* Register signup: `POST /signups`
* Reassess signup: `GET /signups/:id`

## How to run this API locally?

### Application setup

The application requires Ruby 3.1.2. With this Ruby version in place, install `bundler` and run `bundle install` from the root of the repository.

To check if everything is fine, you can run the test suite with `rake spec`.

### Running with your organization credentials

1. Generate Incognia API credentials at Incognia dashboard
2. Set the `client_id` and `secret` at `.env` file
3. Run the server: `rails s` (API will listen at port 3000)

## How to run this API with Docker?

1. Generate Incognia API credentials at Incognia dashboard
2. Set the `client_id` and `secret` at `.env` file
1. Build the image running the follow command from repo root: `docker build . -t incognia-demo-api`
2. Run the image: `docker run -p 3000:3000 --env-file .env incognia-demo-api:latest` (API will listen at port 3000)
