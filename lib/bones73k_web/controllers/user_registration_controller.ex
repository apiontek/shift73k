defmodule Bones73kWeb.UserRegistrationController do
  use Bones73kWeb, :controller
  import Phoenix.LiveView.Controller

  def new(conn, _params) do
    live_render(conn, Bones73kWeb.UserLive.Registration)
  end
end
