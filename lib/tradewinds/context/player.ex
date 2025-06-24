defmodule Tradewinds.Player do
  alias Tradewinds.Repo.PlayerRepo
  alias Tradewinds.Repo.AuthTokenRepo

  defdelegate register(name, email, password), to: PlayerRepo

  defp verify_pass(player, password) do
    if Argon2.verify_pass(password, player.password_hash) do
      :ok
    else
      {:error, :invalid_credentials}
    end
  end

  defp is_enabled(player) do
    if player.enabled, do: :ok, else: {:error, :player_not_enabled}
  end

  def login(email, password) do
    with {:ok, player} <- PlayerRepo.find_by_email(email),
         :ok <- verify_pass(player, password),
         :ok <- is_enabled(player) do
      AuthTokenRepo.create(player.id)
    else
      {:error, :not_found} ->
        Argon2.no_user_verify()
        {:error, :invalid_credentials}

      error ->
        error
    end
  end
end
