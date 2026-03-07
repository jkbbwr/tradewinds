defmodule TradewindsWeb.HealthControllerTest do
  use TradewindsWeb.ConnCase, async: true

  test "GET /api/v1/health returns healthy when db is up", %{conn: conn} do
    conn = get(conn, ~p"/api/v1/health")
    resp = json_response(conn, 200)
    assert resp["status"] == "healthy"
    assert resp["database"] == "connected"
    assert resp["oban_lag_seconds"] == 0
    assert Map.has_key?(resp, "server_time")
  end

  test "GET /api/v1/health keys", %{conn: conn} do
    conn = get(conn, ~p"/api/v1/health")
    resp = json_response(conn, 200)
    assert Map.has_key?(resp, "status")
    assert Map.has_key?(resp, "database")
    assert Map.has_key?(resp, "oban_lag_seconds")
    assert Map.has_key?(resp, "server_time")
  end
end
