defmodule OpenBudget.Repo do
  use AshPostgres.Repo,
    otp_app: :open_budget

  def installed_extensions do
    ["uuid-ossp", "citext"]
  end
end
