defmodule ExPotifyWeb.PageController do
  use ExPotifyWeb, :controller

  # plug :put_layout, false when action in [:home]

  def index(conn, _params) do
    oauth_url = Spotify.Authorization.url()
    render(conn, "index.html", oauth_url: oauth_url)
  end

  # conn
  def home(conn, _) do
    conn
    |> put_layout(false)
    |> put_root_layout(false)
    |> render("home.html")
  end
end
