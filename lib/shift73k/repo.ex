defmodule Shift73k.Repo do
  use Ecto.Repo,
    otp_app: :shift73k,
    adapter: Ecto.Adapters.Postgres

  use Scrivener, page_size: 10

  def timestamp(%{} = attrs) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    Map.merge(attrs, %{inserted_at: now, updated_at: now})
  end
end
