defmodule GarageGenie.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      GarageGenieWeb.Telemetry,
      GarageGenie.Repo,
      {DNSCluster, query: Application.get_env(:garage_genie, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: GarageGenie.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: GarageGenie.Finch},
      # Start a worker by calling: GarageGenie.Worker.start_link(arg)
      # {GarageGenie.Worker, arg},
      # Start to serve requests, typically the last entry
      GarageGenieWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GarageGenie.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    GarageGenieWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
