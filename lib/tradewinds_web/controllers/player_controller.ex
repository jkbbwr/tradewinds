defmodule TradewindsWeb.PlayerController do
  use TradewindsWeb, :controller
  action_fallback TradewindsWeb.FallbackController
  alias Tradewinds.Player
  use Goal

  defparams :register do
    required(:name, :string)
    required(:email, :string, format: :email)
    required(:password, :string, min: 8)
  end

  defparams :login do
    required(:email, :string, format: :email)
    required(:password, :string, min: 8)
  end

  def register(conn, params) do
    with {:ok, attrs} <- validate(:register, params),
         {:ok, player} <- Player.register(attrs.name, attrs.email, attrs.password) do
      render(conn, :register, player: player)
    end
  end

  def login(conn, params) do
    with {:ok, attrs} <- validate(:login, params),
         {:ok, token} <- Player.login(attrs.email, attrs.password) do
      render(conn, :login, token: token)
    end
  end
end
