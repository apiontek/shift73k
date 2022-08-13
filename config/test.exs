import Config

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :shift73k, Shift73k.Repo,
  username: "postgres",
  password: "postgres",
  database: "shift73k_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :shift73k, Shift73kWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Swoosh test mailer config
config :shift73k, Shift73k.Mailer, adapter: Swoosh.Adapters.Test

# Import secret config
# import_config "test.secret.exs"
