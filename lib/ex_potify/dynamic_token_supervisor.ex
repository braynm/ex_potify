defmodule ExPotify.DynamicTokenSupervisor do
  use DynamicSupervisor

  def start_link(_args),
    do: DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)

  def init(_args),
    do: DynamicSupervisor.init(strategy: :one_for_one)

  def start_child(child_name) do
    DynamicSupervisor.start_child(
      __MODULE__,
      {ExPotify.TokenRefresher, child_name}
    )
  end
end
