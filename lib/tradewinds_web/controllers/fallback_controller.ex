defmodule TradewindsWeb.FallbackController do
  use TradewindsWeb, :controller

  def call(conn, {:error, :player_not_enabled}) do
    conn
    |> put_status(:forbidden)
    |> put_view(TradewindsWeb.ErrorJSON)
    |> render(:account_disabled)
  end

  def call(conn, {:error, :wrong_location}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(TradewindsWeb.ErrorJSON)
    |> render("unprocessable_entity.json",
      message: "You are not at the correct location to perform this action."
    )
  end

  def call(conn, {:error, :quantity_mismatch}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(TradewindsWeb.ErrorJSON)
    |> render("unprocessable_entity.json", message: "Quantity mismatch detected")
  end

  def call(conn, {:error, :missing_parameters}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(TradewindsWeb.ErrorJSON)
    |> render("unprocessable_entity.json", message: "Missing required parameters.")
  end

  def call(conn, {:error, :not_at_port}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(TradewindsWeb.ErrorJSON)
    |> render("unprocessable_entity.json", message: "Not at port")
  end

  def call(conn, {:error, :insufficient_funds}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: TradewindsWeb.ErrorJSON)
    |> render(:error, status: :insufficient_funds)
  end

  def call(conn, {:error, :bankrupt}) do
    conn
    |> put_status(:unauthorized)
    |> put_view(TradewindsWeb.ErrorJSON)
    |> render(:unauthorized, reason: "bankrupt")
  end

  def call(conn, {:error, {reason, id}})
      when reason in [
             :route_not_found,
             :port_not_found,
             :good_not_found,
             :ship_type_not_found,
             :order_not_found,
             :warehouse_not_found,
             :ship_not_found,
             :shipyard_not_found,
             :company_not_found,
             :cargo_not_found,
             :inventory_not_found,
             :trader_position_not_found,
             :market_not_found,
             :country_not_found
           ] do
    conn
    |> put_status(:not_found)
    |> put_view(TradewindsWeb.ErrorJSON)
    |> render(:not_found, reason: reason, id: id)
  end

  def call(conn, {:error, reason})
      when reason in [:unauthorized] do
    conn
    |> put_status(:unauthorized)
    |> put_view(TradewindsWeb.ErrorJSON)
    |> render(:unauthorized)
  end

  def call(conn, {:error, {:player_not_found, _}}) do
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
