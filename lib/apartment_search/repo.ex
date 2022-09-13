defmodule ApartmentSearch.Repo do
  use Ecto.Repo,
    otp_app: :apartment_search,
    adapter: Ecto.Adapters.Postgres
end
