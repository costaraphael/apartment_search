defmodule ApartmentSearch.Notifier do
  import Swoosh.Email

  alias ApartmentSearch.Mailer

  def notify_no_daft_listings_found do
    base_email()
    |> subject("No Daft listings found")
    |> text_body("""
    No listing was found while scrapping the Daft website, and it should find at least some, even if they are not new.

    Please check.
    """)
    |> Mailer.deliver!()
  end

  def notify_new_daft_listings(listings) do
    base_email()
    |> subject("New listings found on Daft.ie")
    |> html_body(
      EEx.eval_string(new_daft_listings_found_email_template(), assigns: [listings: listings])
    )
    |> Mailer.deliver!()
  end

  defp base_email() do
    new()
    |> to(target_users())
    |> from({"Apartment Search", "alerts@apartment_search.example.com"})
  end

  defp new_daft_listings_found_email_template() do
    """
    <h1><%= length(@listings) %> new listings found on Daft.ie</h1>

    <ul>
      <%= for listing <- @listings do %>
        <dt><a href="<%= listing.url %>"><%= listing.title %></a></dt>
        <dd><%= listing.description %></dd>
      <% end %>
    </ul>
    """
  end

  defp target_users do
    config()
    |> Keyword.fetch!(:target_users)
    |> String.split(";")
    |> Enum.map(fn user ->
      [name, email] = String.split(user, "|")

      {name, email}
    end)
  end

  defp config do
    Application.fetch_env!(:apartment_search, :notifier)
  end
end
