defmodule Shift73kWeb.ShiftLive.Index do
  use Shift73kWeb, :live_view

  alias Shift73k.Shifts
  alias Shift73k.Shifts.Shift
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
    shift = shift_from_params(params)

    if Roles.can?(current_user, shift, live_action) do
      socket
      |> init_today(Date.utc_today())
      |> update_agenda()
      |> assign_modal_close_handlers()
      |> assign(:delete_shift, nil)
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
    to = Routes.shift_index_path(socket, :index)
    assign(socket, modal_return_to: to, modal_close_action: :return)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "My Shifts")
    |> assign(:shift, nil)
  end

  defp shift_from_params(params)

  defp shift_from_params(%{"id" => id}),
    do: Shifts.get_shift!(id)

  defp shift_from_params(_params), do: %Shift{}

  defp init_today(socket, today) do
    assign(socket, current_date: today, cursor_date: cursor_date(today))
  end

  defp cursor_date(%Date{} = date) do
    date |> Date.beginning_of_month() |> Date.add(4)
  end

  defp assign_date_range(%{assigns: %{cursor_date: cursor_date}} = socket) do
    assign(socket, date_range: date_range(cursor_date))
  end

  defp date_range(cursor_date) do
    cursor_date
    |> Date.beginning_of_month()
    |> Date.range(Date.end_of_month(cursor_date))
  end

  defp assign_known_shifts(socket) do
    user = socket.assigns.current_user
    shifts = Shifts.list_shifts_by_user_in_date_range(user.id, socket.assigns.date_range)
    assign(socket, :shifts, shifts)
  end

  defp update_agenda(socket) do
    socket
    |> assign_date_range()
    |> assign_known_shifts()
  end

  @impl true
  def handle_event("delete-modal", %{"id" => id}, socket) do
    socket
    |> assign(:modal_close_action, :delete_shift)
    |> assign(:delete_shift, Shifts.get_shift!(id))
    |> live_noreply()
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    shift = Shifts.get_shift!(id)
    {:ok, _} = Shifts.delete_shift(shift)

    {:noreply, assign_known_shifts(socket)}
  end

  @impl true
  def handle_event("month-nav", %{"month" => nav}, socket) do
    new_cursor = new_nav_cursor(nav, socket.assigns.cursor_date)

    socket
    |> assign(:cursor_date, new_cursor)
    |> update_agenda()
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
    |> assign_known_shifts()
    |> live_noreply()
  end

  @impl true
  def handle_info({:put_flash_message, {flash_type, msg}}, socket) do
    socket |> put_flash(flash_type, msg) |> live_noreply()
  end

  defp new_nav_cursor("now", _cursor_date), do: Date.utc_today()

  defp new_nav_cursor(nav, cursor_date) do
    cursor_date
    |> Date.add((nav == "prev" && -30) || 30)
    |> cursor_date()
  end
end
