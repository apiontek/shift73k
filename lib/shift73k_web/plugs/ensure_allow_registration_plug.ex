defmodule Shift73kWeb.EnsureAllowRegistrationPlug do
  @moduledoc """
  This plug ensures that there is at least one known User.
  """
  import Plug.Conn
  import Phoenix.Controller

  alias Shift73k.Repo
  alias Shift73k.Accounts.User

  @app_vars Application.compile_env(:shift73k, :app_global_vars, allow_registration: :true)
  @app_allow_registration @app_vars[:allow_registration]

  @doc false
  @spec init(any()) :: any()
  def init(config), do: config

  @doc false
  @spec call(Conn.t(), atom() | [atom()]) :: Conn.t()
  def call(conn, _opts) do
    # If there aren't even any users, or registration is allowed
    if !Repo.exists?(User) || @app_allow_registration do
      # We will allow registration
      conn
    else
      # Otherwise,
      # if app is configured to not allow registration,
      # and there is a user,
      # then we redirect to root URL
      conn
      |> redirect(to: "/")
      |> halt()
    end
  end
end
