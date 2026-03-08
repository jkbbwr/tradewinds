defmodule Tradewinds.Scope do
  @moduledoc """
  A struct representing the current execution context (Identity).
  This is passed to Context functions to enforce authorization and access control.
  """
  defstruct [:player, :company_id]

  def for(attrs) when is_list(attrs) do
    struct(__MODULE__, attrs)
  end

  def for_player(%Tradewinds.Accounts.Player{} = player) do
    struct(__MODULE__, player: player)
  end

  def put_company_id(%__MODULE__{} = scope, company_id) do
    %{scope | company_id: company_id}
  end
end
