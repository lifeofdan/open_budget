defmodule OpenBudget.Budgets.BankAccount do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  relationships do
    belongs_to :budget, OpenBudget.Budgets.Budget do
      primary_key? true
    end
  end

  policies do
    policy action_type(:create) do
      authorize_if actor_present()
    end

    policy action_type([:read, :update]) do
      authorize_if relates_to_actor_via(:budget)
    end
  end

  attributes do
    uuid_primary_key :id
    attribute :title, :string, allow_nil?: false
    attribute :balance, :decimal, allow_nil?: false, default: 0
    attribute :budget_id, :uuid, allow_nil?: false
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

    update :update_title do
      require_attributes [:title]
    end
  end

  postgres do
    table "bank_accounts"
    repo OpenBudget.Repo
  end
end
