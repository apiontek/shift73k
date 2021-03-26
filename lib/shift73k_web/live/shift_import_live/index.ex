defmodule Shift73kWeb.ShiftImportLive.Index do
  use Shift73kWeb, :live_view

  alias Shift73k.Repo
  alias Shift73k.Shifts

  @url_regex_str "[-a-zA-Z0-9@:%._\\+~#=]{1,256}\\.[a-zA-Z0-9()]{1,6}\\b([-a-zA-Z0-9()@:%_\\+.~#?&//=]*)"
  @url_regex Regex.compile!(@url_regex_str)

  @impl true
  def mount(_params, session, socket) do
    HTTPoison.start()

    socket
    |> assign_defaults(session)
    |> assign(:page_title, "iCal Import")
    |> assign(:url_valid, false)
    |> assign(:url_validated, false)
    |> assign(:tz_valid, true)
    |> live_okreply()
  end

  @impl true
  def handle_event("validate", %{"ics_import" => %{"ics_url" => url, "time_zone" => tz}}, socket) do
    socket
    |> assign(:url_valid, Regex.match?(@url_regex, url))
    |> assign(:url_validated, true)
    |> assign(:tz_valid, Enum.member?(Tzdata.zone_list(), tz))
    |> live_noreply()
  end

  @impl true
  def handle_event("save", %{"ics_import" => %{"ics_url" => url, "time_zone" => tz}}, socket) do
    url
    |> HTTPoison.get!()
    |> handle_http_ics_response(socket, tz)
  end

  defp handle_http_ics_response(%HTTPoison.Response{status_code: 200} = resp, socket, tz) do
    case content_type_calendar?(resp.headers) do
      false ->
        handle_http_ics_response(false, socket, tz)

      true ->
        resp.body
        |> ICalendar.from_ics()
        |> handle_parsed_ics_data(socket, tz)
    end
  end

  defp handle_http_ics_response(_, socket, _tz) do
    socket
    |> put_flash(:error, "Bad data, bad URL, or some other error. Page the dev!")
    |> live_noreply()
  end

  defp handle_parsed_ics_data([], socket, tz), do: handle_http_ics_response(false, socket, tz)

  defp handle_parsed_ics_data(events, socket, tz) do
    events
    |> Stream.map(&shift_from_event(&1, tz, socket.assigns.current_user.id))
    |> Enum.map(&Repo.timestamp/1)
    |> Shifts.create_multiple()
    |> handle_create_multiple_result(length(events), socket)
    |> live_noreply()
  end

  defp handle_create_multiple_result(result, event_count, socket) do
    {status, msg} =
      case result do
        {:error, errmsg} ->
          {:error, "Ope, problem error inserting shifts, page the dev! Message: #{errmsg}"}

        {n, _} ->
          s = (n > 1 && "s") || ""

          if n == event_count do
            {:success, "Successfully imported #{n} event#{s}"}
          else
            {:warning,
             "Some error, only #{n} event#{s} imported but seemed like iCal contained #{
               event_count
             }?"}
          end
      end

    put_flash(socket, status, msg)
  end

  defp content_type_calendar?(headers) do
    headers
    |> List.keyfind("Content-Type", 0)
    |> elem(1)
    |> String.contains?("text/calendar")
  end

  defp shift_from_event(%ICalendar.Event{} = e, tz, user_id) do
    dtzstart = DateTime.shift_zone!(e.dtstart, tz)
    dtzend = DateTime.add(dtzstart, DateTime.diff(e.dtend, e.dtstart))

    %{
      subject: e.summary,
      location: e.location,
      description: fix_description(e.description),
      date: DateTime.to_date(dtzstart),
      time_zone: tz,
      time_start: DateTime.to_time(dtzstart),
      time_end: DateTime.to_time(dtzend),
      user_id: user_id
    }
  end

  defp fix_description(nil), do: nil

  defp fix_description(description) do
    description
    |> String.replace("<br>", "\r\n")
    |> String.replace("<br\\>", "\r\n")
    |> String.replace("<br \\>", "\r\n")
    |> String.replace("<b>", "**")
    |> String.replace("</b>", "**")
    |> String.replace("<strong>", "**")
    |> String.replace("</strong>", "**")
    |> String.replace("<i>", "*")
    |> String.replace("</i>", "*")
    |> String.replace("<em>", "*")
    |> String.replace("</em>", "*")
  end
end
