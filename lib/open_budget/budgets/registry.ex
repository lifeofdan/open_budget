defmodule OpenBudget.Budgets.Registry do
  use Ash.Registry, extensions: [Ash.Registry.ResourceValidations]

  entries do
    entry OpenBudget.Budgets.Budget
    entry OpenBudget.Budgets.BankAccount
    entry OpenBudget.Budgets.Transaction
    entry OpenBudget.Budgets.Category
  end
end
