defmodule Shift73kWeb.UserShiftsIcsController do
  use Shift73kWeb, :controller

  alias Shift73k.Accounts
  alias Shift73k.Accounts.User
  alias Shift73k.Shifts
  alias Shift73k.Shifts.Shift

  def index(conn, %{"slug" => slug}) do
    case Accounts.get_user_by_calendar_slug(slug) do
      %User{} = user -> render_ics(conn, user.id)

      _ -> send_not_found(conn)

    end
  end

  defp send_not_found(conn), do: send_resp(conn, 404, "Not found")

  defp render_ics(conn, user_id) do
    user_id
    |> Shifts.list_shifts_by_user()
    |> Enum.map(&event_from_shift/1)
    |> render_ics(conn, user_id)
  end

  defp render_ics([], conn, _user_id), do: send_not_found(conn)

  defp render_ics(events, conn, user_id) do
    conn
    |> put_resp_content_type("text/calendar")
    |> put_resp_header("content-disposition", "attachment; filename=\"#{user_id}.ics\"")
    |> send_resp(200, ICalendar.to_ics(%ICalendar{events: events}))
  end

  defp event_from_shift(%Shift{} = s) do
    dt_start = DateTime.new!(s.date, s.time_start, s.time_zone)
    shift_length_s = Shifts.shift_length(s) * 60

    %ICalendar.Event{
      summary: s.subject,
      dtstart: dt_start,
      dtend: DateTime.add(dt_start, shift_length_s),
      description: s.description,
      location: s.location
    }
  end
end
