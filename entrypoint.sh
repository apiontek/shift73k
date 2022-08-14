#!/bin/ash

export MIX_ENV="prod"

cd /app
mix ecto.migrate
exec mix phx.server
