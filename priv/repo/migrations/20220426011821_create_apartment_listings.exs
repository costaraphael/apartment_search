defmodule ApartmentSearch.Repo.Migrations.CreateApartmentListings do
  use Ecto.Migration

  def change do
    create table(:apartment_listings) do
      add :url, :string, null: false
      add :title, :string
      add :description, :string
      add :sent, :boolean, default: false, null: false

      timestamps()
    end

    create unique_index(:apartment_listings, [:url])
  end
end
