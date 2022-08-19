defmodule ExPotifyWeb.Playlist do
  use Phoenix.Component
  use Phoenix.LiveView

  def index(assigns) do
    IO.inspect(assigns)
    # conn = Spotify.Cookies.set_access_cookie(%{}, access_token)

    # playlists = Spotify.Playlist.get_current_user_playlists(conn, limit: 10)

    # IO.inspect(playlists)

    ~H"""
     <div class="playlists pt-[24px] pl-[24px]">
       <h3 class="text-[24px] text-[#F2F6FF] font-bold opacity-[0.70] mb-[8px]">
         Playlists
       </h3>

       <ul class="overflow-y-scroll max-h-[330px]">
         <%= for item <- @playlists do %>
           <li class="text-[#F2F6FF] pb-[6px] text-sm">
             <span class="cursor-pointer opacity-100"><%= item.name %></span>
           </li>
         <% end %>

         <a href="#">Load More</a>

          <!--

         <li class="text-[#F2F6FF] pb-[4px] text-sm">
           <span class="opacity-75">Golden Songs</span>
         </li>
           -->
         
       </ul>
     </div>
    """
  end
end
