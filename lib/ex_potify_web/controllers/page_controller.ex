defmodule ExPotifyWeb.PageController do
  use ExPotifyWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
