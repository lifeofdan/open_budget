defmodule OpenBudget.Accounts.Registry do
  use Ash.Registry, extensions: [Ash.Registry.ResourceValidations]

  entries do
    entry OpenBudget.Accounts.User
    entry OpenBudget.Accounts.Token
  end
end
