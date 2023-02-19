defmodule OpenBudget.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      OpenBudgetWeb.Telemetry,
      # Start the Ecto repository
      OpenBudget.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: OpenBudget.PubSub},
      # Start Finch
      {Finch, name: OpenBudget.Finch},
      # Start the Endpoint (http/https)
      OpenBudgetWeb.Endpoint,
      # Start a worker by calling: OpenBudget.Worker.start_link(arg)
      # {OpenBudget.Worker, arg}
      {AshAuthentication.Supervisor, otp_app: :open_budget}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: OpenBudget.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    OpenBudgetWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
