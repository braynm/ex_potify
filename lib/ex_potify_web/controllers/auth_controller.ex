defmodule ExPotifyWeb.AuthController do
  use ExPotifyWeb, :controller

  @access_token "BQCXbkh-_U2iBzbyOhq3KpyVMXL2A1xRC0quCI49UUU0r5WVbxzR5SmdgNQqjxWVRRy5yV-K_J2h9gCT8nXhtKT2jm1aYYZb79bbA_xS_pAEEnysgFVTFSB8CVdmMRTmSng4c7UYcneJm9WWTOl9vbClyN9ltP2mG0NgN_NpzaLvwsQYyW_A5YIit-ol9PsWs8IAE5k0bsnh4EJiduOl1JlquQ"

  # refresh token AQAfd3E0fs2hFN-1aEt9D5GXtA_vJ5aD8QNBaBwVqaEworFBb_MxbAL_5eWlq8rTsLTaH8R2bp9RnHkgBUgAMzh1pn1ZyMXOGjibN8tTdQZsWxoFuq63jF1ZyWvGJT9NcIk
  # access token 
  def authorize(conn, _params) do
    redirect(conn, external: Spotify.Authorization.url())
  end

  def callback(conn, params) do
    Spotify.Authentication.authenticate(conn, params) |> IO.inspect()
    conn
  end
end
