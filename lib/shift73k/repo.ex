defmodule Shift73k.Repo do
  use Ecto.Repo,
    otp_app: :shift73k,
    adapter: Ecto.Adapters.Postgres

  use Scrivener, page_size: 10
end
