defmodule SurfMarketplace.Repo do
  use Ecto.Repo,
    otp_app: :surf_marketplace,
    adapter: Ecto.Adapters.Postgres
end
