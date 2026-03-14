defmodule TradewindsWeb.Plugs.RequireWriteAccessTest do
  use TradewindsWeb.ConnCase, async: true

  alias TradewindsWeb.Plugs.RequireWriteAccess
  alias Tradewinds.Scope

  setup do
    conn = build_conn()
    %{conn: conn}
  end

  test "allows request if token is not read-only", %{conn: conn} do
    scope = %Scope{read_only: false}
    conn = assign(conn, :scope, scope)

    conn = RequireWriteAccess.call(conn, %{})

    refute conn.halted
  end

  test "halts and returns 403 if token is read-only", %{conn: conn} do
    scope = %Scope{read_only: true}
    conn = assign(conn, :scope, scope)

    conn = RequireWriteAccess.call(conn, %{})

    assert conn.halted
    assert conn.status == 403
    assert json_response(conn, 403)["error"]["message"] == "Token is read-only"
  end
end
