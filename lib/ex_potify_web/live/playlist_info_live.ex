defmodule ExPotifyWeb.PlaylistInfoLive do
  use ExPotifyWeb, :live_view
  alias Phoenix.LiveView.JS

  def mount(_params, _payload, socket) do
    socket =
      socket
      |> assign(:name, "")
      |> assign(:description, "")
      |> assign(:playlist_id, nil)

    {:ok, socket, temporary_assigns: [tracks: []]}
  end

  def handle_event("select_playlist", payload, socket) do
    %{
      "name" => name,
      "description" => description,
      "owner_id" => owner_id,
      "playlist_id" => playlist_id,
      "session_id" => session_id,
      "playlist_uri" => playlist_uri
    } = payload

    {:ok, resp} =
      ExPotify.Playlist.get_playlist_details(
        session_id,
        owner_id,
        playlist_id,
        offset: 0
      )

    Phoenix.PubSub.broadcast(
      ExPotify.PubSub,
      "#{session_id}_playlist",
      {:select_playlist_uri, payload}
    )

    socket =
      socket
      |> assign(:name, name)
      |> assign(:playlist_id, playlist_id)
      |> assign(:session_id, session_id)
      |> assign(:owner_id, owner_id)
      |> assign(:description, description)
      |> assign(:tracks, transform_items(resp.items, 0))
      |> assign(:offset, length(resp.items))
      |> assign(:total, resp.total)

    {:noreply, socket}
  end

  def handle_event("load_more_tracks", _payload, socket) do
    offset = socket.assigns[:offset]
    total = socket.assigns[:total]
    session_id = socket.assigns[:session_id]
    owner_id = socket.assigns[:owner_id]
    playlist_id = socket.assigns[:playlist_id]

    cond do
      not is_nil(playlist_id) and offset < total ->
        {:ok, paging} =
          ExPotify.Playlist.get_playlist_details(
            session_id,
            owner_id,
            playlist_id,
            offset: offset,
            limit: 100
          )

        socket =
          socket
          |> assign(:tracks, transform_items(paging.items, offset))
          |> assign(:offset, offset + length(paging.items))

        {:noreply, socket}

      not is_nil(playlist_id) and offset >= total ->
        {:noreply, push_event(socket, "all_items_loaded", %{})}

      is_nil(playlist_id) ->
        {:noreply, socket}
    end
  end

  defp transform_items(items, starting_index) do
    items
    |> Enum.map(&do_transform_items/1)
    |> Enum.with_index(fn element, index ->
      {element, index + starting_index}
    end)
  end

  defp do_transform_items(%Spotify.Playlist.Track{track: track}) do
    track_map = Map.from_struct(track)

    %{
      uri: get_in(track_map, [:uri]),
      id: get_in(track_map, [:id]),
      track_number: get_in(track_map, [:track_number]),
      name: get_in(track_map, [:name]),
      img:
        track_map
        |> get_in([:album, "images"])
        |> List.last()
        |> Map.get("url"),
      album: get_in(track_map, [:album, "name"]),
      duration_readable:
        ExPotifyWeb.Utils.TrackDurationFormatter.format(get_in(track_map, [:duration_ms])),
      artist:
        track_map
        |> get_in([:artists])
        |> List.first()
        |> Map.get("name")
    }
  end

  defp select_track(track_id, payload \\ %{}) do
    "play_track"
    |> JS.push(target: "#playback-control", value: payload)
    |> JS.remove_class("track-active", to: ".track")
    |> JS.add_class("track-active", to: "#track-#{track_id}")
  end

  defp play_track(track, index) do
    payload = %{
      name: track.name,
      artist: track.artist,
      track_number: index,
      uri: track.uri,
      img: track.img
    }

    select_track(track.id, payload)
  end

  def render(assigns) do
    ~H"""
    <div id="playlist-info" class="pl-[16px] rounded-tr-[30px] rounded-br-[30px] h-full bg-[#1A2151] min-w-[760px] max-w-[760px] overflow-y-scroll">
      <%= if is_nil(@playlist_id) do %>
        <div class="flex flex-col justify-center items-center">
          <img src="../images/Saly-24.png" width="500" height="500" />
          <h2 class="mt-6 text-xl text-[#F2F6FF]">Please select a Playlist</h2>
        </div>
      <% else %>
      <div class="playlist-header flex flex-row sticky top-0 bg-[#1A2151] py-[32px] z-10 max-h-[240px]">
        <div class="playlist-description flex flex-col justify-center font-[roboto]">
          <div class="mb-[32px]">
            <span class="text-[16px] text-[#F2F6FF] opacity-[.70]">Playlist</span>
            <h2 class="text-[#F2F6FF] text-[32px] font-bold"><%= @name%></h2>
          </div>
          <div>
            <p class="text-[#F2F6FF] opacity-[.70] font-normal text-[12px]"><%= raw @description %></p>
            <span class="text-[#F2F6FF] font-normal text-[12px]">Bryan</span>
            <span class="text-[#F2F6FF] ml-[4px] font-light text-[12px]">3k likes</span>
            <span class="text-[#F2F6FF] font-light text-[12px]">53 songs</span>
            <span class="text-[#F2F6FF] ml-[4px] font-light text-[12px]">6 hr 7 min</span>

          </div>
        </div>
      </div>
      <div class="playlist-tracks mt-[48px]">
        <table class="font-[roboto]">
          <thead>
            <tr>
              <th class="overflow-hidden text-ellipsis whitespace-nowrap font-small text-left text-[#F2F6FF] opacity-[0.7]">Track</th>
              <th class="font-small text-left text-[#F2F6FF] opacity-[0.7]">Album</th>
              <th class="font-small text-right text-[#F2F6FF] opacity-[0.7]">Duration</th>
            </tr>
          </thead>
          <tbody id={"track-list-#{@playlist_id}"} phx-update="append">
            <%= for {track, index} <- @tracks do %>
              <tr id={"track-#{track.id}"} class="track" phx-click={play_track(track, index)}>
                <td class="max-w-[350px] w-[350px] text-[#F2F6FF] pl-[5px]">
                  <p alt="123" class="whitespace-nowrap overflow-hidden text-ellipsis font-small nowrap pt-[4px]"><%= track.name %></p>
                  <p class="pb-[4px] opacity-[0.7] text-sm"><%= track.artist %></p>
                </td>
                <td class="max-w-[300px] w-[300px] whitespace-nowrap overflow-hidden text-ellipsis font-small text-[#F2F6FF] nowrap "><%= track.album %></td>
                <td class="max-w-[10px] w-[10px] text-[#F2F6FF] text-right pr-[5px]"><%= track.duration_readable %></td>
              </tr>
            <% end %>
          </tbody>
        </table>
         <span id="track-scroll" phx-hook="TrackPagination"></span>
        <div class="min-h-[120px]">
        </div>
      </div>
      <% end %>
    </div>
    """
  end
end
