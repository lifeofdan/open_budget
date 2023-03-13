defmodule OpenBudget.CategoryTest do
  use OpenBudget.DataCase, async: true
  require Ash.Query

  test "can create category" do
    user =
      OpenBudget.Accounts.User
      |> Ash.Changeset.for_create(:register_with_password, %{
        email: "test@user.com",
        hashed_password: "password",
        password: "password",
        password_confirmation: "password"
      })
      |> OpenBudget.Accounts.create!()

    budget =
      OpenBudget.Budgets.Budget
      |> Ash.Changeset.for_create(:new_budget, %{title: "My new budget", active: true},
        actor: user
      )
      |> OpenBudget.Budgets.create!()

    category =
      OpenBudget.Budgets.Category
      |> Ash.Changeset.for_create(:category, %{title: "A Category", budget_id: budget.id},
        actor: user
      )
      |> OpenBudget.Budgets.create!()

    dbg(category)
  end
end
