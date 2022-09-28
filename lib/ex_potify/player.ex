defmodule ExPotify.Player do
  def play(user_id, {device_id, payload}) do
    access_token = ExPotify.TokenRefresher.get_access_token(user_id)
    credentials = %Spotify.Credentials{access_token: access_token}

    params = [
      device_id: device_id,
      context_uri: payload[:context_uri],
      offset: %{
        position: payload[:offset]
      }
    ]

    Spotify.Player.play(credentials, params)
  end

  def skip_to_next(user_id) do
    access_token = ExPotify.TokenRefresher.get_access_token(user_id)
    credentials = %Spotify.Credentials{access_token: access_token}

    Spotify.Player.skip_to_next(credentials)
  end

  def skip_to_previous(user_id) do
    access_token = ExPotify.TokenRefresher.get_access_token(user_id)
    credentials = %Spotify.Credentials{access_token: access_token}

    Spotify.Player.skip_to_previous(credentials)
  end
end
