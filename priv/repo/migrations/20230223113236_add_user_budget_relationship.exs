defmodule OpenBudget.Repo.Migrations.AddUserBudgetRelationship do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:budgets) do
      add :user_id,
          references(:users,
            column: :id,
            name: "budgets_user_id_fkey",
            type: :uuid,
            prefix: "public"
          )
    end
  end

  def down do
    drop constraint(:budgets, "budgets_user_id_fkey")

    alter table(:budgets) do
      remove :user_id
    end
  end
end