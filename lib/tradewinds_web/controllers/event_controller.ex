defmodule TradewindsWeb.EventController do
  use TradewindsWeb, :controller

  def world_events(conn, _params) do
    conn =
      conn
      |> put_resp_header("content-type", "text/event-stream")
      |> put_resp_header("cache-control", "no-cache")
      |> put_resp_header("connection", "keep-alive")
      |> send_chunked(200)

    Phoenix.PubSub.subscribe(Tradewinds.PubSub, "events:world:all")

    loop(conn)
  end

  def company_events(conn, _params) do
    conn =
      conn
      |> put_resp_header("content-type", "text/event-stream")
      |> put_resp_header("cache-control", "no-cache")
      |> put_resp_header("connection", "keep-alive")
      |> send_chunked(200)

    Phoenix.PubSub.subscribe(Tradewinds.PubSub, "events:#{conn.assigns.scope.company_id}:all")

    loop(conn)
  end

  defp loop(conn) do
    receive do
      {:message, payload} ->
        case(chunk(conn, "data: #{Jason.encode!(payload)}\n\n")) do
          {:ok, conn} -> loop(conn)
          {:error, _} -> conn
        end
    after
      15_000 ->
        case chunk(conn, ":keepalive\n\n") do
          {:ok, conn} -> loop(conn)
          {:error, _} -> conn
        end
    end
  end
end
