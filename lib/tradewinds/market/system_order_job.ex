defmodule Tradewinds.Market.SystemOrderJob do
  use Oban.Worker,
    queue: :default,
    unique: [period: 60, states: [:available, :scheduled]]

  alias Tradewinds.Repo
  alias Tradewinds.Trade.TraderPosition
  alias Tradewinds.Market
  alias Tradewinds.Trade

  import Ecto.Query

  require Logger

  # Using the Economic scale: 1 game day = 4320 real seconds (72 minutes)
  @game_day_seconds 4320

  @impl Oban.Worker
  def perform(_job) do
    # Pick a random TraderPosition (links trader, port, and good)
    position =
      Repo.one(
        from tp in TraderPosition,
          order_by: fragment("RANDOM()"),
          limit: 1,
          preload: [:good]
      )

    if position do
      with {:ok, guild_price} <- Trade.get_guild_price(position.port_id, position.good_id) do
        # Markup: 1.1x to 1.5x of guild price (buy order)
        markup_bps = Enum.random(1100..1500)
        price = round(guild_price * markup_bps / 1000)

        # Reasonable Quantity: 10-100
        quantity = Enum.random(10..100)

        # Short lived: expires in 1 to 5 in-game days
        expiry_seconds = Enum.random(1..5) * @game_day_seconds
        expires_at = DateTime.utc_now() |> DateTime.add(expiry_seconds, :second)

        case Market.post_system_order(
               position.trader_id,
               position.port_id,
               position.good_id,
               :buy,
               price,
               quantity,
               expires_at
             ) do
          {:ok, order} ->
            Logger.info(
              "System posted premium buy order for trader_id #{position.trader_id}: #{quantity}x #{position.good.name} at #{price} in port_id #{position.port_id} (markup: #{markup_bps / 1000}x, expires in #{div(expiry_seconds, @game_day_seconds)} game days)"
            )

            {:ok, order}

          {:error, reason} ->
            Logger.error("System failed to post buy order: #{inspect(reason)}")
            {:error, reason}
        end
      end
    end

    # Self-schedule next run (15 to 60 minutes)
    delay_seconds = Enum.random(15..60) * 60

    %{}
    |> Tradewinds.Market.SystemOrderJob.new(schedule_in: delay_seconds)
    |> Oban.insert()

    :ok
  end
end
