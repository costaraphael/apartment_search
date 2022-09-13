defmodule ApartmentSearch.FindNewDaftListings do
  use Oban.Worker, queue: :default

  alias ApartmentSearch.{
    Repo,
    ApartmentListing,
    DaftListingFetcher,
    Notifier
  }

  require Logger

  @impl Oban.Worker
  def perform(_job) do
    Logger.info("Fetching new Daft listings")

    case DaftListingFetcher.fetch_all_listings() do
      [] ->
        Logger.warn("No listings found")
        Notifier.notify_no_daft_listings_found()

      listings ->
        persisted_listings = persist_listings!(listings)

        new_listings = Enum.reject(persisted_listings, & &1.sent)

        Logger.info("Found #{length(listings)} listings and #{length(new_listings)} new listings")

        unless new_listings == [] do
          Notifier.notify_new_daft_listings(new_listings)
        end

        mark_new_listings_as_sent!(new_listings)
    end
  end

  defp persist_listings!(listings) do
    placeholders = %{now: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)}

    entries =
      listings
      |> Enum.map(fn listing ->
        listing
        |> Map.put(:inserted_at, {:placeholder, :now})
        |> Map.put(:updated_at, {:placeholder, :now})
      end)

    {_, persisted_listings} =
      Repo.insert_all(ApartmentListing, entries,
        on_conflict: {:replace, [:updated_at]},
        placeholders: placeholders,
        conflict_target: [:url],
        returning: true
      )

    persisted_listings
  end

  defp mark_new_listings_as_sent!(new_listings) do
    import Ecto.Query

    ids = Enum.map(new_listings, & &1.id)
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    ApartmentListing
    |> where([l], l.id in ^ids)
    |> Repo.update_all(set: [sent: true, updated_at: now])

    :ok
  end
end
