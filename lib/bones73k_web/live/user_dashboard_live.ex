defmodule Bones73kWeb.UserDashboardLive do
  use Bones73kWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(socket, session)
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <section class="phx-hero">
      <h1>Welcome to the user dashboard!</h1>
    </section>
    """
  end
end
