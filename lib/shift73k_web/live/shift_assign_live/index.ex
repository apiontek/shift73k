defmodule Shift73kWeb.ShiftAssignLive.Index do
  use Shift73kWeb, :live_view
  use Timex

  alias Shift73k.EctoEnums.WeekdayEnum

  @impl true
  def mount(_params, session, socket) do
    socket
    |> assign_defaults(session)
    |> assign_day_names()
    |> assign_init_dates(Timex.today())
    |> assign_week_rows()
    |> live_okreply()
  end

  defp rotate_week(week_start_at) do
    {a, b} = Enum.split_while(WeekdayEnum.__enum_map__(), fn {k, _v} -> k != week_start_at end)
    b ++ a
  end

  defp day_names(week_start_at) do
    week_start_at
    |> rotate_week()
    |> Keyword.values()
    |> Enum.map(&Timex.day_shortname/1)
    |> IO.inspect(label: "day names...")
  end

  defp week_rows(cursor_date, week_start_at) do
    first =
      cursor_date
      |> Timex.beginning_of_month()
      |> Timex.beginning_of_week(week_start_at)

    last =
      cursor_date
      |> Timex.end_of_month()
      |> Timex.end_of_week(week_start_at)
      |> IO.inspect(label: "last found")

    Interval.new(from: first, until: last, right_open: false)
    |> Enum.map(& &1)
    |> Enum.chunk_every(7)
    |> IO.inspect(label: "week rows")
  end

  defp assign_day_names(socket) do
    day_names = day_names(socket.assigns.current_user.week_start_at)
    assign(socket, :day_names, day_names)
  end

  defp assign_init_dates(socket, today) do
    socket
    |> assign(:current_date, today)
    |> assign(:cursor_date, today)
  end

  defp assign_week_rows(socket) do
    cursor_date = socket.assigns.cursor_date
    week_start_at = socket.assigns.current_user.week_start_at

    assign(socket, :week_rows, week_rows(cursor_date, week_start_at))
  end

end
