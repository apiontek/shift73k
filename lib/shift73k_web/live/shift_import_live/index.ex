defmodule Shift73kWeb.ShiftImportLive.Index do
  use Shift73kWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    HTTPoison.start()

    socket
    |> assign_defaults(session)
    |> live_okreply()
  end

  @impl true
  def handle_event("save", %{"ics_import" => %{"ics_url" => ics_url}}, socket) do
    ics_url
    |> IO.inspect(label: "given ical url :")
    |> HTTPoison.get!()
    |> handle_http_ics_response(socket)
  end

  defp handle_http_ics_response(%HTTPoison.Response{status_code: 200} = resp, socket) do
    case content_type_calendar?(resp.headers) do
      false ->
        handle_http_ics_response(false, socket)

      true ->
        resp.body
        |> ICalendar.from_ics()
        |> handle_parsed_ics_data(socket)
    end
  end

  defp handle_http_ics_response(_, socket) do
    socket
    |> put_flash(:error, "Bad data, bad URL, or some other error")
    |> live_noreply()
  end

  defp handle_parsed_ics_data([], socket), do: handle_http_ics_response(false, socket)

  defp handle_parsed_ics_data(events, socket) do
    IO.inspect(events, label: "We got some ical events! :")

    socket
    |> put_flash(:success, "We got some ical events")
    |> live_noreply()
  end

  def ical_request(ics_url) do
    # ics_url = "https://calendar.google.com/calendar/ical/l44mcggj2rsoqq7prlakvitqfo%40group.calendar.google.com/private-66f4cf8b340bdd6e9de8c60b2ae36528/basic.ics"
  end

  defp content_type_calendar?(headers) do
    headers
    |> List.keyfind("Content-Type", 0)
    |> elem(1)
    |> String.contains?("text/calendar")
  end

  def shift_from_event(%ICalendar.Event{} = event) do
    %{}
  end
end
