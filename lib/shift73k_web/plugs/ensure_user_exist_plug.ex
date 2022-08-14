defmodule Shift73kWeb.EnsureUserExistPlug do
  @moduledoc """
  This plug ensures that there is at least one known User.
  """
  import Plug.Conn
  import Phoenix.Controller

  alias Shift73k.Repo
  alias Shift73k.Accounts.User
  alias Shift73kWeb.Router.Helpers, as: Routes

  @doc false
  @spec init(any()) :: any()
  def init(config), do: config

  @doc false
  @spec call(Conn.t(), atom() | [atom()]) :: Conn.t()
  def call(conn, _opts) do
    # If there aren't even any users,
    if !Repo.exists?(User) do
      # We're just going to redirect to registration
      conn
      |> redirect(to: Routes.user_registration_path(conn, :new))
      |> halt()
    else
      # Otherwise we proceed as normal
      conn
    end
  end
end
