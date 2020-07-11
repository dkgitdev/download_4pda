defmodule Download4pda.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      Download4pdaWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Download4pda.PubSub},
      # Start the Endpoint (http/https)
      Download4pdaWeb.Endpoint,
      # Start a worker by calling: Download4pda.Worker.start_link(arg)
      # {Download4pda.Worker, arg}
      Download4pda.Downloads.TempLinks
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Download4pda.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Download4pdaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
