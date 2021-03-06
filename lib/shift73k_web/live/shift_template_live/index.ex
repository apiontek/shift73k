defmodule Shift73kWeb.ShiftTemplateLive.Index do
  use Shift73kWeb, :live_view

  alias Shift73k.ShiftTemplates
  alias Shift73k.ShiftTemplates.ShiftTemplate

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :shift_templates, list_shift_templates())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Shift template")
    |> assign(:shift_template, ShiftTemplates.get_shift_template!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Shift template")
    |> assign(:shift_template, %ShiftTemplate{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Shift templates")
    |> assign(:shift_template, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    shift_template = ShiftTemplates.get_shift_template!(id)
    {:ok, _} = ShiftTemplates.delete_shift_template(shift_template)

    {:noreply, assign(socket, :shift_templates, list_shift_templates())}
  end

  defp list_shift_templates do
    ShiftTemplates.list_shift_templates()
  end
end
