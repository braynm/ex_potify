defmodule ExPotify.TokenSupervisor do
  @moduledoc """
  This supervisor are for:
  - A supervisor monitoring token refresher.
  - A Registry providing a key-value store for per-user processes (uses username from Spotify).
  """

  use Supervisor
  @registry :token_refresher

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(args) do
    children = [
      {Registry, [keys: :unique, name: @registry]},
      {ExPotify.DynamicTokenSupervisor, []}
    ]

    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.init(children, opts)
  end
end
