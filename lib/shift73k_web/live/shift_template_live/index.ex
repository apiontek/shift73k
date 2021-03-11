defmodule Shift73kWeb.ShiftTemplateLive.Index do
  use Shift73kWeb, :live_view

  alias Shift73k.ShiftTemplates
  alias Shift73k.ShiftTemplates.ShiftTemplate
  alias Shift73kWeb.Roles

  @impl true
  def mount(_params, session, socket) do
    # {:ok, assign(socket, :shift_templates, list_shift_templates())}
    socket
    |> assign_defaults(session)
    |> live_okreply()
  end

  @impl true
  def handle_params(params, _url, socket) do
    current_user = socket.assigns.current_user
    live_action = socket.assigns.live_action
    shift_template = shift_template_from_params(params)

    if Roles.can?(current_user, shift_template, live_action) do
      socket
      |> assign_shift_templates()
      |> assign(:modal_return_to, Routes.shift_template_index_path(socket, :index))
      |> assign(:delete_shift_template, nil)
      |> apply_action(socket.assigns.live_action, params)
      |> live_noreply()
    else
      socket
      |> put_flash(:error, "Unauthorised")
      |> redirect(to: "/")
      |> live_noreply()
    end
  end

  defp apply_action(socket, :clone, %{"id" => id}) do
    socket
    |> assign(:page_title, "Clone Shift Template")
    |> assign(:shift_template, ShiftTemplates.get_shift_template!(id))
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Shift Template")
    |> assign(:shift_template, ShiftTemplates.get_shift_template!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Shift Template")
    |> assign(:shift_template, %ShiftTemplate{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Shift templates")
    |> assign(:shift_template, nil)
  end

  defp assign_shift_templates(socket) do
    %User{id: uid} = socket.assigns.current_user
    user_shifts = ShiftTemplates.list_shift_templates_by_user_id(uid)
    assign(socket, :shift_templates, user_shifts)
  end

  defp shift_template_from_params(params)

  defp shift_template_from_params(%{"id" => id}),
    do: ShiftTemplates.get_shift_template!(id)

  defp shift_template_from_params(_params), do: %ShiftTemplate{}

  @impl true
  def handle_event("delete-modal", %{"id" => id}, socket) do
    {:noreply, assign(socket, :delete_shift_template, ShiftTemplates.get_shift_template!(id))}
  end

  # @impl true
  # def handle_event("delete", %{"id" => id}, socket) do
  #   shift_template = ShiftTemplates.get_shift_template!(id)
  #   {:ok, _} = ShiftTemplates.delete_shift_template(shift_template)

  #   {:noreply, assign_shift_templates(socket)}
  # end

  @impl true
  def handle_info({:close_modal, _}, %{assigns: %{modal_return_to: to}} = socket) do
    socket |> copy_flash() |> push_patch(to: to) |> live_noreply()
  end

  @impl true
  def handle_info({:put_flash_message, {flash_type, msg}}, socket) do
    socket |> put_flash(flash_type, msg) |> live_noreply()
  end
end
