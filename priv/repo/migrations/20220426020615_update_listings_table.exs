defmodule ApartmentSearch.Repo.Migrations.UpdateListingsTable do
  use Ecto.Migration

  def change do
    alter table("apartment_listings") do
      modify :url, :string, null: false, size: 10000
      modify :title, :string, size: 10000
      modify :description, :string, size: 10000
    end
  end
end
