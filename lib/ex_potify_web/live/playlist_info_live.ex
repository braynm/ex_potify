defmodule ExPotifyWeb.PlaylistInfoLive do
  use ExPotifyWeb, :live_view
  alias Phoenix.LiveView.JS

  def mount(_params, _payload, socket) do
    socket =
      socket
      |> assign(:name, "")
      |> assign(:description, "")

    {:ok, socket}
  end

  def handle_event("select_playlist", payload, socket) do
    %{"name" => name, "description" => description} = payload

    socket =
      socket
      |> assign(:name, name)
      |> assign(:description, description)

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div id="playlist-info" class="flex pt-[32px] pl-[16px] rounded-tr-[30px] rounded-br-[30px] h-full bg-[#1A2151] w-100 grow">
      <div class="playlist-header flex flex-row max-h-[240px]">
        <div class="playlist-cover mr-[32px]">
          <%#<img class="rounded-[10px]" width="232" height="232" src="../images/playlist-cover.png"/>%>
        </div>
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
      <div class="playlist-tracks">
      </div>
    </div>
    """
  end
end
