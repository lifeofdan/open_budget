defmodule OpenBudget.Budgets.Budget do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  relationships do
    belongs_to :user, OpenBudget.Accounts.User do
      api OpenBudget.Accounts.User
      attribute_writable? true
    end

    has_many :bank_account, OpenBudget.Budgets.BankAccount do
      destination_attribute :budget_id
    end

    has_many :category, OpenBudget.Budgets.Category do
      destination_attribute :budget_id
    end
  end

  policies do
    policy action_type(:create) do
      # You must be a user in order to create a budget
      authorize_if actor_present()
    end

    policy action_type([:read, :update, :destroy]) do
      # You can only read or update your own budget
      authorize_if relates_to_actor_via(:user)
    end
  end

  attributes do
    uuid_primary_key :id
    attribute :title, :string, allow_nil?: false
    attribute :active, :boolean, allow_nil?: false, default: false
  end

  actions do
    defaults [:read, :update, :destroy]

    create :create do
      primary? true
      change relate_actor(:user)
    end

    create :new_budget do
      require_attributes [:title, :active]

      argument :user, OpenBudget.Accounts.User
      change relate_actor(:user)
    end

    update :update_title do
      require_attributes [:title]
    end

    update :update_active do
      require_attributes [:active]
    end
  end

  postgres do
    table "budgets"
    repo OpenBudget.Repo
  end
end
