defmodule Shift73kWeb.ShiftLive.Index do
  use Shift73kWeb, :live_view
  use Timex

  alias Shift73k.Shifts
  alias Shift73k.Shifts.Shift
  alias Shift73kWeb.Roles

  @impl true
  def mount(_params, session, socket) do
    socket
    |> assign_defaults(session)
    |> live_okreply()

    # {:ok, assign(socket, :shifts, list_shifts())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    current_user = socket.assigns.current_user
    live_action = socket.assigns.live_action
    shift = shift_from_params(params)

    if Roles.can?(current_user, shift, live_action) do
      socket
      # |> assign_shift_templates()
      # |> assign_modal_close_handlers()
      |> init_today(Timex.today())
      |> assign_date_range()
      |> assign_known_shifts()
      |> assign(:delete_shift, nil)
      |> apply_action(socket.assigns.live_action, params)
      |> live_noreply()
    else
      socket
      |> put_flash(:error, "Unauthorised")
      |> redirect(to: "/")
      |> live_noreply()
    end

    # {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Shift")
    |> assign(:shift, Shifts.get_shift!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Shift")
    |> assign(:shift, %Shift{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Shifts")
    |> assign(:shift, nil)
  end

  defp shift_from_params(params)

  defp shift_from_params(%{"id" => id}),
    do: Shifts.get_shift!(id)

  defp shift_from_params(_params), do: %Shift{}

  defp init_today(socket, today) do
    assign(socket, current_date: today, cursor_date: today)
  end

  defp assign_date_range(%{assigns: %{cursor_date: cursor_date}} = socket) do
    assign(socket, date_range: date_range(cursor_date))
  end

  defp date_range(cursor_date) do
    cursor_date
    |> Timex.beginning_of_month()
    |> Date.range(Timex.end_of_month(cursor_date))
  end

  defp assign_known_shifts(socket) do
    user = socket.assigns.current_user
    shifts = Shifts.list_shifts_by_user_in_date_range(user.id, socket.assigns.date_range)
    assign(socket, :shifts, shifts)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    shift = Shifts.get_shift!(id)
    {:ok, _} = Shifts.delete_shift(shift)

    {:noreply, assign_known_shifts(socket)}
  end

  @impl true
  def handle_event("month-nav", %{"month" => direction}, socket) do
    new_cursor =
      cond do
        direction == "now" ->
          Timex.today()

        true ->
          months = (direction == "prev" && -1) || 1
          Timex.shift(socket.assigns.cursor_date, months: months)
      end

    socket
    |> assign(:cursor_date, new_cursor)
    |> assign_date_range()
    |> assign_known_shifts()
    |> live_noreply()
  end
end
