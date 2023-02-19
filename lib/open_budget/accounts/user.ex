defmodule OpenBudget.Accounts.User do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication]

  attributes do
    uuid_primary_key :id
    attribute :email, :ci_string, allow_nil?: false
    attribute :hashed_password, :string, allow_nil?: false, sensitive?: true
  end

  authentication do
    api OpenBudget.Accounts

    strategies do
      password :password do
        identity_field(:email)

        resettable do
          sender(OpenBudget.Accounts.User.Senders.SendPasswordResetEmail)
        end
      end
    end

    tokens do
      enabled?(true)
      token_resource(OpenBudget.Accounts.Token)

      signing_secret(
        Application.compile_env(:open_budget, OpenBudgetWeb.Endpoint)[:secret_key_base]
      )
    end
  end

  postgres do
    table "users"
    repo OpenBudget.Repo
  end

  identities do
    identity :unique_email, [:email]
  end
end
