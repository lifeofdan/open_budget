defmodule OpenBudget.Accounts do
  use Ash.Api

  resources do
    registry OpenBudget.Accounts.Registry
  end
end
