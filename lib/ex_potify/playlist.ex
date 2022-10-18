defmodule ExPotify.Playlist do
  def get_user_playlist(user_id, offset) do
    access_token = ExPotify.TokenRefresher.get_access_token(user_id)
    credentials = %Spotify.Credentials{access_token: access_token}

    Spotify.Playlist.get_current_user_playlists(credentials, limit: 50, offset: offset)
  end

  def get_playlist_details(user_id, owner_id, playlist_id, params \\ []) do
    access_token = ExPotify.TokenRefresher.get_access_token(user_id)
    credentials = %Spotify.Credentials{access_token: access_token}

    Spotify.Playlist.get_playlist_tracks(credentials, owner_id, playlist_id, params)
  end
end
