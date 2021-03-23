defmodule Shift73kWeb.UserShiftsCsvController do
  use Shift73kWeb, :controller

  alias Shift73k.Shifts
  alias Shift73k.Shifts.Shift

  def new(conn, _params) do
    render(conn, "new.html", error_message: nil)
  end

  def export(conn, %{"csv_export" => request_params}) do
    IO.inspect(request_params, label: "csv request params :")

    case Map.get(request_params, "user_id") == conn.assigns.current_user.id do
      true ->
        export_csv(conn, request_params)

      false ->
        conn
        |> put_flash(:danger, "Unauthorized CSV export request")
        |> redirect(to: "/")
        |> halt()
    end
  end

  defp export_csv(conn, %{"date_min" => date_min, "date_max" => date_max}) do
    date_range = Date.range(Date.from_iso8601!(date_min), Date.from_iso8601!(date_max))
    csv_content = build_csv_content(conn.assigns.current_user.id, date_range)
    filename_dt = DateTime.utc_now() |> Calendar.strftime("%Y%m%dT%H%M%S")
    filename = "#{conn.assigns.current_user.id}_#{filename_dt}.csv"

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"#{filename}\"")
    |> send_resp(200, csv_content)
  end

  def build_csv_content(user_id, date_range) do
    [csv_headers() | csv_data(user_id, date_range)]
    |> NimbleCSV.RFC4180.dump_to_iodata()
    |> to_string()
    |> IO.inspect()
  end

  def csv_data(user_id, date_range) do
    user_id
    |> Shifts.list_shifts_by_user_in_date_range(date_range)
    |> Enum.map(&csv_shift_row/1)
  end

  def csv_headers do
    [
      "Subject",
      "Start Date",
      "Start Time",
      "End Date",
      "End Time",
      "All Day Event",
      "Description",
      "Location",
      "Private"
    ]
  end

  defp csv_shift_row(%Shift{} = s) do
    dt_start = DateTime.new!(s.date, s.time_start, s.time_zone)
    shift_length_s = Shifts.shift_length(s) * 60
    dt_end = DateTime.add(dt_start, shift_length_s)

    [
      s.subject,
      csv_date_string(dt_start),
      csv_time_string(dt_start),
      csv_date_string(dt_end),
      csv_time_string(dt_end),
      false,
      s.description,
      s.location,
      false
    ]
  end

  defp csv_date_string(%DateTime{} = dt) do
    dt
    |> DateTime.to_date()
    |> Calendar.strftime("%m/%d/%Y")
  end

  defp csv_time_string(%DateTime{} = dt) do
    dt
    |> DateTime.to_time()
    |> Calendar.strftime("%-I:%M %p")
  end
end
