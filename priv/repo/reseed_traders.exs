alias Tradewinds.Repo
alias Tradewinds.World.Port
alias Tradewinds.World.Good
alias Tradewinds.Trade.Trader
alias Tradewinds.Trade.TraderPosition

port_market_data = %{
  "Bristol" => %{sells: ["Iron", "Coal", "Wool"], buys: ["Wine", "Salt", "Grain"]},
  "Hull" => %{sells: ["Fish", "Grain", "Wool"], buys: ["Timber", "Iron", "Tar/Pitch"]},
  "Portsmouth" => %{sells: ["Hemp", "Salt", "Timber"], buys: ["Coal", "Cloth", "Wine"]},
  "Plymouth" => %{sells: ["Copper", "Fish", "Salt"], buys: ["Cloth", "Grain", "Timber"]},
  "Rotterdam" => %{sells: ["Hemp", "Tar/Pitch", "Cloth"], buys: ["Coal", "Iron", "Silk"]},
  "Antwerp" => %{sells: ["Silk", "Cloth", "Wine"], buys: ["Wool", "Copper", "Grain"]},
  "Dunkirk" => %{sells: ["Wine", "Grain", "Cloth"], buys: ["Iron", "Coal", "Fish"]},
  "Calais" => %{sells: ["Wine", "Salt", "Grain"], buys: ["Wool", "Timber", "Coal"]},
  "Dublin" => %{sells: ["Wool", "Fish", "Salt"], buys: ["Iron", "Timber", "Cloth"]},
  "Bremen" => %{sells: ["Timber", "Tar/Pitch", "Grain"], buys: ["Spices", "Copper", "Salt"]},
  "London" => %{sells: ["Cloth", "Wool", "Iron"], buys: ["Timber", "Hemp", "Wine"]},
  "Amsterdam" => %{sells: ["Spices", "Silk", "Fish"], buys: ["Grain", "Wool", "Iron"]},
  "Hamburg" => %{sells: ["Timber", "Grain", "Copper"], buys: ["Wine", "Silk", "Cloth"]},
  "Edinburgh" => %{sells: ["Coal", "Fish", "Wool"], buys: ["Salt", "Hemp", "Spices"]}
}

ports = Repo.all(Port)
goods = Repo.all(Good) |> Map.new(&{&1.name, &1})

for port <- ports do
  trader = Repo.get_by!(Trader, name: "#{port.name} Merchant Guild")
  market_data = Map.get(port_market_data, port.name, %{sells: [], buys: []})

  hub_mult = if port.is_hub, do: 2.0, else: 1.0
  base_spread = if port.is_hub, do: 0.05, else: 0.08

  for {good_name, good} <- goods do
    is_selling = good_name in market_data.sells
    is_buying = good_name in market_data.buys

    {stock, target, s_rate, d_rate} =
      cond do
        is_selling ->
          # Producers: Start with surplus (200% of target) to drive prices down
          {round(2000 * hub_mult), round(1000 * hub_mult), 0.12, 0.02}

        is_buying ->
          # Consumers: Start with severe scarcity (5% of target) to drive prices up
          {round(50 * hub_mult), round(1000 * hub_mult), 0.02, 0.10}

        true ->
          # Neutral: Balanced baseline
          {round(500 * hub_mult), round(500 * hub_mult), 0.04, 0.04}
      end

    position =
      Repo.get_by!(TraderPosition, trader_id: trader.id, port_id: port.id, good_id: good.id)

    position
    |> Ecto.Changeset.change(%{
      stock: stock,
      target_stock: target,
      supply_rate: s_rate,
      demand_rate: d_rate,
      elasticity: good.elasticity,
      spread: base_spread
    })
    |> Repo.update!()
  end
end

IO.puts("Successfully updated all existing trader positions!")
