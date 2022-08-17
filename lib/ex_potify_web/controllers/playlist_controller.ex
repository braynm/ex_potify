defmodule ExPotifyWeb.PlaylistController do
  use ExPotifyWeb, :controller

  @access_token "BQCXbkh-_U2iBzbyOhq3KpyVMXL2A1xRC0quCI49UUU0r5WVbxzR5SmdgNQqjxWVRRy5yV-K_J2h9gCT8nXhtKT2jm1aYYZb79bbA_xS_pAEEnysgFVTFSB8CVdmMRTmSng4c7UYcneJm9WWTOl9vbClyN9ltP2mG0NgN_NpzaLvwsQYyW_A5YIit-ol9PsWs8IAE5k0bsnh4EJiduOl1JlquQ"

  def index(conn, _params) do
    conn
    |> Spotify.Cookies.set_access_cookie(@access_token)
    # |> Spotify.Profile.me()
    |> Spotify.Playlist.get_playlist("b.madrid", "")
    |> IO.inspect()

    conn
  end

  def callback(conn, params) do
    Spotify.Authentication.authenticate(conn, params) |> IO.inspect()
    conn
  end
end
