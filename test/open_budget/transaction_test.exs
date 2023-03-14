defmodule OpenBudget.TransactionTest do
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

    {response, _result} = transaction

    assert response == :ok
  end

  test "cannot create transaction without title" do
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

    no_title_transaction =
      OpenBudget.Budgets.Transaction
      |> Ash.Changeset.for_create(
        :create_transaction,
        %{
          amount: -14.53,
          bank_account_id: bank_account.id
        },
        actor: budget
      )
      |> OpenBudget.Budgets.create()

    {response, result} = no_title_transaction

    assert response == :error

    %{errors: errors} = result
    [%{field: error_field, class: error_class}] = errors

    assert error_field == :title
    assert error_class == :invalid
  end

  test "cannot create transaction without bank_account_id" do
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
          amount: -14.53
        },
        actor: budget
      )
      |> OpenBudget.Budgets.create()

    {response, result} = transaction

    assert response == :error

    %{errors: errors} = result
    [%{field: error_field, class: error_class}] = errors

    assert error_field == :bank_account_id
    assert error_class == :invalid
  end

  test "creating transaction without amount defaults to 0" do
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
          bank_account_id: bank_account.id
        },
        actor: budget
      )
      |> OpenBudget.Budgets.create()

    {response, result} = transaction

    assert response == :ok
    assert Decimal.to_integer(result.amount) == 0
  end

  test "cannot create transaction without budget as actor" do
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
          amount: -10.02,
          bank_account_id: bank_account.id
        }
      )
      |> OpenBudget.Budgets.create()

    {response, result} = transaction

    assert response == :error

    %{errors: errors} = result
    [%{class: error_class}] = errors

    assert error_class == :forbidden

    invalid_actor_transaction =
      OpenBudget.Budgets.Transaction
      |> Ash.Changeset.for_create(
        :create_transaction,
        %{
          title: "New transaction",
          amount: -10.02,
          bank_account_id: bank_account.id
        },
        actor: user
      )
      |> OpenBudget.Budgets.create()

    {invalid_actor_response, invalid_actor_result} = invalid_actor_transaction

    assert invalid_actor_response == :error

    %{errors: invalid_actor_errors} = invalid_actor_result
    [%{class: invalid_actor_error_class}] = invalid_actor_errors

    assert invalid_actor_error_class == :invalid
  end

  test "can read transaction" do
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
    |> OpenBudget.Budgets.create!()

    read_transaction =
      OpenBudget.Budgets.Transaction
      |> Ash.Query.for_read(:read, %{}, actor: bank_account)
      |> OpenBudget.Budgets.read()

    {response, _result} = read_transaction
    assert response == :ok
  end

  test "cannot read data with invalid actor" do
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
    |> OpenBudget.Budgets.create!()

    read_transaction_empty =
      OpenBudget.Budgets.Transaction
      # user is the wrong thing to pass
      |> Ash.Query.for_read(:read, %{}, actor: user)
      |> OpenBudget.Budgets.read!()

    assert read_transaction_empty == []

    read_transaction_ok =
      OpenBudget.Budgets.Transaction
      |> Ash.Query.for_read(:read, %{}, actor: bank_account)
      |> OpenBudget.Budgets.read!()

    assert length(read_transaction_ok) != 0
  end
end
