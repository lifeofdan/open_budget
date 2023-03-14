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

  test "can read transactions" do
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

  test "can read single transaction" do
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
      |> OpenBudget.Budgets.create!()

    OpenBudget.Budgets.Transaction
    |> Ash.Changeset.for_create(
      :create_transaction,
      %{
        title: "New transaction 2",
        amount: -14.53,
        bank_account_id: bank_account.id
      },
      actor: budget
    )
    |> OpenBudget.Budgets.create!()

    read_single_transaction =
      OpenBudget.Budgets.Transaction.get_by_id(transaction.id, actor: bank_account)

    {response, result} = read_single_transaction

    assert response == :ok
    assert result.title == "New transaction"
  end

  test "cannot read single transaction without actor" do
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
      |> OpenBudget.Budgets.create!()

    forbidden_transaction = OpenBudget.Budgets.Transaction.get_by_id(transaction.id)

    {response, result} = forbidden_transaction
    %{errors: errors} = result
    [%{class: error_class}] = errors

    assert response == :error
    assert error_class == :forbidden
  end

  test "cannot read single transaction with invalid actor" do
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
      |> OpenBudget.Budgets.create!()

    invalid_transaction = OpenBudget.Budgets.Transaction.get_by_id(transaction.id, actor: budget)

    {invalid_response, invalid_result} = invalid_transaction
    assert invalid_response == :error
    assert invalid_result.class == :invalid
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

  test "can update transaction" do
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
      |> OpenBudget.Budgets.create!()

    assert transaction.title == "New transaction"

    updated_transaction =
      transaction
      |> Ash.Changeset.for_update(:title, %{title: "Updated transaction"}, actor: bank_account)
      |> OpenBudget.Budgets.update!()

    assert updated_transaction.title == "Updated transaction"
  end

  test "cannot update without actor, forbidden" do
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
      |> OpenBudget.Budgets.create!()

    update_transaction =
      transaction
      |> Ash.Changeset.for_update(:title, %{title: "Update transaction"})
      |> OpenBudget.Budgets.update()

    {response, result} = update_transaction
    %{errors: [%{class: result_errors_class}]} = result

    assert response == :error
    assert result_errors_class == :forbidden
  end

  test "cannot update with incorrect actor" do
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
      |> OpenBudget.Budgets.create!()

    update_transaction =
      transaction
      |> Ash.Changeset.for_update(:title, %{title: "Update transaction"}, actor: user)
      |> OpenBudget.Budgets.update()

    {response, result} = update_transaction
    %{errors: [%{class: result_errors_class}]} = result

    assert response == :error
    assert result_errors_class == :forbidden
  end

  test "cannot update amount when using :title action" do
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
      |> OpenBudget.Budgets.create!()

    update_with_amount =
      transaction
      |> Ash.Changeset.for_update(:title, %{amount: 0}, actor: bank_account)
      |> OpenBudget.Budgets.update()

    {response, result} = update_with_amount
    %{errors: [%{class: result_error_class}]} = result

    assert response == :error
    assert result_error_class == :invalid
  end

  test "can destroy transaction" do
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
      |> OpenBudget.Budgets.create!()

    read_transaction =
      OpenBudget.Budgets.Transaction.get_by_id!(transaction.id, actor: bank_account)

    assert read_transaction.title == "New transaction"

    read_transaction
    |> Ash.Changeset.for_destroy(:destroy, %{id: transaction.id}, actor: bank_account)
    |> OpenBudget.Budgets.destroy!()

    read_after_destroyed =
      OpenBudget.Budgets.Transaction.get_by_id(transaction.id, actor: bank_account)

    {response, result} = read_after_destroyed
    %{class: result_class} = result

    assert response == :error
    assert result_class == :invalid
  end

  test "cannot destroy without actor" do
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
      |> OpenBudget.Budgets.create!()

    read_transaction =
      OpenBudget.Budgets.Transaction.get_by_id!(transaction.id, actor: bank_account)

    assert read_transaction.title == "New transaction"

    try_destroy =
      read_transaction
      |> Ash.Changeset.for_destroy(:destroy, %{id: transaction.id})
      |> OpenBudget.Budgets.destroy()

    {response, result} = try_destroy
    %{errors: [%{class: result_error_class}]} = result

    assert response == :error
    assert result_error_class == :forbidden
  end

  test "cannot destroy with invalid actor" do
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
      |> OpenBudget.Budgets.create!()

    read_transaction =
      OpenBudget.Budgets.Transaction.get_by_id!(transaction.id, actor: bank_account)

    assert read_transaction.title == "New transaction"

    try_destroy =
      read_transaction
      |> Ash.Changeset.for_destroy(:destroy, %{id: transaction.id}, actor: budget)
      |> OpenBudget.Budgets.destroy()

    {response, result} = try_destroy
    %{errors: [%{class: result_error_class}]} = result

    assert response == :error
    assert result_error_class == :forbidden
  end
end
