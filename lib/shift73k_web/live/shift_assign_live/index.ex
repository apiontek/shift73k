defmodule Shift73kWeb.ShiftAssignLive.Index do
  use Shift73kWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    socket
    |> assign_defaults(session)
    |> live_okreply()
  end
end
