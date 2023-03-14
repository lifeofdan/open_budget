defmodule OpenBudget.Budgets.Category do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  relationships do
    belongs_to :budget, OpenBudget.Budgets.Budget do
      primary_key? true
    end

    has_one :category, OpenBudget.Budgets.Category do
      destination_attribute :parent_id
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
    attribute :assigned_limit, :decimal, allow_nil?: false, default: 0.00
    attribute :activity, :decimal, allow_nil?: false, default: 0.00
    attribute :parent_id, :uuid, allow_nil?: true
    attribute :budget_id, :uuid, allow_nil?: false
  end

  code_interface do
    define_for OpenBudget.Budgets
    define :get_by_id, action: :get_category_by_id, args: [:id], get?: true
  end

  actions do
    defaults [:read, :update, :destroy]

    create :category do
      accept [:title, :parent_id]

      argument :budget_id, :uuid do
        allow_nil? false
      end

      change manage_relationship(:budget_id, :budget, type: :append_and_remove)
    end

    update :title do
      require_attributes [:title]
    end

    update :parent do
      require_attributes [:parent_id]
    end

    read :get_category_by_id do
      get? true

      argument :id, :uuid do
        allow_nil? false
      end

      filter id: arg(:id)
    end
  end

  postgres do
    table "categories"
    repo OpenBudget.Repo
  end
end
