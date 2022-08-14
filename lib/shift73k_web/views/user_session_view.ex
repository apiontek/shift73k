defmodule Shift73kWeb.UserSessionView do
  use Shift73kWeb, :view
  alias Shift73k.Accounts.User

  @app_vars Application.compile_env(:shift73k, :app_global_vars, allow_registration: :true)
  @app_allow_registration @app_vars[:allow_registration]

  def allow_registration, do: @app_allow_registration
end
