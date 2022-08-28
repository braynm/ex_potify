defmodule ExPotifyWeb.PlaylistInfoLive do
  use ExPotifyWeb, :live_view
  alias Phoenix.LiveView.JS

  def mount(_params, _payload, socket) do
    socket =
      socket
      |> assign(:name, "")
      |> assign(:description, "")

    {:ok, socket, temporary_assigns: [tracks: []]}
  end

  def handle_event("select_playlist", payload, socket) do
    %{
      "name" => name,
      "description" => description,
      "owner_id" => owner_id,
      "playlist_id" => playlist_id,
      "session_id" => session_id
    } = payload

    {:ok, resp} =
      ExPotify.Playlist.get_playlist_details(
        session_id,
        owner_id,
        playlist_id
      )

    socket =
      socket
      |> assign(:name, name)
      |> assign(:name, name)
      |> assign(:description, description)
      |> assign(:tracks, transform_items(resp.items))

    {:noreply, socket}
  end

  defp transform_items(items) do
    Enum.map(items, &do_transform_items/1)
  end

  defp do_transform_items(%Spotify.Playlist.Track{track: track}) do
    track_map = Map.from_struct(track)

    %{
      name: get_in(track_map, [:name]),
      album: get_in(track_map, [:album, "name"]),
      artist:
        track_map
        |> get_in([:artists])
        |> List.first()
        |> Map.get("name")
    }
  end

  def render(assigns) do
    ~H"""
    <div id="playlist-info" class="pt-[32px] pl-[16px] rounded-tr-[30px] rounded-br-[30px] h-full bg-[#1A2151] min-w-[760px] max-w-[760px] overflow-y-scroll">
      <div class="playlist-header flex flex-row max-h-[240px]">
        <div class="playlist-description flex flex-col justify-center font-[roboto]">
          <div class="mb-[32px]">
            <span class="text-[16px] text-[#F2F6FF] opacity-[.70]">Playlist</span>
            <h2 class="text-[#F2F6FF] text-[32px] font-bold"><%= @name%></h2>
          </div>
          <div>
            <p class="text-[#F2F6FF] opacity-[.70] font-normal text-[12px]"><%= @description %></p>
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
          <tbody>
            <%= for track <- @tracks do %>
            <tr>
              <td class="max-w-[350px] w-[350px] text-[#F2F6FF]">
                <p alt="123" class="whitespace-nowrap overflow-hidden text-ellipsis font-small nowrap "><%= track.name %></p>
                <p class="pb-[8px] opacity-[0.7] text-sm"><%= track.artist %></p>
              </td>
              <td class="max-w-[300px] w-[300px] whitespace-nowrap overflow-hidden text-ellipsis font-small text-[#F2F6FF] nowrap "><%= track.album %></td>
              <td class="max-w-[10px] w-[10px] text-[#F2F6FF] text-right">3:31</td>
            </tr>
            <% end %>
          </tbody>
        </table>
        <div class="min-h-[120px]">
        </div>
      </div>
    </div>
    """
  end
end
