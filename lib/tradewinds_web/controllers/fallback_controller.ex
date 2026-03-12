defmodule TradewindsWeb.FallbackController do
  use TradewindsWeb, :controller

  def call(conn, {:error, :player_not_enabled}) do
    conn
    |> put_status(:forbidden)
    |> put_view(TradewindsWeb.ErrorJSON)
    |> render(:account_disabled)
  end

  def call(conn, {:error, reason})
      when reason in [
             :route_not_found,
             :port_not_found,
             :good_not_found,
             :ship_type_not_found,
             :order_not_found,
             :warehouse_not_found,
             :ship_not_found,
             :shipyard_not_found
           ] do
    conn
    |> put_status(:not_found)
    |> put_view(TradewindsWeb.ErrorJSON)
    |> render(:not_found)
  end

  def call(conn, {:error, reason})
      when reason in [:unauthorized, :email_not_found] do
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
