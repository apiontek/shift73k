defmodule Shift73kWeb.LayoutView do
  use Shift73kWeb, :view

  alias Shift73k.Accounts.User
  alias Shift73kWeb.Roles

  # With a Vite.js-based workflow, we will import different asset files in development
  # and in production builds. Therefore, we will need a way to conditionally render
  # <script> tags based on Mix environment. However, since Mix is not available in
  # releases, we need to cache the Mix environment at compile time. To this end:
  @env Mix.env() # remember value at compile time
  def dev_env?, do: @env == :dev

  def nav_link_opts(conn, opts) do
    case Keyword.get(opts, :to) == Phoenix.Controller.current_path(conn) do
      false -> opts
      true -> Keyword.update(opts, :class, "active", fn c -> "#{c} active" end)
    end
  end

  def alert_kinds do
    [
      success: "alert-success",
      info: "alert-info",
      error: "alert-danger",
      warning: "alert-warning",
      primary: "alert-primary",
      secondary: "alert-secondary"
    ]
  end
end
