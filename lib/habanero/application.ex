defmodule Habanero.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      HabaneroWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Habanero.PubSub},
      # Start the Endpoint (http/https)
      HabaneroWeb.Endpoint,
      # Start a worker by calling: Habanero.Worker.start_link(arg)
      # {Habanero.Worker, arg}
      Habanero.Loader.Supervisor,
      Habanero.Loader.Starter
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Habanero.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    HabaneroWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
