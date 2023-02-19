defmodule OpenBudget.Accounts.Token do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication.TokenResource]

  token do
    api OpenBudget.Accounts
  end

  postgres do
    table "tokens"
    repo OpenBudget.Repo
  end
end
