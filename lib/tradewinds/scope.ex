defmodule Tradewinds.Scope do
  @moduledoc """
  A struct representing the current execution context (Identity).
  This is passed to Context functions to enforce authorization and access control.
  """
  defstruct [:player, :company_ids]

  @doc """
  Creates a new Scope struct from the given keyword list.
  Automatically populates `company_ids` if a `player` is provided but `company_ids` are missing.
  """
  def for(attrs) when is_list(attrs) do
    attrs =
      Keyword.put_new_lazy(attrs, :company_ids, fn ->
        fetch_company_ids(attrs[:player])
      end)

    struct(__MODULE__, attrs)
  end

  @doc """
  Validates whether the current scope (representing the player's session)
  has permission to act on behalf of the given company ID.
  Returns `:ok` or `{:error, :unauthorized}`.
  """
  def authorizes?(%__MODULE__{company_ids: company_ids}, company_id) do
    if company_id in company_ids do
      :ok
    else
      {:error, :unauthorized}
    end
  end

  def authorizes?(_scope, _company_id), do: {:error, :unauthorized}

  @doc """
  Injects a newly created company ID into the current scope's authorization list.
  Typically used right after a player founds a new company in the same request cycle.
  """
  def put_company_id(%__MODULE__{} = scope, company_id) do
    %{scope | company_ids: [company_id | scope.company_ids]}
  end

  # Lazily loads the list of company IDs a player is a director of.
  defp fetch_company_ids(%Tradewinds.Accounts.Player{} = player) do
    Tradewinds.Companies.list_player_company_ids(player)
  end

  defp fetch_company_ids(_), do: []
end
