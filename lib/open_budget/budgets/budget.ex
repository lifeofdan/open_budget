defmodule OpenBudget.Budgets.Budget do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  relationships do
    belongs_to :user, OpenBudget.Accounts.User do
      api OpenBudget.Accounts.User
    end
  end

  attributes do
    uuid_primary_key :id
    attribute :title, :string, allow_nil?: false
  end

  actions do
    update :assign do
      # No attributes should be accepted
      accept []

      # We accept a representative's id as input here
      argument :user_id, :uuid do
        # This action requires representative_id
        allow_nil? false
      end

      change manage_relationship(:user_id, :user, type: :append_and_remove)
    end
  end

  postgres do
    table "budgets"
    repo OpenBudget.Repo
  end
end
