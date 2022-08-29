defmodule ExPotify.Player do
  def play(user_id, {device_id, uri}) do
    access_token = ExPotify.TokenRefresher.get_access_token(user_id)
    credentials = %Spotify.Credentials{access_token: access_token}

    params = [
      device_id: device_id,
      uris: uri
    ]

    Spotify.Player.play(credentials, params)
  end
end
