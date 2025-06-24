defmodule Tradewinds.Repo.AuthTokenRepo do
  alias Tradewinds.Repo
  alias Tradewinds.Schema.AuthToken
  alias Phoenix.Token
  import Ecto.Changeset

  def create(player_id) do
    # Token expires in 24 hours
    token_lifespan = 24 * 60 * 60

    signed_token =
      Token.sign(TradewindsWeb.Endpoint, "user auth", player_id, max_age: token_lifespan)

    %AuthToken{}
    |> cast(%{player_id: player_id, token: signed_token}, [:token, :player_id])
    |> validate_required([:token, :player_id])
    |> Repo.insert()
  end
end
