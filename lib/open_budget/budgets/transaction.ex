defmodule OpenBudget.Budgets.Transaction do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

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
  end

  postgres do
    table "transactions"
    repo OpenBudget.Repo
  end
end
