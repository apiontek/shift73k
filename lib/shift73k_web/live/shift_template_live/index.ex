defmodule Shift73kWeb.ShiftTemplateLive.Index do
  use Shift73kWeb, :live_view

  alias Shift73k.Accounts
  alias Shift73k.Shifts.Templates
  alias Shift73k.Shifts.Templates.ShiftTemplate
  alias Shift73kWeb.Roles

  @impl true
  def mount(_params, session, socket) do
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
      |> assign_modal_close_handlers()
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

  defp assign_modal_close_handlers(socket) do
    to = Routes.shift_template_index_path(socket, :index)
    assign(socket, modal_return_to: to, modal_close_action: :return)
  end

  defp apply_action(socket, :clone, %{"id" => id}) do
    socket
    |> assign(:page_title, "Clone Shift Template")
    |> assign(:shift_template, Templates.get_shift_template!(id))
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Shift Template")
    |> assign(:shift_template, Templates.get_shift_template!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Shift Template")
    |> assign(:shift_template, %ShiftTemplate{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "My Shift Templates")
    |> assign(:shift_template, nil)
  end

  defp assign_shift_templates(socket) do
    %User{id: uid} = socket.assigns.current_user
    user_shifts = Templates.list_shift_templates_by_user(uid)
    assign(socket, :shift_templates, user_shifts)
  end

  defp shift_template_from_params(params)

  defp shift_template_from_params(%{"id" => id}),
    do: Templates.get_shift_template!(id)

  defp shift_template_from_params(_params), do: %ShiftTemplate{}

  @impl true
  def handle_event("delete-modal", %{"id" => id}, socket) do
    socket
    |> assign(:modal_close_action, :delete_shift_template)
    |> assign(:delete_shift_template, Templates.get_shift_template!(id))
    |> live_noreply()
  end

  @impl true
  def handle_event("set-user-fave-shift-template", %{"id" => shift_template_id}, socket) do
    user_id = socket.assigns.current_user.id
    Accounts.set_user_fave_shift_template(user_id, shift_template_id)

    socket
    |> assign(:current_user, Accounts.get_user!(user_id))
    |> assign_shift_templates()
    |> live_noreply()
  end

  @impl true
  def handle_event("unset-user-fave-shift-template", _params, socket) do
    user_id = socket.assigns.current_user.id
    Accounts.unset_user_fave_shift_template(user_id)

    socket
    |> assign(:current_user, Accounts.get_user!(user_id))
    |> assign_shift_templates()
    |> live_noreply()
  end

  @impl true
  def handle_info({:close_modal, _}, %{assigns: %{modal_close_action: :return}} = socket) do
    socket
    |> copy_flash()
    |> push_patch(to: socket.assigns.modal_return_to)
    |> live_noreply()
  end

  @impl true
  def handle_info({:close_modal, _}, %{assigns: %{modal_close_action: assign_key}} = socket) do
    socket
    |> assign(assign_key, nil)
    |> assign_modal_close_handlers()
    |> assign_shift_templates()
    |> live_noreply()
  end

  @impl true
  def handle_info({:put_flash_message, {flash_type, msg}}, socket) do
    socket |> put_flash(flash_type, msg) |> live_noreply()
  end
end
