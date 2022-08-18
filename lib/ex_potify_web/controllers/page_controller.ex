defmodule ExPotifyWeb.PageController do
  use ExPotifyWeb, :controller

  # plug :put_layout, false when action in [:home]

  def index(conn, _params) do
    oauth_url = Spotify.Authorization.url()

    conn
    |> put_layout(false)
    |> render("index.html", oauth_url: oauth_url)
  end

  # conn
  def home(conn, _) do
    %{"id" => session_id} = get_session(conn)

    conn
    |> render("home.html", session_id: session_id)
  end
end
