defmodule Shift73kWeb.UserRegistrationController do
  use Shift73kWeb, :controller
  import Phoenix.LiveView.Controller

  def new(conn, _params) do
    live_render(conn, Shift73kWeb.UserLive.Registration)
  end
end
