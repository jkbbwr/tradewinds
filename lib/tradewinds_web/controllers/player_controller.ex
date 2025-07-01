defmodule TradewindsWeb.PlayerController do
  use TradewindsWeb, :controller
  action_fallback TradewindsWeb.FallbackController
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
end
