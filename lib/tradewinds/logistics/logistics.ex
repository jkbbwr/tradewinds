defmodule Tradewinds.Logistics do
  alias Tradewinds.Scope

  def rent_warehouse(%Scope{} = _scope, _company_id, _port_id) do
  end

  def list_warehouses(%Scope{} = _scope, _company_id) do
  end

  def deposit(%Scope{} = _scope, _warehouse_id, _good_id, _quantity) do
  end

  def withdraw(%Scope{} = _scope, _warehouse_id, _good_id, _quantity) do
  end
end