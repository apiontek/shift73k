defmodule Shift73kWeb.LayoutView do
  use Shift73kWeb, :view

  alias Shift73k.Accounts.User
  alias Shift73kWeb.Roles

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
