defmodule TradewindsWeb.AuthController do
  use TradewindsWeb, :controller
  use Goal
  use OpenApiSpex.ControllerSpecs

  alias Tradewinds.Accounts

  alias TradewindsWeb.Schemas.{
    LoginRequest,
    LoginResponse,
    RegisterRequest,
    RegisterResponse,
    ChangesetResponse,
    ErrorResponse
  }

  action_fallback(TradewindsWeb.FallbackController)

  defparams :register do
    required(:name, :string)
    required(:email, :string, format: :email)
    required(:password, :string, min: 8)
    optional(:discord_id, :string)
  end

  operation(:register,
    operation_id: "register",
    tags: ["Accounts"],
    summary: "Register a new player",
    description: "Creates a new player account with the provided details.",
    request_body: {"Registration details", "application/json", RegisterRequest},
    responses: [
      created: {"Player created", "application/json", RegisterResponse},
      unprocessable_entity: {"Validation error", "application/json", ChangesetResponse}
    ]
  )

  def register(conn, params) do
    with {:ok, valid} <- validate(:register, params),
         {:ok, player} <-
           Accounts.register(valid.name, valid.email, valid.password, valid[:discord_id]) do
      conn
      |> put_status(:created)
      |> render(:player, player: player)
    end
  end

  defparams :login do
    required(:email, :string, format: :email)
    required(:password, :string, min: 8)
  end

  operation(:login,
    operation_id: "login",
    tags: ["Accounts"],
    summary: "Login player",
    description: "Authenticates a player and returns a JWT token for subsequent API calls.",
    request_body: {"Login credentials", "application/json", LoginRequest},
    responses: [
      ok: {"Successful login", "application/json", LoginResponse},
      unauthorized:
        {"Invalid credentials", "application/json", ErrorResponse},
      forbidden:
        {"Disabled account", "application/json", ErrorResponse},
      unprocessable_entity: {"Validation error", "application/json", ChangesetResponse}
    ]
  )

  def login(conn, params) do
    with {:ok, valid} <- validate(:login, params),
         {:ok, auth_token} <- Accounts.authenticate(valid.email, valid.password) do
      conn
      |> put_status(:ok)
      |> render(:login, auth_token: auth_token)
    end
  end

  operation(:revoke,
    operation_id: "revoke",
    tags: ["Accounts"],
    summary: "Revoke token",
    description: "Revokes the currently active JWT token, logging the player out.",
    security: [%{"bearerAuth" => []}],
    responses: [
      no_content: "Token successfully revoked",
      unauthorized: {"Invalid or expired token", "application/json", ErrorResponse}
    ]
  )

  def revoke(conn, _params) do
    Accounts.revoke(conn.assigns.token.token)

    send_resp(conn, :no_content, "")
  end

  operation(:me,
    operation_id: "me",
    tags: ["Accounts"],
    summary: "Get current player profile",
    description: "Returns the profile of the currently authenticated player.",
    security: [%{"bearerAuth" => []}],
    responses: [
      ok: {"Current player", "application/json", RegisterResponse},
      unauthorized: {"Invalid or expired token", "application/json", ErrorResponse}
    ]
  )

  def me(conn, _params) do
    conn
    |> put_status(:ok)
    |> render(:player, player: conn.assigns.token.player)
  end
end
