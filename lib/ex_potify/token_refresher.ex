defmodule ExPotify.TokenRefresher do
  use GenServer
  require Logger

  @registry :token_refresher

  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: via_tuple(name))
  end

  def stop(name), do: GenServer.stop(via_tuple(name))
  def crash(name), do: GenServer.cast(via_tuple(name), :raise)

  def get_access_token(name),
    do: GenServer.call(via_tuple(name), :get_token)

  defp request_new_access_token(account) do
    credentials = %Spotify.Credentials{refresh_token: account.refresh_token}
    {:ok, token} = Spotify.Authentication.refresh(credentials)

    %{
      user_id: account.username,
      refresh_token: account.refresh_token,
      access_token: token.access_token
    }
  end

  defp refresh_token() do
    send(self(), :refresh)
  end

  def init(user_id) do
    refresh_token()

    {:ok, %{user_id: user_id}}
  end

  def handle_info(:refresh, %{user_id: user_id}) do
    account = ExPotify.Account.fetch_account(user_id)

    new_state = request_new_access_token(account)

    IO.inspect(DateTime.utc_now())

    Process.send_after(self(), :refresh, 60 * 1000)
    {:noreply, new_state}
  end

  def handle_call(:get_token, from, %{access_token: token} = state) do
    {:reply, token, state}
  end

  def terminate(reason, name) do
    Logger.info("Exiting worker: #{name} with reason: #{inspect(reason)}")
  end

  def handle_cast(:raise, name),
    do: raise(RuntimeError, message: "Error, Server #{name} has crashed")

  defp via_tuple(name),
    do: {:via, Registry, {@registry, name}}
end
