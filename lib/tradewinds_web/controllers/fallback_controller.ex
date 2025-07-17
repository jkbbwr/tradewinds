defmodule TradewindsWeb.FallbackController do
  @moduledoc """
  Handles fallback responses for controllers.
  """
  use TradewindsWeb, :controller
  require Logger

  @doc """
  Handles `{:error, :not_found}` tuples.
  """
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
  end

  @doc """
  Handles `{:error, changeset}` tuples.
  """
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:bad_request)
    |> put_view(TradewindsWeb.ErrorJSON)
    |> render(:error, changeset: changeset)
  end
end
