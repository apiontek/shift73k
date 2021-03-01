defmodule Bones73kWeb.AdminDashboardLive do
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
      <h1>Welcome to the admin dashboard!</h1>
    </section>
    """
  end
end
