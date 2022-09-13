defmodule ApartmentSearch.ApartmentListing do
  use Ecto.Schema
  import Ecto.Changeset

  schema "apartment_listings" do
    field :description, :string
    field :title, :string
    field :url, :string
    field :sent, :boolean

    timestamps()
  end

  @doc false
  def changeset(apartment_listing, attrs) do
    apartment_listing
    |> cast(attrs, [:url, :title, :description])
    |> validate_required([:url, :title, :description])
    |> unique_constraint(:url)
  end
end
