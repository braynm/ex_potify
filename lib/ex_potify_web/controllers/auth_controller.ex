defmodule ExPotifyWeb.AuthController do
  use ExPotifyWeb, :controller

  def authorize(conn, _params) do
    redirect(conn, external: Spotify.Authorization.url())
  end

  def callback(conn, params) do
    with {:ok, plug_conn} <-
           Spotify.Authentication.authenticate(conn, params) do
      cookies = plug_conn.cookies
      access_token = Map.get(cookies, "spotify_access_token")
      refresh_token = Map.get(cookies, "spotify_refresh_token")

      {:ok, profile} =
        conn
        |> Spotify.Cookies.set_access_cookie(access_token)
        |> Spotify.Profile.me()

      ExPotify.Account.insert_or_update_account(%{
        username: profile.id,
        email: profile.email,
        refresh_token: refresh_token,
        access_token: access_token
      })

      redirect(conn, to: "/")
    else
      err ->
        IO.inspect("something went wrong: #{err}")
    end
  end
end
