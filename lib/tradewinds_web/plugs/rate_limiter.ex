defmodule TradewindsWeb.Plugs.RateLimiter do
  import Plug.Conn

  # 300 requests per 60 seconds by default
  @default_scale 60_000
  @default_limit 300

  def init(opts) do
    %{
      scale: Keyword.get(opts, :scale, @default_scale),
      limit: Keyword.get(opts, :limit, @default_limit)
    }
  end

  def call(conn, %{scale: scale, limit: limit}) do
    ip = conn.remote_ip |> :inet.ntoa() |> to_string()

    # We use limit and scale in the key so that different limits (e.g. auth vs global) 
    # get tracked in separate buckets.
    id = "ip:#{ip}:#{limit}:#{scale}"

    case Tradewinds.RateLimit.hit(id, scale, limit) do
      {:allow, _count} ->
        conn

      {:deny, _limit} ->
        conn
        |> put_status(:too_many_requests)
        |> Phoenix.Controller.json(%{error: "Rate limit exceeded. Try again later."})
        |> halt()
    end
  end
end
