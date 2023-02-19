defmodule OpenBudget.Repo do
  use Ecto.Repo,
    otp_app: :open_budget,
    adapter: Ecto.Adapters.Postgres
end
