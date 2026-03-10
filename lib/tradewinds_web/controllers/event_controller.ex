defmodule TradewindsWeb.EventController do
  use TradewindsWeb, :controller
  use OpenApiSpex.ControllerSpecs

  operation(:world_events,
    summary: "Subscribe to world events",
    description: "Server-Sent Events (SSE) endpoint streaming public world events (e.g. general economy shocks, news).",
    responses: [
      ok: {"SSE stream", "text/event-stream", %OpenApiSpex.Schema{type: :string}}
    ]
  )

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

  operation(:company_events,
    summary: "Subscribe to company events",
    description: "Server-Sent Events (SSE) endpoint streaming private company events (e.g. ship arrivals, completed trades, ledger updates).",
    security: [%{"bearerAuth" => []}],
    parameters: [
      %OpenApiSpex.Parameter{
        name: "tradewinds-company-id",
        in: :header,
        required: true,
        schema: %OpenApiSpex.Schema{type: :string, format: :uuid},
        description: "Company ID"
      }
    ],
    responses: [
      ok: {"SSE stream", "text/event-stream", %OpenApiSpex.Schema{type: :string}},
      unauthorized: {"Invalid or expired token", "application/json", TradewindsWeb.Schemas.ErrorResponse}
    ]
  )

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
