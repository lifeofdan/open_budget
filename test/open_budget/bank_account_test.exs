defmodule OpenBudget.BankAccountTest do
  alias OpenBudget.Accounts.User
  alias OpenBudget.Budgets.Budget
  use OpenBudget.DataCase, async: true
  require Ash.Query

  test "cannot create bank account with missing fields" do
    user =
      User
      |> Ash.Changeset.for_create(:register_with_password, %{
        email: "test@user.com",
        hashed_password: "password",
        password: "password",
        password_confirmation: "password"
      })
      |> OpenBudget.Accounts.create!()

    budget =
      Budget
      |> Ash.Changeset.for_create(:new_budget, %{title: "My new budget", active: true},
        actor: user
      )
      |> OpenBudget.Budgets.create!()

    no_budget_id_account =
      OpenBudget.Budgets.BankAccount
      |> Ash.Changeset.for_create(
        :create_bank_account,
        %{
          title: "My new account"
        },
        actor: budget
      )
      |> OpenBudget.Budgets.create()

    {no_budget_id_response, _no_budget_id_result} = no_budget_id_account

    assert no_budget_id_response == :error

    no_title_account =
      OpenBudget.Budgets.BankAccount
      |> Ash.Changeset.for_create(
        :create_bank_account,
        %{
          budget_id: budget.id
        },
        actor: budget
      )
      |> OpenBudget.Budgets.create()

    {no_title_account_response, _no_title_result} = no_title_account

    assert no_title_account_response == :error

    no_actor_account =
      OpenBudget.Budgets.BankAccount
      |> Ash.Changeset.for_create(
        :create_bank_account,
        %{
          title: "My new account",
          budget_id: budget.id
        }
      )
      |> OpenBudget.Budgets.create()

    {no_actor_account_response, _no_actor_account_result} = no_actor_account

    assert no_actor_account_response == :error
  end

  test "can create bank account" do
    user =
      User
      |> Ash.Changeset.for_create(:register_with_password, %{
        email: "test@user.com",
        hashed_password: "password",
        password: "password",
        password_confirmation: "password"
      })
      |> OpenBudget.Accounts.create!()

    budget =
      Budget
      |> Ash.Changeset.for_create(:new_budget, %{title: "My new budget", active: true},
        actor: user
      )
      |> OpenBudget.Budgets.create!()

    account =
      OpenBudget.Budgets.BankAccount
      |> Ash.Changeset.for_create(
        :create_bank_account,
        %{
          title: "My new account",
          budget_id: budget.id
        },
        actor: user
      )
      |> OpenBudget.Budgets.create!()

    %{title: title} = account

    assert title == "My new account"
  end

  test "must have budget to update" do
    user =
      User
      |> Ash.Changeset.for_create(:register_with_password, %{
        email: "test@user.com",
        hashed_password: "password",
        password: "password",
        password_confirmation: "password"
      })
      |> OpenBudget.Accounts.create!()

    budget =
      Budget
      |> Ash.Changeset.for_create(:new_budget, %{title: "My new budget", active: true},
        actor: user
      )
      |> OpenBudget.Budgets.create!()

    account =
      OpenBudget.Budgets.BankAccount
      |> Ash.Changeset.for_create(
        :create_bank_account,
        %{
          title: "My new account",
          budget_id: budget.id
        },
        actor: user
      )
      |> OpenBudget.Budgets.create!()

    update_account_error =
      account
      |> Ash.Changeset.for_update(:update_title, %{title: "My new account updated"})
      |> OpenBudget.Budgets.update()

    {response, _result} = update_account_error

    assert response == :error

    update_account_ok =
      account
      |> Ash.Changeset.for_update(:update_title, %{title: "My new account updated"}, actor: budget)
      |> OpenBudget.Budgets.update()

    {response_ok, _result_ok} = update_account_ok

    assert response_ok == :ok
  end

  test "can only read account if is your budget" do
    user =
      User
      |> Ash.Changeset.for_create(:register_with_password, %{
        email: "test@user.com",
        hashed_password: "password",
        password: "password",
        password_confirmation: "password"
      })
      |> OpenBudget.Accounts.create!()

    budget =
      Budget
      |> Ash.Changeset.for_create(:new_budget, %{title: "My new budget", active: true},
        actor: user
      )
      |> OpenBudget.Budgets.create!()

    OpenBudget.Budgets.BankAccount
    |> Ash.Changeset.for_create(
      :create_bank_account,
      %{
        title: "My new account",
        budget_id: budget.id
      },
      actor: user
    )
    |> OpenBudget.Budgets.create!()

    no_budget_read_account =
      OpenBudget.Budgets.BankAccount
      |> Ash.Query.for_read(:read, %{})
      |> OpenBudget.Budgets.read()

    {no_budget_read_response, _no_budget_read_response} = no_budget_read_account

    assert no_budget_read_response == :error

    read_account =
      OpenBudget.Budgets.BankAccount
      |> Ash.Query.for_read(:read, %{}, actor: budget)
      |> OpenBudget.Budgets.read()

    {read_account_response, _read_account_result} = read_account

    assert read_account_response == :ok
  end

  test "can destroy with budget, cannot destroy without budget" do
    user =
      User
      |> Ash.Changeset.for_create(:register_with_password, %{
        email: "test@user.com",
        hashed_password: "password",
        password: "password",
        password_confirmation: "password"
      })
      |> OpenBudget.Accounts.create!()

    budget =
      Budget
      |> Ash.Changeset.for_create(:new_budget, %{title: "My new budget", active: true},
        actor: user
      )
      |> OpenBudget.Budgets.create!()

    account =
      OpenBudget.Budgets.BankAccount
      |> Ash.Changeset.for_create(
        :create_bank_account,
        %{
          title: "My new account",
          budget_id: budget.id
        },
        actor: user
      )
      |> OpenBudget.Budgets.create!()

    cannot_destroy =
      account
      |> Ash.Changeset.for_destroy(:destroy)
      |> OpenBudget.Budgets.destroy()

    {cannot_destroy_response, _cannot_destroy_result} = cannot_destroy

    assert cannot_destroy_response == :error

    can_destroy =
      account
      |> Ash.Changeset.for_destroy(:destroy, %{}, actor: budget)
      |> OpenBudget.Budgets.destroy()

    assert can_destroy == :ok
  end
end
