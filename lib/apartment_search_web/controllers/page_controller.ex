defmodule ApartmentSearchWeb.PageController do
  use ApartmentSearchWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
