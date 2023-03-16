defmodule OpenBudget.Budgets.BankAccount do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  relationships do
    belongs_to :budget, OpenBudget.Budgets.Budget do
      primary_key? true
    end

    has_many :transaction, OpenBudget.Budgets.Transaction do
      destination_attribute :bank_account_id
    end
  end

  policies do
    policy action_type(:create) do
      authorize_if actor_present()
    end

    policy action_type([:read, :update, :destroy]) do
      authorize_if relates_to_actor_via(:budget)
    end
  end

  attributes do
    uuid_primary_key :id
    attribute :title, :string, allow_nil?: false
    attribute :balance, :decimal, allow_nil?: false, default: 0
    attribute :budget_id, :uuid, allow_nil?: false
  end

  code_interface do
    define_for OpenBudget.Budgets
    define :get_by_id, action: :get_bank_account_by_id, args: [:id], get?: true
  end

  actions do
    defaults [:read, :update, :destroy]

    create :create_bank_account do
      accept [:title]

      argument :budget_id, :uuid do
        allow_nil? false
      end

      change manage_relationship(:budget_id, :budget, type: :append_and_remove)
    end

    read :get_bank_account_by_id do
      get? true

      argument :id, :uuid do
        allow_nil? false
      end

      filter id: arg(:id)
    end

    update :update_title do
      require_attributes [:title]
    end

    update :balance do
      require_attributes [:balance]
    end
  end

  postgres do
    table "bank_accounts"
    repo OpenBudget.Repo
  end
end
