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
    attrs = Keyword.put_new_lazy(attrs, :company_ids, fn ->
      fetch_company_ids(attrs[:player])
    end)

    struct(__MODULE__, attrs)
  end

  defp fetch_company_ids(%Tradewinds.Accounts.Player{} = player) do
    Tradewinds.Companies.list_player_company_ids(player)
  end

  defp fetch_company_ids(_), do: []
end