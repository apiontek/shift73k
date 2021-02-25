defmodule Bones73kWeb.LayoutView do
  use Bones73kWeb, :view

  def nav_link_opts(conn, opts) do
    case Keyword.get(opts, :to) == Phoenix.Controller.current_path(conn) do
      false -> opts
      true -> Keyword.update(opts, :class, "active", fn c -> "#{c} active" end)
    end
  end
end
