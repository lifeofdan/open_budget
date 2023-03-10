defmodule OpenBudget.TransactionTest do
  alias OpenBudget.Accounts.User
  use OpenBudget.DataCase, async: true
  require Ash.Query

  test "can create transaction" do
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

    bank_account =
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

    transaction =
      OpenBudget.Budgets.Transaction
      |> Ash.Changeset.for_create(
        :create_transaction,
        %{
          title: "New transaction",
          amount: -14.53,
          bank_account_id: bank_account.id
        },
        actor: budget
      )
      |> OpenBudget.Budgets.create()

    {response, result} = transaction

    assert response == :ok
  end
end
