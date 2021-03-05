defmodule Bones73k.Repo do
  use Ecto.Repo,
    otp_app: :bones73k,
    adapter: Ecto.Adapters.Postgres

  use Scrivener, page_size: 10
end
