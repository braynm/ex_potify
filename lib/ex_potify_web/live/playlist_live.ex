defmodule ExPotifyWeb.PlaylistLive do
  # use Phoenix.LiveComponent
  use ExPotifyWeb, :live_view
  alias Phoenix.LiveView.JS

  def mount(_params, %{"id" => session_id}, socket) do
    {:ok, paging} = fetch_playlist(session_id, 0)

    socket =
      socket
      |> assign(:playlists, paging.items)
      |> assign(:session_id, session_id)
      |> assign(:offset, paging.offset + 50)
      |> assign(:total, paging.total)

    IO.inspect(List.first(paging.items))
    {:ok, socket, temporary_assigns: [playlists: []]}
  end

  def handle_event("load_more", _payload, socket) do
    offset = socket.assigns[:offset]
    total = socket.assigns[:total]
    session_id = socket.assigns[:session_id]

    if offset < total do
      {:ok, paging} = fetch_playlist(session_id, offset)

      socket =
        socket
        |> assign(:playlists, paging.items)
        |> assign(:offset, offset + 50)

      {:noreply, socket}
    else
      {:noreply, push_event(socket, "all_loaded", %{})}
    end
  end

  def handle_event("select_playlist", payload, socket) do
    %{"playlist_id" => playlist_id, "owner_id" => owner_id} = payload
    session_id = socket.assigns[:session_id]
    playlist_details = ExPotify.Playlist.get_playlist_details(session_id, owner_id, playlist_id)

    socket =
      socket
      |> assign("playlist", playlist_details)

    IO.inspect("@@@@@@@@@@@@@2")
    IO.inspect(playlist_details)

    {:noreply, socket}
  end

  defp fetch_playlist(session_id, offset) do
    ExPotify.Playlist.get_user_playlist(session_id, offset)
  end

  def render(assigns) do
    ~H"""
    <div class="playlists pt-[24px] pl-[24px]" id="playlist-container">
       <h3 class="text-[24px] text-[#F2F6FF] font-bold opacity-[0.70] mb-[8px]">
         Playlists
       </h3>
       <div class="overflow-y-scroll max-h-[330px]">
        <ul id="playlists-items" phx-update="append">
           <%= for item <- @playlists do %>
             <li
               id={item.id}
               class="text-[#F2F6FF] pb-[6px] text-sm"
               phx-click="select_playlist"
               phx-value-playlist_id={item.id}
               phx-value-owner_id={item.owner["id"]}
               phx-value-name={item.name}
               phx-value-img_url={List.first(item.images)["url"]}
             >
               <span class="cursor-pointer opacity-75"><%= item.name %></span>
             </li>
           <% end %>
         </ul>
         <span id="playlist-scroll" phx-hook="Scroll"></span>
       </div>
     </div>
    """
  end
end
