defmodule Shift73kWeb.PropertyLive.Show do
  use Shift73kWeb, :live_view

  alias Shift73k.Properties
  alias Shift73kWeb.Roles

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(socket, session)
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    current_user = socket.assigns.current_user
    live_action = socket.assigns.live_action
    property = Properties.get_property!(id)

    if Roles.can?(current_user, property, live_action) do
      socket
      |> assign(:property, property)
      |> assign(:page_title, page_title(live_action))
      |> assign(:modal_return_to, Routes.property_show_path(socket, :show, property))
      |> live_noreply()
    else
      socket
      |> put_flash(:error, "Unauthorised")
      |> redirect(to: "/")
      |> live_noreply()
    end
  end

  @impl true
  def handle_info({:close_modal, _}, %{assigns: %{modal_return_to: to}} = socket) do
    socket |> copy_flash() |> push_patch(to: to) |> live_noreply()
  end

  @impl true
  def handle_info({:put_flash_message, {flash_type, msg}}, socket) do
    socket |> put_flash(flash_type, msg) |> live_noreply()
  end

  defp page_title(:show), do: "Show Property"
  defp page_title(:edit), do: "Edit Property"
end
