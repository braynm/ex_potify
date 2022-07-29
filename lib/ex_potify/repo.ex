defmodule ExPotify.Repo do
  use Ecto.Repo,
    otp_app: :ex_potify,
    adapter: Ecto.Adapters.Postgres
end
