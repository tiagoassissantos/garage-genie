defmodule GarageGenie.Repo do
  use Ecto.Repo,
    otp_app: :garage_genie,
    adapter: Ecto.Adapters.Postgres
end
