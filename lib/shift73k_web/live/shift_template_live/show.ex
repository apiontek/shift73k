defmodule Shift73kWeb.ShiftTemplateLive.Show do
  use Shift73kWeb, :live_view

  alias Shift73k.ShiftTemplates

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:shift_template, ShiftTemplates.get_shift_template!(id))}
  end

  defp page_title(:show), do: "Show Shift template"
  defp page_title(:edit), do: "Edit Shift template"
end
