defmodule Shift73kWeb.ModalComponent do
  use Shift73kWeb, :live_component

  @impl true
  def render(assigns) do
    ~L"""
    <div id="<%= @id %>" class="modal fade"
      phx-hook="BsModal"
      phx-window-keydown="hide"
      phx-key="escape"
      phx-target="#<%= @id %>"
      phx-page-loading>

      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">

          <div class="modal-header">
            <h5 class="modal-title"><%= Keyword.get(@opts, :title, "Modal title") %></h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>

          <%= live_component @socket, @component, @opts %>

        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("close", _, socket) do
    send(self(), {:close_modal, true})
    live_noreply(socket)
  end

  @impl true
  def handle_event("hide", _, socket) do
    {:noreply, push_event(socket, "modal-please-hide", %{})}
  end
end
