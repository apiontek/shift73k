defmodule Shift73k.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Shift73k.Repo,
      # Start the Telemetry supervisor
      Shift73kWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Shift73k.PubSub},
      # Start the Endpoint (http/https)
      Shift73kWeb.Endpoint
      # Start a worker by calling: Shift73k.Worker.start_link(arg)
      # {Shift73k.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Shift73k.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Shift73kWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
