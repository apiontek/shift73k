# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :shift73k,
  ecto_repos: [Shift73k.Repo]

# Custom application global variables
config :shift73k, :app_global_vars,
  time_zone: "America/New_York",
  mailer_reply_to: "reply_to@example.com",
  mailer_from: "app_name@example.com"

# Configures the endpoint
config :shift73k, Shift73kWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "LdIQmzV5UCWSbB2SdiWFHLgxYNObKq9Za/VyguoILxfOAMDb5IsptKCKtXTRn+Tf",
  render_errors: [view: Shift73kWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Shift73k.PubSub,
  live_view: [signing_salt: "2D4GC4ac"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
