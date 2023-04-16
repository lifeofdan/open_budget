defmodule OpenBudgetWeb.DashboardController do
  use OpenBudgetWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end
end
