defmodule Shift73kWeb.UserShiftsIcsController do
  use Shift73kWeb, :controller

  alias Shift73k.Accounts
  alias Shift73k.Accounts.User

  def index(conn, %{"slug" => slug}) do
    case Accounts.get_user_by_calendar_slug(slug) do
      %User{} = user ->
        render(conn, "index.html", slug: slug, user: user)

      _ ->
        send_resp(conn, 404, "Not found")
    end
  end
end
