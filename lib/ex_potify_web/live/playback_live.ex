defmodule ExPotifyWeb.PlaybackLive do
  use ExPotifyWeb, :live_view
  alias Phoenix.LiveView.JS

  @is_playing_img ""
  @is_paused_img ""

  def mount(_params, %{"id" => session_id}, socket) do
    token = ExPotify.TokenRefresher.get_access_token(session_id)
    send(self(), {:init_token, token})

    if connected?(socket) do
      Phoenix.PubSub.subscribe(ExPotify.PubSub, "#{session_id}_playlist")
    end

    socket =
      socket
      |> assign(:token, token)
      |> assign(:session_id, session_id)
      |> assign(:paused, true)
      |> assign(:track, nil)
      |> assign(:playlist_id, nil)
      |> assign(:playlist, nil)

    {:ok, socket}
  end

  def handle_info({:init_token, token}, socket) do
    {:noreply, push_event(socket, "init_token", %{"token" => token})}
  end

  def handle_info(
        {:select_playlist_uri, %{"playlist_uri" => uri, "playlist_id" => id} = playlist},
        socket
      ) do
    socket =
      socket
      |> assign(:playlist_uri, uri)
      |> assign(:playlist_id, id)
      |> assign(:playlist, playlist)

    {:noreply, socket}
  end

  def handle_event("init_device", %{"device_id" => device_id}, socket) do
    socket = assign(socket, :device_id, device_id)
    {:noreply, socket}
  end

  def handle_event("play_track", %{"uri" => uri, "track_number" => number} = track, socket) do
    device_id = socket.assigns.device_id
    playlist_uri = socket.assigns.playlist_uri

    payload =
      {device_id,
       [
         context_uri: playlist_uri,
         offset: number
       ]}

    ExPotify.Player.play(socket.assigns.session_id, payload)

    socket =
      socket
      |> assign(:paused, false)
      |> assign(:track, track)

    {:noreply, socket}
  end

  def handle_event("skip_to_previous", _params, socket) do
    ExPotify.Player.skip_to_previous(socket.assigns.session_id)
    {:noreply, socket}
  end

  def handle_event("skip_to_next", _params, socket) do
    ExPotify.Player.skip_to_next(socket.assigns.session_id)
    {:noreply, socket}
  end

  def handle_event("paused", %{"paused" => paused}, socket) do
    socket = assign(socket, :paused, paused)
    {:noreply, push_event(socket, "player_state_changed", %{paused: paused})}
  end

  def handle_event("select_track", payload, socket) do
    socket =
      socket
      |> assign(:track, payload)
      |> assign(:paused, false)

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="flex absolute h-[90px] w-full bottom-[0px] z-10 bg-[#161C44] rounded-[30px]">
      <div class="min-w-[256px] max-w-[256px] pl-[24px] flex items-center">
        <%= if not is_nil(@track) do %>
        <div>
          <a
            href="#"
          >
            <img class="cursor-pointer" src={Map.get(@track, "img")} />
          </a>
        </div>
        <div class="text-[#F2F6FF] ml-[12px] font-[roboto]">
          <p alt="123" class="whitespace-nowrap overflow-hidden text-ellipsis text-sm nowrap pt-[4px]"><%= Map.get(@track, "name") %></p>
          <p class="pb-[4px] opacity-[0.7] text-xs"><%= Map.get(@track, "artist") %></p>
        </div>
        <% end %>
      </div>
      <div phx-hook="Playback" id="playback-control" class="controls grow flex flex-col items-center justify-center">
        <div class="flex mt-4">
          <img class="mr-[8px] cursor-pointer opacity-[0.6]" height="24" width="24" src="images/step-backward(24x24)@2(2).png" phx-click="skip_to_previous" />
          <div class="play-pause cursor-pointer mr-[8px] w-[24px] h-[24px] rounded-[22px] z-[200]">
            <%= if @paused do %>
              <img height="16" width="16" src="images/play-6(24x24)@2.png" phx-click={JS.push("paused", value: %{paused: false})} />
            <% else %>
              <img height="16" width="16" src="images/pause-7---filled(24x24)@2x.png" phx-click={JS.push("paused", value: %{paused: true})}  />
            <% end %>
          </div>
          <img class="cursor-pointer opacity-[0.6]" height="24" width="24" src="images/step-forward(24x24)@2.png" phx-click="skip_to_next" />
        </div>
        <div class="my-2 flex items-center">
          <span id="currentDuration" class="text-[#fff]">0:00</span>
          <progress id="track" max="100" value="0" class="h-[6px] mx-2 rounded-md"> 0% </progress>
          <span id="duration" class="text-[#fff]">3:38</span>
        </div>
      </div>
    </div>
    """
  end
end
