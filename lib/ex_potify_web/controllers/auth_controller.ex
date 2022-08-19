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

      ExPotify.DynamicTokenSupervisor.start_child(profile.id)

      conn
      |> put_session(:id, profile.id)
      |> redirect(to: "/home")
    else
      err ->
        IO.inspect("something went wrong: #{err}")
    end
  end

  def test(conn, params) do
    conn =
      Spotify.Cookies.set_refresh_cookie(
        conn,
        "AQDxw53IorzJbHEVJpWuaEyM4UCAfSmd9CjA65zVE8HKPVb-MiIqg16vuJWbhu7j9KkKQFZL4WGs7-X8kmOaOT60AGxDfve7TH4uN6rTgtPK1t9NhC-vM_PJfFX8QFeDbEg"
      )

    IO.inspect(Spotify.Cookies.get_refresh_token(conn))
    IO.inspect(conn)
    conn
  end
end
