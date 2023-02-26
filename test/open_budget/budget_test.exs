defmodule OpenBudget.BudgetTest do
  alias OpenBudget.Accounts.User
  use OpenBudget.DataCase, async: true
  require Ash.Query

  test "can create budget" do
    user =
      OpenBudget.Accounts.User
      |> Ash.Changeset.for_create(:register_with_password, %{
        email: "test@user.com",
        hashed_password: "password",
        password: "password",
        password_confirmation: "password"
      })
      |> OpenBudget.Accounts.create!()

    %User{email: email} = user

    assert Ash.CiString.value(email) == "test@user.com"

    budget =
      OpenBudget.Budgets.Budget
      |> Ash.Changeset.for_create(:new_budget, %{title: "My new budget"}, actor: user)
      |> OpenBudget.Budgets.create!()

    assert budget.title == "My new budget"
  end

  test "cannot create budget without user" do
    budget =
      OpenBudget.Budgets.Budget
      |> Ash.Changeset.for_create(:new_budget, %{title: "My new budget"})

    %{errors: errors} = budget
    [%{relationship: relationship_error, class: error_type}] = errors

    assert relationship_error == :user
    assert error_type == :invalid
  end

  test "cannot read another user's budget" do
    user_one =
      OpenBudget.Accounts.User
      |> Ash.Changeset.for_create(:register_with_password, %{
        email: "test@user1.com",
        hashed_password: "password",
        password: "password",
        password_confirmation: "password"
      })
      |> OpenBudget.Accounts.create!()

    user_two =
      OpenBudget.Accounts.User
      |> Ash.Changeset.for_create(:register_with_password, %{
        email: "test@user2.com",
        hashed_password: "password",
        password: "password",
        password_confirmation: "password"
      })
      |> OpenBudget.Accounts.create!()

    budget =
      OpenBudget.Budgets.Budget
      |> Ash.Changeset.for_create(:new_budget, %{title: "My user_one budget"}, actor: user_one)
      |> OpenBudget.Budgets.create!()

    # This is not working TODO. This should error without a user.
    read_budget =
      OpenBudget.Budgets.Budget
      |> Ash.Query.for_read(:read)
      |> OpenBudget.Budgets.read!()
  end

  test "cannot create budget without title" do
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
      |> Ash.Changeset.for_create(:new_budget, %{}, actor: user)

    %{errors: errors} = budget
    [%{field: error_field, class: error_type}] = errors

    assert error_field == :title
    assert error_type == :invalid
  end

  test "can assign user to budget" do
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
      |> Ash.Changeset.for_create(:new_budget, %{title: "My new budget"}, actor: user)
      |> OpenBudget.Budgets.create!()
  end
end
