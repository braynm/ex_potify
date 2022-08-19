defmodule ExPotify.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
  @registry :workers_registry

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      ExPotify.Repo,
      # Start the Telemetry supervisor
      ExPotifyWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: ExPotify.PubSub},
      # Start the Endpoint (http/https)
      ExPotifyWeb.Endpoint,
      {ExPotify.TokenSupervisor, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ExPotify.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ExPotifyWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
