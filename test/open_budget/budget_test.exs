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
      |> Ash.Changeset.for_create(:new_budget, %{title: "My new budget", active: true},
        actor: user
      )
      |> OpenBudget.Budgets.create!()

    assert budget.title == "My new budget"
  end

  test "cannot create budget without user" do
    budget =
      OpenBudget.Budgets.Budget
      |> Ash.Changeset.for_create(:new_budget, %{title: "My new budget", active: true})

    %{errors: errors} = budget
    [%{relationship: relationship_error, class: error_type}] = errors

    assert relationship_error == :user
    assert error_type == :invalid
  end

  test "can read own budget, cannot read another user's budget" do
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

    OpenBudget.Budgets.Budget
    |> Ash.Changeset.for_create(:new_budget, %{title: "My user_one budget", active: true},
      actor: user_one
    )
    |> OpenBudget.Budgets.create!()

    read_budget_user_one =
      OpenBudget.Budgets.Budget
      |> Ash.Query.for_read(:read, %{}, actor: user_one)
      |> OpenBudget.Budgets.read()

    read_budget_user_two =
      OpenBudget.Budgets.Budget
      |> Ash.Query.for_read(:read, %{}, actor: user_two)
      |> OpenBudget.Budgets.read!()

    {response, _result} = read_budget_user_one

    assert response == :ok
    assert read_budget_user_two == []
  end

  test "cannot read budget without an actor" do
    read_budget =
      OpenBudget.Budgets.Budget
      |> Ash.Query.for_read(:read, %{})
      |> OpenBudget.Budgets.read()

    {err, _response} = read_budget
    assert err == :error
  end

  test "cannot create budget without title or setting active status" do
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
      |> OpenBudget.Budgets.create()

    {response, result} = budget

    assert response == :error

    %{errors: [first, last]} = result
    %{field: first_field, class: first_class} = first
    %{field: last_field, class: last_class} = last

    assert first_field == :title
    assert first_class == :invalid
    assert last_field == :active
    assert last_class == :invalid
  end

  test "user can update own budget title or active status, user cannot update other user's budget" do
    user_one =
      OpenBudget.Accounts.User
      |> Ash.Changeset.for_create(:register_with_password, %{
        email: "test@user.com",
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
      |> Ash.Changeset.for_create(:new_budget, %{title: "My new budget", active: true},
        actor: user_one
      )
      |> OpenBudget.Budgets.create!()

    %{title: title} = budget

    assert title == "My new budget"

    updated_budget =
      budget
      |> Ash.Changeset.for_update(:update_title, %{title: "My updated budget"}, actor: user_one)
      |> OpenBudget.Budgets.update!()

    %{title: updated_title} = updated_budget

    assert updated_title == "My updated budget"

    updated_budget_status =
      budget
      |> Ash.Changeset.for_update(:update_active, %{active: false}, actor: user_one)
      |> OpenBudget.Budgets.update!()

    %{active: updated_active} = updated_budget_status

    assert updated_active == false

    updated_budget_user_two =
      budget
      |> Ash.Changeset.for_update(:update_title, %{title: "My updated budget by user two"},
        actor: user_two
      )
      |> OpenBudget.Budgets.update()

    {response, _result} = updated_budget_user_two

    assert response == :error

    updated_budget_status_user_two =
      budget
      |> Ash.Changeset.for_update(:update_active, %{active: false}, actor: user_two)
      |> OpenBudget.Budgets.update()

    {status_response, _status_result} = updated_budget_status_user_two

    assert status_response == :error
  end

  test "
    user can delete own budget,
    user cannot delete other user's budget,
    must pass user to delete budget" do
    user_one =
      OpenBudget.Accounts.User
      |> Ash.Changeset.for_create(:register_with_password, %{
        email: "test@user.com",
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
      |> Ash.Changeset.for_create(:new_budget, %{title: "My new budget", active: true},
        actor: user_one
      )
      |> OpenBudget.Budgets.create!()

    user_two_attempt_delete =
      budget
      |> Ash.Changeset.for_destroy(:destroy, %{}, actor: user_two)
      |> OpenBudget.Budgets.destroy()

    {user_two_response, _user_two_result} = user_two_attempt_delete

    assert user_two_response == :error

    no_user_attempt_delete =
      budget
      |> Ash.Changeset.for_destroy(:destroy)
      |> OpenBudget.Budgets.destroy()

    {no_user_response, _no_user_result} = no_user_attempt_delete

    assert no_user_response == :error

    user_one_attempt_delete =
      budget
      |> Ash.Changeset.for_destroy(:destroy, %{}, actor: user_one)
      |> OpenBudget.Budgets.destroy()

    assert user_one_attempt_delete == :ok

    get_budgets_after_destroy =
      OpenBudget.Budgets.Budget
      |> Ash.Query.for_read(:read, %{}, actor: user_one)
      |> OpenBudget.Budgets.read!()

    assert get_budgets_after_destroy == []
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
      |> Ash.Changeset.for_create(:new_budget, %{title: "My new budget", active: true},
        actor: user
      )
      |> OpenBudget.Budgets.create()

    {response, _result} = budget

    assert response == :ok
  end
end
