defmodule :"Elixir.OpenBudget.Repo.Migrations.Add accounts to budget" do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:bank_accounts) do
      modify :budget_id, :uuid, null: false
    end
  end

  def down do
    alter table(:bank_accounts) do
      modify :budget_id, :uuid, null: true
    end
  end
end