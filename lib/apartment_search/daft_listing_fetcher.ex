defmodule ApartmentSearch.DaftListingFetcher do
  require Logger

  def fetch_all_listings do
    fetch_all_from(0)
  end

  defp fetch_all_from(index) do
    case fetch_page(index) do
      [] ->
        []

      results ->
        results ++ fetch_all_from(index + length(results))
    end
  end

  defp fetch_page(from) do
    url =
      "https://www.daft.ie/property-for-rent/ireland?location=clontarf-dublin&location=raheny-dublin&location=south-dublin-city-dublin&rentalPrice_to=2100&from=#{from}"

    Req.get!(url).body
    |> Floki.parse_document!()
    |> Floki.find(~s|li[class^="SearchPage__Result"]|)
    |> Enum.map(fn result ->
      title =
        result
        |> Floki.find(~s|[data-testid="price"]|)
        |> Floki.text()

      description =
        result
        |> Floki.find(~s|[data-testid="address"]|)
        |> Floki.text()

      link =
        result
        |> Floki.find("a")
        |> Floki.attribute("href")

      url = "https://www.daft.ie#{link}"

      %{title: title, description: description, url: url}
    end)
  end
end
