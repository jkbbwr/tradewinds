defmodule TradewindsWeb.FallbackController do
  use TradewindsWeb, :controller

  def call(conn, {:error, :unauthorized}) do
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
