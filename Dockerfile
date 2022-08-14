# ./Dockerfile

# Extend from the official Elixir image
FROM elixir:1.13.4-otp-25-alpine

# # install the package postgresql-client to run pg_isready within entrypoint script
# RUN apt-get update && \
#   apt-get install -y postgresql-client

# Create app directory and copy the Elixir project into it
RUN mkdir /app
COPY . /app
WORKDIR /app

# Install the build tools we'll need
RUN apk update && \
  apk upgrade --no-cache && \
  apk add --no-cache \
    build-base && \
  mix local.rebar --force && \
  mix local.hex --force


# The environment to build with
ENV MIX_ENV=prod

# Get deps and compile
RUN mix do deps.get, deps.compile, compile

# Start command
CMD = ["/app/entrypoint.sh"]
