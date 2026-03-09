defmodule TradewindsWeb.FallbackController do
  use TradewindsWeb, :controller

  def call(conn, {:error, reason}) when reason in [:unauthorized, :email_not_found, :player_not_enabled] do
    conn
    |> put_status(:unauthorized)
    |> put_view(TradewindsWeb.ErrorJSON)
    |> render(:unauthorized)
  end

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(TradewindsWeb.ErrorJSON)
    |> render(:error, changeset: changeset)
  end
end
