defmodule ExPotifyWeb.PageController do
  use ExPotifyWeb, :controller

  # plug :put_layout, false when action in [:home]
  def index(conn, _params) do
    oauth_url = Spotify.Authorization.url()

    conn
    |> put_layout(false)
    |> render("index.html", oauth_url: oauth_url)
  end

  def home(conn, _) do
    conn
    |> render("home.html")
  end
end
