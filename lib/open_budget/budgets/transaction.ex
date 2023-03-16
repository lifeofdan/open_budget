defmodule OpenBudget.Budgets.Transaction do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  require Decimal

  relationships do
    belongs_to :bank_account, OpenBudget.Budgets.BankAccount do
      primary_key? true
    end
  end

  policies do
    policy action_type(:create) do
      authorize_if actor_present()
    end

    policy action_type([:read, :update, :destroy]) do
      authorize_if relates_to_actor_via(:bank_account)
    end
  end

  attributes do
    uuid_primary_key :id
    attribute :title, :string, allow_nil?: false
    attribute :amount, :decimal, allow_nil?: false, default: 0
    attribute :bank_account_id, :uuid, allow_nil?: false
    attribute :pending, :boolean, allow_nil?: false, default: true
  end

  code_interface do
    define_for OpenBudget.Budgets
    define :get_by_id, action: :get_transaction_by_id, args: [:id], get?: true
  end

  actions do
    defaults [:read, :update, :destroy]

    create :create_transaction do
      accept [:title, :amount]

      argument :bank_account_id, :uuid do
        allow_nil? false
      end

      change manage_relationship(:bank_account_id, :bank_account, type: :append_and_remove)
    end

    update :title do
      accept [:title]
    end

    update :amount do
      accept [:amount]
    end

    read :get_transaction_by_id do
      get? true

      argument :id, :uuid do
        allow_nil? false
      end

      filter id: arg(:id)
    end

    update :clear do
      change set_attribute(:pending, false)

      argument :budget, :map do
        allow_nil? false
      end

      change fn changeset, _ ->
        Ash.Changeset.after_action(changeset, fn changeset, result ->
          budget = changeset.arguments.budget

          bank_account =
            OpenBudget.Budgets.BankAccount
            |> Ash.Query.for_read(:read, %{}, actor: budget)
            |> OpenBudget.Budgets.read_one!()

          new_balance = Decimal.add(result.bank_account.balance, result.amount)

          updated_bank_account =
            bank_account
            |> Ash.Changeset.for_update(
              :balance,
              %{balance: new_balance},
              actor: budget
            )
            |> OpenBudget.Budgets.update!()

          {:ok, result}
        end)
      end
    end

    update :pending do
      change set_attribute(:pending, true)

      argument :budget, :map do
        allow_nil? false
      end

      change fn changeset, _ ->
        Ash.Changeset.after_action(changeset, fn changeset, result ->
          budget = changeset.arguments.budget

          bank_account =
            OpenBudget.Budgets.BankAccount
            |> Ash.Query.for_read(:read, %{}, actor: budget)
            |> OpenBudget.Budgets.read_one!()

          new_balance = 0

          if bank_account >= 0 do
            new_balance = Decimal.sub(result.bank_account.balance, result.amount)
          else
            negative_to_positive = Decimal.mult(-1, result.amount)
            new_balance = Decimal.add(result.bank_account.balance, negative_to_positive)
          end

          updated_bank_account =
            bank_account
            |> Ash.Changeset.for_update(
              :balance,
              %{balance: new_balance},
              actor: budget
            )
            |> OpenBudget.Budgets.update!()

          {:ok, result}
        end)
      end
    end
  end

  postgres do
    table "transactions"
    repo OpenBudget.Repo
  end
end
