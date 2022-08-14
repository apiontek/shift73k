# Shift73k

Calendaring app for shift-worker shift tracking, with support for CSV export and sharing work schedule with others.

Written in Elixir & Phoenix LiveView, with Bootstrap v5.

## TODO

- [X] ~~*Proper modal to delete shifts?*~~ [2022-08-14]
- [ ] move runtime config out of compile-time config files, to move towards supporting releases
  - [ ] probably need to use `def get_app_config` style functions instead of `@module_var` module variables, ([see this](https://stephenbussey.com/2019/01/03/understanding-compile-time-dependencies-in-elixir-a-bug-hunt.html))
- [ ] Update tests, which are probably all way out of date. But I also don't care that much for this project...

## Deploying

I'm using a dumb & simple docker approach to deploying this now. Nothing automated, the basic steps are:

1. ensure latest assets are built, digested, and committed to the repo

    ```shell
    # rebuild static assets:
    rm -rf ./priv/static/*
    npm --prefix assets run build
    MIX_ENV=prod mix phx.digest
    # then do a new commit and push...
    ```

2. on server, build a new container, and run it

### Simple dockerfile

```dockerfile
# ./Dockerfile

# Extend from the official Elixir image
FROM elixir:1.13.4-otp-25-alpine

# # install the package postgresql-client to run pg_isready within entrypoint script
# RUN apt-get update && \
#   apt-get install -y postgresql-client

# Copy the entrypoint script
COPY ./entrypoint.sh /entrypoint.sh

# Create app directory and copy the Elixir projects into it
RUN mkdir /app
COPY ./app /app
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
CMD = ["/entrypoint.sh"]
```

### Simple entrypoint script

```shell
#!/bin/ash

export MIX_ENV="prod"

cd /app
exec mix ecto.migrate && mix phx.server
```
