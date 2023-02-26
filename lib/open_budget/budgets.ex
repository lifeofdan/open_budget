defmodule OpenBudget.Budgets do
  use Ash.Api

  authorization do
    authorize :by_default
  end

  resources do
    registry OpenBudget.Budgets.Registry
  end
end
