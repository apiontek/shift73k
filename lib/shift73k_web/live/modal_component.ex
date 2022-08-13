defmodule Shift73kWeb.ModalComponent do
  use Shift73kWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id} class="modal fade"
      phx-hook="BsModal"
      phx-window-keydown="hide"
      phx-key="escape"
      phx-target={"#" <> to_string(@id)}
      phx-page-loading>

      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">

          <div class="modal-header">
            <h5 class="modal-title"><%= Keyword.get(@opts, :title, "Modal title") %></h5>
            <button type="button" class="btn-close" phx-click="hide" phx-target={@myself} aria-label="Close"></button>
          </div>

          <%= live_component @component, Keyword.put(@opts, :modal_id, @id) %>

        </div>
      </div>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    socket |> assign(assigns) |> live_okreply()
  end

  @impl true
  def handle_event("close", _, socket) do
    send(self(), {:close_modal, true})
    live_noreply(socket)
  end

  @impl true
  def handle_event("hide", _, socket) do
    socket |> push_event("modal-please-hide", %{}) |> live_noreply()
  end
end
