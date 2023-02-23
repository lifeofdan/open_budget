defmodule OpenBudget.Budgets do
  use Ash.Api

  resources do
    registry OpenBudget.Budgets.Registry
  end
end
