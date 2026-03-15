# priv/repo/new_ports.exs
alias Tradewinds.Repo
alias Tradewinds.World.{Country, Port, Good, Route}
alias Tradewinds.Shipyards.Shipyard
alias Tradewinds.Trade.{Trader, TraderPosition}
import Ecto.Query

# New Countries
countries_data = [
  {"Portugal",
   "At the edge of the Atlantic, a nation of explorers whose ports served as the first point of contact for many overseas treasures."},
  {"Spain",
   "A Mediterranean power with a vast coastline, bridging the gap between the Atlantic and the inner sea."},
  {"Italy",
   "The heart of the Mediterranean, where historic maritime republics continue to dominate the flow of luxury goods and staples."},
  {"Greece",
   "An ancient seafaring nation whose countless islands and strategic mainland ports are vital for eastern trade."},
  {"Turkey",
   "The bridge between two continents, controlling the strategic straits that lead to the Black Sea."},
  {"Egypt",
   "The gateway to the East, where the ancient port of Alexandria serves as a crossroads for spices and grains."}
]

countries =
  Enum.map(countries_data, fn {name, desc} ->
    case Repo.get_by(Country, name: name) do
      nil -> Repo.insert!(%Country{name: name, description: desc})
      country -> country
    end
  end)
  |> Map.new(&{&1.name, &1})

# France is already in seeds.exs, but we need it for Marseille
france = Repo.get_by!(Country, name: "France")

# New Goods
goods_data = [
  {"Olive Oil", "Golden oil pressed from Mediterranean olives", "Staple", 70, 0.15, 0.25},
  {"Marble", "High-quality white and colored marble for architecture", "Material", 150, 0.10,
   0.20},
  {"Glass", "Fine glassware from Venetian and Genoese masters", "Luxury", 250, 0.20, 0.15}
]

new_goods_records =
  Enum.map(goods_data, fn {name, desc, cat, price, vol, ela} ->
    case Repo.get_by(Good, name: name) do
      nil ->
        Repo.insert!(%Good{
          name: name,
          description: desc,
          category: cat,
          base_price: price,
          volatility: vol,
          elasticity: ela
        })

      good ->
        good
    end
  end)

# New Ports
ports_data = [
  {"Lisbon", "LIS", "Portugal", true, 200},
  {"Barcelona", "BCN", "Spain", false, 100},
  {"Marseille", "MRS", "France", true, 200},
  {"Genoa", "GEN", "Italy", false, 100},
  {"Venice", "VEN", "Italy", true, 200},
  {"Naples", "NAP", "Italy", false, 100},
  {"Piraeus", "PIR", "Greece", false, 100},
  {"Istanbul", "IST", "Turkey", true, 200},
  {"Alexandria", "ALX", "Egypt", true, 200},
  {"Cartagena", "CAR", "Spain", false, 100}
]

new_ports_records =
  Enum.map(ports_data, fn {name, code, country_name, hub, tax} ->
    country = if country_name == "France", do: france, else: Map.get(countries, country_name)

    case Repo.get_by(Port, shortcode: code) do
      nil ->
        Repo.insert!(%Port{
          name: name,
          shortcode: code,
          country_id: country.id,
          is_hub: hub,
          tax_rate_bps: tax
        })

      port ->
        port
    end
  end)

new_port_ids = Enum.map(new_ports_records, & &1.id)

# Shipyards for new hubs
for port <- new_ports_records, port.is_hub do
  case Repo.get_by(Shipyard, port_id: port.id) do
    nil -> Repo.insert!(%Shipyard{port_id: port.id})
    shipyard -> shipyard
  end
end

# Market Specialties for New Ports
port_market_data = %{
  "Lisbon" => %{sells: ["Wine", "Salt", "Fish"], buys: ["Timber", "Grain", "Iron"]},
  "Barcelona" => %{sells: ["Cloth", "Wool", "Wine"], buys: ["Grain", "Iron", "Copper"]},
  "Marseille" => %{sells: ["Wine", "Olive Oil", "Cloth"], buys: ["Silk", "Spices", "Hemp"]},
  "Genoa" => %{sells: ["Silk", "Cloth", "Marble"], buys: ["Timber", "Iron", "Grain"]},
  "Venice" => %{sells: ["Glass", "Spices", "Silk"], buys: ["Timber", "Hemp", "Tar/Pitch"]},
  "Naples" => %{sells: ["Wine", "Olive Oil", "Grain"], buys: ["Cloth", "Iron", "Wool"]},
  "Piraeus" => %{sells: ["Olive Oil", "Marble", "Wine"], buys: ["Cloth", "Grain", "Iron"]},
  "Istanbul" => %{sells: ["Spices", "Silk", "Salt"], buys: ["Timber", "Iron", "Copper"]},
  "Alexandria" => %{sells: ["Grain", "Spices", "Silk"], buys: ["Timber", "Iron", "Wine"]},
  "Cartagena" => %{sells: ["Copper", "Salt", "Fish"], buys: ["Grain", "Timber", "Cloth"]}
}

all_goods = Repo.all(Good)

# 1. Setup Markets for New Ports
for port <- new_ports_records do
  trader_name = "#{port.name} Merchant Guild"

  trader =
    case Repo.get_by(Trader, name: trader_name) do
      nil -> Repo.insert!(%Trader{name: trader_name})
      t -> t
    end

  market_data = Map.get(port_market_data, port.name, %{sells: [], buys: []})
  hub_mult = if port.is_hub, do: 2.0, else: 1.0
  base_spread = if port.is_hub, do: 0.05, else: 0.08

  for good <- all_goods do
    is_selling = good.name in market_data.sells
    is_buying = good.name in market_data.buys

    {stock, target, s_rate, d_rate} =
      cond do
        is_selling -> {round(2000 * hub_mult), round(1000 * hub_mult), 0.12, 0.02}
        is_buying -> {round(50 * hub_mult), round(1000 * hub_mult), 0.02, 0.10}
        true -> {round(500 * hub_mult), round(500 * hub_mult), 0.04, 0.04}
      end

    case Repo.get_by(TraderPosition, trader_id: trader.id, port_id: port.id, good_id: good.id) do
      nil ->
        Repo.insert!(%TraderPosition{
          trader_id: trader.id,
          port_id: port.id,
          good_id: good.id,
          stock: stock,
          target_stock: target,
          supply_rate: s_rate,
          demand_rate: d_rate,
          elasticity: good.elasticity,
          ask_spread: base_spread,
          bid_spread: base_spread,
          quarterly_profit: 0
        })

      _ ->
        :ok
    end
  end
end

# 2. Cross-Pollination: Update Existing Ports to buy New Mediterranean Goods
existing_ports = Repo.all(from p in Port, where: p.id not in ^new_port_ids)

for port <- existing_ports do
  trader = Repo.get_by!(Trader, name: "#{port.name} Merchant Guild")
  hub_mult = if port.is_hub, do: 2.0, else: 1.0
  base_spread = if port.is_hub, do: 0.05, else: 0.08

  for good <- new_goods_records do
    case Repo.get_by(TraderPosition, trader_id: trader.id, port_id: port.id, good_id: good.id) do
      nil ->
        # Existing ports consume these exotic Mediterranean goods
        Repo.insert!(%TraderPosition{
          trader_id: trader.id,
          port_id: port.id,
          good_id: good.id,
          stock: round(50 * hub_mult),
          target_stock: round(1000 * hub_mult),
          supply_rate: 0.02,
          demand_rate: 0.10,
          elasticity: good.elasticity,
          ask_spread: base_spread,
          bid_spread: base_spread,
          quarterly_profit: 0
        })

      _ ->
        :ok
    end
  end
end

# 3. Synchronize Embedded Routes
# This list was generated using tools/generate_routes.py via searoute
routes = [
  {"London", "Edinburgh", 419},
  {"London", "Bristol", 585},
  {"London", "Hull", 218},
  {"London", "Portsmouth", 183},
  {"London", "Plymouth", 312},
  {"London", "Glasgow", 743},
  {"London", "Amsterdam", 259},
  {"London", "Rotterdam", 153},
  {"London", "Hamburg", 383},
  {"London", "Bremen", 371},
  {"London", "Antwerp", 168},
  {"London", "Dunkirk", 104},
  {"London", "Calais", 93},
  {"London", "Dublin", 597},
  {"London", "Lisbon", 1068},
  {"London", "Barcelona", 1876},
  {"London", "Marseille", 2039},
  {"London", "Genoa", 2202},
  {"London", "Venice", 3031},
  {"London", "Naples", 2312},
  {"London", "Piraeus", 2780},
  {"London", "Istanbul", 3129},
  {"London", "Alexandria", 3141},
  {"London", "Cartagena", 1580},
  {"Edinburgh", "Bristol", 914},
  {"Edinburgh", "Hull", 201},
  {"Edinburgh", "Portsmouth", 512},
  {"Edinburgh", "Plymouth", 642},
  {"Edinburgh", "Glasgow", 578},
  {"Edinburgh", "Amsterdam", 438},
  {"Edinburgh", "Rotterdam", 387},
  {"Edinburgh", "Hamburg", 521},
  {"Edinburgh", "Bremen", 509},
  {"Edinburgh", "Antwerp", 421},
  {"Edinburgh", "Dunkirk", 413},
  {"Edinburgh", "Calais", 414},
  {"Edinburgh", "Dublin", 627},
  {"Edinburgh", "Lisbon", 1397},
  {"Edinburgh", "Barcelona", 2205},
  {"Edinburgh", "Marseille", 2369},
  {"Edinburgh", "Genoa", 2532},
  {"Edinburgh", "Venice", 3361},
  {"Edinburgh", "Naples", 2641},
  {"Edinburgh", "Piraeus", 3109},
  {"Edinburgh", "Istanbul", 3458},
  {"Edinburgh", "Alexandria", 3470},
  {"Edinburgh", "Cartagena", 1910},
  {"Bristol", "Hull", 714},
  {"Bristol", "Portsmouth", 412},
  {"Bristol", "Plymouth", 278},
  {"Bristol", "Glasgow", 525},
  {"Bristol", "Amsterdam", 732},
  {"Bristol", "Rotterdam", 624},
  {"Bristol", "Hamburg", 856},
  {"Bristol", "Bremen", 844},
  {"Bristol", "Antwerp", 613},
  {"Bristol", "Dunkirk", 543},
  {"Bristol", "Calais", 514},
  {"Bristol", "Dublin", 379},
  {"Bristol", "Lisbon", 962},
  {"Bristol", "Barcelona", 1771},
  {"Bristol", "Marseille", 1934},
  {"Bristol", "Genoa", 2097},
  {"Bristol", "Venice", 2926},
  {"Bristol", "Naples", 2206},
  {"Bristol", "Piraeus", 2674},
  {"Bristol", "Istanbul", 3023},
  {"Bristol", "Alexandria", 3036},
  {"Bristol", "Cartagena", 1475},
  {"Hull", "Portsmouth", 311},
  {"Hull", "Plymouth", 441},
  {"Hull", "Glasgow", 710},
  {"Hull", "Amsterdam", 248},
  {"Hull", "Rotterdam", 186},
  {"Hull", "Hamburg", 332},
  {"Hull", "Bremen", 320},
  {"Hull", "Antwerp", 220},
  {"Hull", "Dunkirk", 212},
  {"Hull", "Calais", 213},
  {"Hull", "Dublin", 726},
  {"Hull", "Lisbon", 1196},
  {"Hull", "Barcelona", 2005},
  {"Hull", "Marseille", 2168},
  {"Hull", "Genoa", 2331},
  {"Hull", "Venice", 3160},
  {"Hull", "Naples", 2440},
  {"Hull", "Piraeus", 2908},
  {"Hull", "Istanbul", 3257},
  {"Hull", "Alexandria", 3270},
  {"Hull", "Cartagena", 1709},
  {"Portsmouth", "Plymouth", 134},
  {"Portsmouth", "Glasgow", 570},
  {"Portsmouth", "Amsterdam", 333},
  {"Portsmouth", "Rotterdam", 227},
  {"Portsmouth", "Hamburg", 457},
  {"Portsmouth", "Bremen", 445},
  {"Portsmouth", "Antwerp", 218},
  {"Portsmouth", "Dunkirk", 150},
  {"Portsmouth", "Calais", 121},
  {"Portsmouth", "Dublin", 424},
  {"Portsmouth", "Lisbon", 902},
  {"Portsmouth", "Barcelona", 1711},
  {"Portsmouth", "Marseille", 1874},
  {"Portsmouth", "Genoa", 2037},
  {"Portsmouth", "Venice", 2866},
  {"Portsmouth", "Naples", 2146},
  {"Portsmouth", "Piraeus", 2614},
  {"Portsmouth", "Istanbul", 2963},
  {"Portsmouth", "Alexandria", 2976},
  {"Portsmouth", "Cartagena", 1415},
  {"Plymouth", "Glasgow", 436},
  {"Plymouth", "Amsterdam", 462},
  {"Plymouth", "Rotterdam", 357},
  {"Plymouth", "Hamburg", 587},
  {"Plymouth", "Bremen", 575},
  {"Plymouth", "Antwerp", 347},
  {"Plymouth", "Dunkirk", 279},
  {"Plymouth", "Calais", 251},
  {"Plymouth", "Dublin", 290},
  {"Plymouth", "Lisbon", 810},
  {"Plymouth", "Barcelona", 1619},
  {"Plymouth", "Marseille", 1782},
  {"Plymouth", "Genoa", 1945},
  {"Plymouth", "Venice", 2774},
  {"Plymouth", "Naples", 2055},
  {"Plymouth", "Piraeus", 2523},
  {"Plymouth", "Istanbul", 2872},
  {"Plymouth", "Alexandria", 2884},
  {"Plymouth", "Cartagena", 1323},
  {"Glasgow", "Amsterdam", 863},
  {"Glasgow", "Rotterdam", 782},
  {"Glasgow", "Hamburg", 897},
  {"Glasgow", "Bremen", 886},
  {"Glasgow", "Antwerp", 771},
  {"Glasgow", "Dunkirk", 701},
  {"Glasgow", "Calais", 672},
  {"Glasgow", "Dublin", 177},
  {"Glasgow", "Lisbon", 1114},
  {"Glasgow", "Barcelona", 1922},
  {"Glasgow", "Marseille", 2086},
  {"Glasgow", "Genoa", 2249},
  {"Glasgow", "Venice", 3078},
  {"Glasgow", "Naples", 2358},
  {"Glasgow", "Piraeus", 2826},
  {"Glasgow", "Istanbul", 3175},
  {"Glasgow", "Alexandria", 3187},
  {"Glasgow", "Cartagena", 1627},
  {"Amsterdam", "Rotterdam", 131},
  {"Amsterdam", "Hamburg", 229},
  {"Amsterdam", "Bremen", 217},
  {"Amsterdam", "Antwerp", 190},
  {"Amsterdam", "Dunkirk", 207},
  {"Amsterdam", "Calais", 224},
  {"Amsterdam", "Dublin", 744},
  {"Amsterdam", "Lisbon", 1215},
  {"Amsterdam", "Barcelona", 2023},
  {"Amsterdam", "Marseille", 2187},
  {"Amsterdam", "Genoa", 2350},
  {"Amsterdam", "Venice", 3179},
  {"Amsterdam", "Naples", 2459},
  {"Amsterdam", "Piraeus", 2927},
  {"Amsterdam", "Istanbul", 3276},
  {"Amsterdam", "Alexandria", 3288},
  {"Amsterdam", "Cartagena", 1728},
  {"Rotterdam", "Hamburg", 263},
  {"Rotterdam", "Bremen", 251},
  {"Rotterdam", "Antwerp", 78},
  {"Rotterdam", "Dunkirk", 95},
  {"Rotterdam", "Calais", 113},
  {"Rotterdam", "Dublin", 636},
  {"Rotterdam", "Lisbon", 1107},
  {"Rotterdam", "Barcelona", 1915},
  {"Rotterdam", "Marseille", 2079},
  {"Rotterdam", "Genoa", 2242},
  {"Rotterdam", "Venice", 3071},
  {"Rotterdam", "Naples", 2351},
  {"Rotterdam", "Piraeus", 2819},
  {"Rotterdam", "Istanbul", 3168},
  {"Rotterdam", "Alexandria", 3180},
  {"Rotterdam", "Cartagena", 1620},
  {"Hamburg", "Bremen", 58},
  {"Hamburg", "Antwerp", 322},
  {"Hamburg", "Dunkirk", 333},
  {"Hamburg", "Calais", 348},
  {"Hamburg", "Dublin", 868},
  {"Hamburg", "Lisbon", 1339},
  {"Hamburg", "Barcelona", 2147},
  {"Hamburg", "Marseille", 2311},
  {"Hamburg", "Genoa", 2474},
  {"Hamburg", "Venice", 3303},
  {"Hamburg", "Naples", 2583},
  {"Hamburg", "Piraeus", 3051},
  {"Hamburg", "Istanbul", 3400},
  {"Hamburg", "Alexandria", 3412},
  {"Hamburg", "Cartagena", 1852},
  {"Bremen", "Antwerp", 310},
  {"Bremen", "Dunkirk", 321},
  {"Bremen", "Calais", 336},
  {"Bremen", "Dublin", 856},
  {"Bremen", "Lisbon", 1327},
  {"Bremen", "Barcelona", 2135},
  {"Bremen", "Marseille", 2299},
  {"Bremen", "Genoa", 2462},
  {"Bremen", "Venice", 3291},
  {"Bremen", "Naples", 2571},
  {"Bremen", "Piraeus", 3039},
  {"Bremen", "Istanbul", 3388},
  {"Bremen", "Alexandria", 3400},
  {"Bremen", "Cartagena", 1840},
  {"Antwerp", "Dunkirk", 84},
  {"Antwerp", "Calais", 102},
  {"Antwerp", "Dublin", 625},
  {"Antwerp", "Lisbon", 1096},
  {"Antwerp", "Barcelona", 1904},
  {"Antwerp", "Marseille", 2068},
  {"Antwerp", "Genoa", 2231},
  {"Antwerp", "Venice", 3060},
  {"Antwerp", "Naples", 2340},
  {"Antwerp", "Piraeus", 2808},
  {"Antwerp", "Istanbul", 3157},
  {"Antwerp", "Alexandria", 3169},
  {"Antwerp", "Cartagena", 1609},
  {"Dunkirk", "Calais", 32},
  {"Dunkirk", "Dublin", 555},
  {"Dunkirk", "Lisbon", 1025},
  {"Dunkirk", "Barcelona", 1834},
  {"Dunkirk", "Marseille", 1997},
  {"Dunkirk", "Genoa", 2160},
  {"Dunkirk", "Venice", 2989},
  {"Dunkirk", "Naples", 2269},
  {"Dunkirk", "Piraeus", 2737},
  {"Dunkirk", "Istanbul", 3087},
  {"Dunkirk", "Alexandria", 3099},
  {"Dunkirk", "Cartagena", 1538},
  {"Calais", "Dublin", 526},
  {"Calais", "Lisbon", 997},
  {"Calais", "Barcelona", 1805},
  {"Calais", "Marseille", 1968},
  {"Calais", "Genoa", 2132},
  {"Calais", "Venice", 2960},
  {"Calais", "Naples", 2241},
  {"Calais", "Piraeus", 2709},
  {"Calais", "Istanbul", 3058},
  {"Calais", "Alexandria", 3070},
  {"Calais", "Cartagena", 1510},
  {"Dublin", "Lisbon", 968},
  {"Dublin", "Barcelona", 1776},
  {"Dublin", "Marseille", 1940},
  {"Dublin", "Genoa", 2103},
  {"Dublin", "Venice", 2932},
  {"Dublin", "Naples", 2212},
  {"Dublin", "Piraeus", 2680},
  {"Dublin", "Istanbul", 3029},
  {"Dublin", "Alexandria", 3041},
  {"Dublin", "Cartagena", 1481},
  {"Lisbon", "Barcelona", 861},
  {"Lisbon", "Marseille", 1025},
  {"Lisbon", "Genoa", 1188},
  {"Lisbon", "Venice", 2017},
  {"Lisbon", "Naples", 1297},
  {"Lisbon", "Piraeus", 1765},
  {"Lisbon", "Istanbul", 2114},
  {"Lisbon", "Alexandria", 2126},
  {"Lisbon", "Cartagena", 566},
  {"Barcelona", "Marseille", 188},
  {"Barcelona", "Genoa", 358},
  {"Barcelona", "Venice", 1338},
  {"Barcelona", "Naples", 540},
  {"Barcelona", "Piraeus", 1086},
  {"Barcelona", "Istanbul", 1435},
  {"Barcelona", "Alexandria", 1478},
  {"Barcelona", "Cartagena", 302},
  {"Marseille", "Genoa", 227},
  {"Marseille", "Venice", 1253},
  {"Marseille", "Naples", 456},
  {"Marseille", "Piraeus", 1002},
  {"Marseille", "Istanbul", 1351},
  {"Marseille", "Alexandria", 1435},
  {"Marseille", "Cartagena", 465},
  {"Genoa", "Venice", 1151},
  {"Genoa", "Naples", 322},
  {"Genoa", "Piraeus", 899},
  {"Genoa", "Istanbul", 1248},
  {"Genoa", "Alexandria", 1333},
  {"Genoa", "Cartagena", 628},
  {"Venice", "Naples", 832},
  {"Venice", "Piraeus", 715},
  {"Venice", "Istanbul", 1064},
  {"Venice", "Alexandria", 1218},
  {"Venice", "Cartagena", 1482},
  {"Naples", "Piraeus", 581},
  {"Naples", "Istanbul", 930},
  {"Naples", "Alexandria", 1014},
  {"Naples", "Cartagena", 756},
  {"Piraeus", "Istanbul", 356},
  {"Piraeus", "Alexandria", 518},
  {"Piraeus", "Cartagena", 1231},
  {"Istanbul", "Alexandria", 719},
  {"Istanbul", "Cartagena", 1580},
  {"Alexandria", "Cartagena", 1592}
]

ports_map = Repo.all(Port) |> Map.new(&{&1.name, &1.id})

IO.puts("Synchronizing #{length(routes)} routes...")

for {from_name, to_name, distance} <- routes do
  from_id = Map.get(ports_map, from_name)
  to_id = Map.get(ports_map, to_name)

  if from_id && to_id do
    # Check if route already exists (preserving manual routes from seeds.exs)
    unless Repo.exists?(from r in Route, where: r.from_id == ^from_id and r.to_id == ^to_id) do
      Repo.insert!(%Route{from_id: from_id, to_id: to_id, distance: distance})
    end

    unless Repo.exists?(from r in Route, where: r.from_id == ^to_id and r.to_id == ^from_id) do
      Repo.insert!(%Route{from_id: to_id, to_id: from_id, distance: distance})
    end
  end
end

IO.puts("Mediterranean expansion complete!")
