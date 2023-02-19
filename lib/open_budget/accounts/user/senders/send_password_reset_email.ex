defmodule OpenBudget.Accounts.User.Senders.SendPasswordResetEmail do
  @moduledoc """
  Sends a password reset email
  """
  use AshAuthentication.Sender
  use OpenBudgetWeb, :verified_routes

  def send(user, token, _) do
    OpenBudget.Accounts.Emails.deliver_reset_password_instructions(
      user,
      url(~p"/password-reset/#{token}")
    )
  end
end
