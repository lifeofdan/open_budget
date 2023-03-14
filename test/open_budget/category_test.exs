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
      |> OpenBudget.Budgets.create()

    {response, _result} = category

    assert response == :ok
  end

  test "cannot create category if no actor or invalid actor is present" do
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

    no_actor_category =
      OpenBudget.Budgets.Category
      |> Ash.Changeset.for_create(:category, %{title: "New category", budget_id: budget.id})
      |> OpenBudget.Budgets.create()

    {no_actor_response, no_actor_result} = no_actor_category
    %{errors: [%{class: no_actor_class}]} = no_actor_result

    invalid_actor_category =
      OpenBudget.Budgets.Category
      |> Ash.Changeset.for_create(:category, %{title: "New category", budget_id: budget.id},
        actor: budget
      )
      |> OpenBudget.Budgets.create()

    {invalid_actor_response, invalid_actor_result} = invalid_actor_category
    %{errors: [%{class: invalid_actor_class}]} = invalid_actor_result

    assert no_actor_response == :error
    assert no_actor_class == :forbidden
    assert invalid_actor_response == :error
    assert invalid_actor_class == :invalid
  end
end
