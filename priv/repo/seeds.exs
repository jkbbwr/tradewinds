# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Tradewinds.Repo.insert!(%Tradewinds.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Tradewinds.Repo
alias Tradewinds.World.Country
alias Tradewinds.World.Port
alias Tradewinds.World.Route
alias Tradewinds.World.Good
alias Tradewinds.World.ShipType
alias Tradewinds.Shipyards.Shipyard

# United Kingdom
uk =
  Repo.insert!(%Country{
    name: "United Kingdom",
    description:
      "A maritime powerhouse with a storied naval history and bustling industrial ports that connect the British Isles to the world."
  })

london = Repo.insert!(%Port{name: "London", shortcode: "LON", country_id: uk.id})
edinburgh = Repo.insert!(%Port{name: "Edinburgh", shortcode: "EDI", country_id: uk.id})
bristol = Repo.insert!(%Port{name: "Bristol", shortcode: "BRS", country_id: uk.id})
hull = Repo.insert!(%Port{name: "Hull", shortcode: "HUL", country_id: uk.id})
portsmouth = Repo.insert!(%Port{name: "Portsmouth", shortcode: "PME", country_id: uk.id})
plymouth = Repo.insert!(%Port{name: "Plymouth", shortcode: "PLH", country_id: uk.id})
glasgow = Repo.insert!(%Port{name: "Glasgow", shortcode: "GLA", country_id: uk.id})

# Netherlands
netherlands =
  Repo.insert!(%Country{
    name: "Netherlands",
    description:
      "The gateway to Europe, a nation defined by its intricate canal systems and some of the world's most advanced deep-water harbors."
  })

amsterdam = Repo.insert!(%Port{name: "Amsterdam", shortcode: "AMS", country_id: netherlands.id})
rotterdam = Repo.insert!(%Port{name: "Rotterdam", shortcode: "RTM", country_id: netherlands.id})

# Germany
germany =
  Repo.insert!(%Country{
    name: "Germany",
    description:
      "A hub of engineering and trade, where historic Hanseatic cities continue to serve as vital arteries for Central European commerce."
  })

hamburg = Repo.insert!(%Port{name: "Hamburg", shortcode: "HAM", country_id: germany.id})
bremen = Repo.insert!(%Port{name: "Bremen", shortcode: "BRE", country_id: germany.id})

# Belgium
belgium =
  Repo.insert!(%Country{
    name: "Belgium",
    description:
      "A vital crossroads of European trade, home to massive inland ports that bridge the gap between the North Sea and the heart of the continent."
  })

antwerp = Repo.insert!(%Port{name: "Antwerp", shortcode: "ANR", country_id: belgium.id})

# France
france =
  Repo.insert!(%Country{
    name: "France",
    description:
      "A nation of diverse coastlines, where strategic northern ports have served as the threshold for cross-channel trade for centuries."
  })

dunkirk = Repo.insert!(%Port{name: "Dunkirk", shortcode: "DKK", country_id: france.id})
calais = Repo.insert!(%Port{name: "Calais", shortcode: "CQF", country_id: france.id})

# Ireland
ireland =
  Repo.insert!(%Country{
    name: "Ireland",
    description:
      "The Emerald Isle, whose vibrant coastal cities have long been shaped by their deep connection to the Atlantic and the Irish Sea."
  })

dublin = Repo.insert!(%Port{name: "Dublin", shortcode: "DUB", country_id: ireland.id})

# Routes

# Routes
Repo.insert!(%Route{from_id: london.id, to_id: edinburgh.id, distance: 419})
Repo.insert!(%Route{from_id: london.id, to_id: bristol.id, distance: 585})
Repo.insert!(%Route{from_id: london.id, to_id: hull.id, distance: 218})
Repo.insert!(%Route{from_id: london.id, to_id: portsmouth.id, distance: 183})
Repo.insert!(%Route{from_id: london.id, to_id: plymouth.id, distance: 312})
Repo.insert!(%Route{from_id: london.id, to_id: glasgow.id, distance: 743})
Repo.insert!(%Route{from_id: london.id, to_id: amsterdam.id, distance: 259})
Repo.insert!(%Route{from_id: london.id, to_id: rotterdam.id, distance: 153})
Repo.insert!(%Route{from_id: london.id, to_id: hamburg.id, distance: 383})
Repo.insert!(%Route{from_id: london.id, to_id: bremen.id, distance: 371})
Repo.insert!(%Route{from_id: london.id, to_id: antwerp.id, distance: 168})
Repo.insert!(%Route{from_id: london.id, to_id: dunkirk.id, distance: 104})
Repo.insert!(%Route{from_id: london.id, to_id: calais.id, distance: 93})
Repo.insert!(%Route{from_id: london.id, to_id: dublin.id, distance: 597})
Repo.insert!(%Route{from_id: edinburgh.id, to_id: london.id, distance: 419})
Repo.insert!(%Route{from_id: edinburgh.id, to_id: bristol.id, distance: 914})
Repo.insert!(%Route{from_id: edinburgh.id, to_id: hull.id, distance: 201})
Repo.insert!(%Route{from_id: edinburgh.id, to_id: portsmouth.id, distance: 512})
Repo.insert!(%Route{from_id: edinburgh.id, to_id: plymouth.id, distance: 642})
Repo.insert!(%Route{from_id: edinburgh.id, to_id: glasgow.id, distance: 578})
Repo.insert!(%Route{from_id: edinburgh.id, to_id: amsterdam.id, distance: 438})
Repo.insert!(%Route{from_id: edinburgh.id, to_id: rotterdam.id, distance: 387})
Repo.insert!(%Route{from_id: edinburgh.id, to_id: hamburg.id, distance: 521})
Repo.insert!(%Route{from_id: edinburgh.id, to_id: bremen.id, distance: 509})
Repo.insert!(%Route{from_id: edinburgh.id, to_id: antwerp.id, distance: 421})
Repo.insert!(%Route{from_id: edinburgh.id, to_id: dunkirk.id, distance: 413})
Repo.insert!(%Route{from_id: edinburgh.id, to_id: calais.id, distance: 414})
Repo.insert!(%Route{from_id: edinburgh.id, to_id: dublin.id, distance: 627})
Repo.insert!(%Route{from_id: bristol.id, to_id: london.id, distance: 585})
Repo.insert!(%Route{from_id: bristol.id, to_id: edinburgh.id, distance: 914})
Repo.insert!(%Route{from_id: bristol.id, to_id: hull.id, distance: 714})
Repo.insert!(%Route{from_id: bristol.id, to_id: portsmouth.id, distance: 412})
Repo.insert!(%Route{from_id: bristol.id, to_id: plymouth.id, distance: 278})
Repo.insert!(%Route{from_id: bristol.id, to_id: glasgow.id, distance: 525})
Repo.insert!(%Route{from_id: bristol.id, to_id: amsterdam.id, distance: 732})
Repo.insert!(%Route{from_id: bristol.id, to_id: rotterdam.id, distance: 624})
Repo.insert!(%Route{from_id: bristol.id, to_id: hamburg.id, distance: 856})
Repo.insert!(%Route{from_id: bristol.id, to_id: bremen.id, distance: 844})
Repo.insert!(%Route{from_id: bristol.id, to_id: antwerp.id, distance: 613})
Repo.insert!(%Route{from_id: bristol.id, to_id: dunkirk.id, distance: 543})
Repo.insert!(%Route{from_id: bristol.id, to_id: calais.id, distance: 514})
Repo.insert!(%Route{from_id: bristol.id, to_id: dublin.id, distance: 379})
Repo.insert!(%Route{from_id: hull.id, to_id: london.id, distance: 218})
Repo.insert!(%Route{from_id: hull.id, to_id: edinburgh.id, distance: 201})
Repo.insert!(%Route{from_id: hull.id, to_id: bristol.id, distance: 714})
Repo.insert!(%Route{from_id: hull.id, to_id: portsmouth.id, distance: 311})
Repo.insert!(%Route{from_id: hull.id, to_id: plymouth.id, distance: 441})
Repo.insert!(%Route{from_id: hull.id, to_id: glasgow.id, distance: 710})
Repo.insert!(%Route{from_id: hull.id, to_id: amsterdam.id, distance: 248})
Repo.insert!(%Route{from_id: hull.id, to_id: rotterdam.id, distance: 186})
Repo.insert!(%Route{from_id: hull.id, to_id: hamburg.id, distance: 332})
Repo.insert!(%Route{from_id: hull.id, to_id: bremen.id, distance: 320})
Repo.insert!(%Route{from_id: hull.id, to_id: antwerp.id, distance: 220})
Repo.insert!(%Route{from_id: hull.id, to_id: dunkirk.id, distance: 212})
Repo.insert!(%Route{from_id: hull.id, to_id: calais.id, distance: 213})
Repo.insert!(%Route{from_id: hull.id, to_id: dublin.id, distance: 726})
Repo.insert!(%Route{from_id: portsmouth.id, to_id: london.id, distance: 183})
Repo.insert!(%Route{from_id: portsmouth.id, to_id: edinburgh.id, distance: 512})
Repo.insert!(%Route{from_id: portsmouth.id, to_id: bristol.id, distance: 412})
Repo.insert!(%Route{from_id: portsmouth.id, to_id: hull.id, distance: 311})
Repo.insert!(%Route{from_id: portsmouth.id, to_id: plymouth.id, distance: 134})
Repo.insert!(%Route{from_id: portsmouth.id, to_id: glasgow.id, distance: 570})
Repo.insert!(%Route{from_id: portsmouth.id, to_id: amsterdam.id, distance: 333})
Repo.insert!(%Route{from_id: portsmouth.id, to_id: rotterdam.id, distance: 227})
Repo.insert!(%Route{from_id: portsmouth.id, to_id: hamburg.id, distance: 457})
Repo.insert!(%Route{from_id: portsmouth.id, to_id: bremen.id, distance: 445})
Repo.insert!(%Route{from_id: portsmouth.id, to_id: antwerp.id, distance: 218})
Repo.insert!(%Route{from_id: portsmouth.id, to_id: dunkirk.id, distance: 150})
Repo.insert!(%Route{from_id: portsmouth.id, to_id: calais.id, distance: 121})
Repo.insert!(%Route{from_id: portsmouth.id, to_id: dublin.id, distance: 424})
Repo.insert!(%Route{from_id: plymouth.id, to_id: london.id, distance: 312})
Repo.insert!(%Route{from_id: plymouth.id, to_id: edinburgh.id, distance: 642})
Repo.insert!(%Route{from_id: plymouth.id, to_id: bristol.id, distance: 278})
Repo.insert!(%Route{from_id: plymouth.id, to_id: hull.id, distance: 441})
Repo.insert!(%Route{from_id: plymouth.id, to_id: portsmouth.id, distance: 134})
Repo.insert!(%Route{from_id: plymouth.id, to_id: glasgow.id, distance: 436})
Repo.insert!(%Route{from_id: plymouth.id, to_id: amsterdam.id, distance: 462})
Repo.insert!(%Route{from_id: plymouth.id, to_id: rotterdam.id, distance: 357})
Repo.insert!(%Route{from_id: plymouth.id, to_id: hamburg.id, distance: 587})
Repo.insert!(%Route{from_id: plymouth.id, to_id: bremen.id, distance: 575})
Repo.insert!(%Route{from_id: plymouth.id, to_id: antwerp.id, distance: 347})
Repo.insert!(%Route{from_id: plymouth.id, to_id: dunkirk.id, distance: 279})
Repo.insert!(%Route{from_id: plymouth.id, to_id: calais.id, distance: 251})
Repo.insert!(%Route{from_id: plymouth.id, to_id: dublin.id, distance: 290})
Repo.insert!(%Route{from_id: glasgow.id, to_id: london.id, distance: 743})
Repo.insert!(%Route{from_id: glasgow.id, to_id: edinburgh.id, distance: 578})
Repo.insert!(%Route{from_id: glasgow.id, to_id: bristol.id, distance: 525})
Repo.insert!(%Route{from_id: glasgow.id, to_id: hull.id, distance: 710})
Repo.insert!(%Route{from_id: glasgow.id, to_id: portsmouth.id, distance: 570})
Repo.insert!(%Route{from_id: glasgow.id, to_id: plymouth.id, distance: 436})
Repo.insert!(%Route{from_id: glasgow.id, to_id: amsterdam.id, distance: 863})
Repo.insert!(%Route{from_id: glasgow.id, to_id: rotterdam.id, distance: 782})
Repo.insert!(%Route{from_id: glasgow.id, to_id: hamburg.id, distance: 897})
Repo.insert!(%Route{from_id: glasgow.id, to_id: bremen.id, distance: 886})
Repo.insert!(%Route{from_id: glasgow.id, to_id: antwerp.id, distance: 771})
Repo.insert!(%Route{from_id: glasgow.id, to_id: dunkirk.id, distance: 701})
Repo.insert!(%Route{from_id: glasgow.id, to_id: calais.id, distance: 672})
Repo.insert!(%Route{from_id: glasgow.id, to_id: dublin.id, distance: 177})
Repo.insert!(%Route{from_id: amsterdam.id, to_id: london.id, distance: 259})
Repo.insert!(%Route{from_id: amsterdam.id, to_id: edinburgh.id, distance: 438})
Repo.insert!(%Route{from_id: amsterdam.id, to_id: bristol.id, distance: 732})
Repo.insert!(%Route{from_id: amsterdam.id, to_id: hull.id, distance: 248})
Repo.insert!(%Route{from_id: amsterdam.id, to_id: portsmouth.id, distance: 333})
Repo.insert!(%Route{from_id: amsterdam.id, to_id: plymouth.id, distance: 462})
Repo.insert!(%Route{from_id: amsterdam.id, to_id: glasgow.id, distance: 863})
Repo.insert!(%Route{from_id: amsterdam.id, to_id: rotterdam.id, distance: 131})
Repo.insert!(%Route{from_id: amsterdam.id, to_id: hamburg.id, distance: 229})
Repo.insert!(%Route{from_id: amsterdam.id, to_id: bremen.id, distance: 217})
Repo.insert!(%Route{from_id: amsterdam.id, to_id: antwerp.id, distance: 190})
Repo.insert!(%Route{from_id: amsterdam.id, to_id: dunkirk.id, distance: 207})
Repo.insert!(%Route{from_id: amsterdam.id, to_id: calais.id, distance: 224})
Repo.insert!(%Route{from_id: amsterdam.id, to_id: dublin.id, distance: 744})
Repo.insert!(%Route{from_id: rotterdam.id, to_id: london.id, distance: 153})
Repo.insert!(%Route{from_id: rotterdam.id, to_id: edinburgh.id, distance: 387})
Repo.insert!(%Route{from_id: rotterdam.id, to_id: bristol.id, distance: 624})
Repo.insert!(%Route{from_id: rotterdam.id, to_id: hull.id, distance: 186})
Repo.insert!(%Route{from_id: rotterdam.id, to_id: portsmouth.id, distance: 227})
Repo.insert!(%Route{from_id: rotterdam.id, to_id: plymouth.id, distance: 357})
Repo.insert!(%Route{from_id: rotterdam.id, to_id: glasgow.id, distance: 782})
Repo.insert!(%Route{from_id: rotterdam.id, to_id: amsterdam.id, distance: 131})
Repo.insert!(%Route{from_id: rotterdam.id, to_id: hamburg.id, distance: 263})
Repo.insert!(%Route{from_id: rotterdam.id, to_id: bremen.id, distance: 251})
Repo.insert!(%Route{from_id: rotterdam.id, to_id: antwerp.id, distance: 78})
Repo.insert!(%Route{from_id: rotterdam.id, to_id: dunkirk.id, distance: 95})
Repo.insert!(%Route{from_id: rotterdam.id, to_id: calais.id, distance: 113})
Repo.insert!(%Route{from_id: rotterdam.id, to_id: dublin.id, distance: 636})
Repo.insert!(%Route{from_id: hamburg.id, to_id: london.id, distance: 383})
Repo.insert!(%Route{from_id: hamburg.id, to_id: edinburgh.id, distance: 521})
Repo.insert!(%Route{from_id: hamburg.id, to_id: bristol.id, distance: 856})
Repo.insert!(%Route{from_id: hamburg.id, to_id: hull.id, distance: 332})
Repo.insert!(%Route{from_id: hamburg.id, to_id: portsmouth.id, distance: 457})
Repo.insert!(%Route{from_id: hamburg.id, to_id: plymouth.id, distance: 587})
Repo.insert!(%Route{from_id: hamburg.id, to_id: glasgow.id, distance: 897})
Repo.insert!(%Route{from_id: hamburg.id, to_id: amsterdam.id, distance: 229})
Repo.insert!(%Route{from_id: hamburg.id, to_id: rotterdam.id, distance: 263})
Repo.insert!(%Route{from_id: hamburg.id, to_id: bremen.id, distance: 58})
Repo.insert!(%Route{from_id: hamburg.id, to_id: antwerp.id, distance: 322})
Repo.insert!(%Route{from_id: hamburg.id, to_id: dunkirk.id, distance: 333})
Repo.insert!(%Route{from_id: hamburg.id, to_id: calais.id, distance: 348})
Repo.insert!(%Route{from_id: hamburg.id, to_id: dublin.id, distance: 868})
Repo.insert!(%Route{from_id: bremen.id, to_id: london.id, distance: 371})
Repo.insert!(%Route{from_id: bremen.id, to_id: edinburgh.id, distance: 509})
Repo.insert!(%Route{from_id: bremen.id, to_id: bristol.id, distance: 844})
Repo.insert!(%Route{from_id: bremen.id, to_id: hull.id, distance: 320})
Repo.insert!(%Route{from_id: bremen.id, to_id: portsmouth.id, distance: 445})
Repo.insert!(%Route{from_id: bremen.id, to_id: plymouth.id, distance: 575})
Repo.insert!(%Route{from_id: bremen.id, to_id: glasgow.id, distance: 886})
Repo.insert!(%Route{from_id: bremen.id, to_id: amsterdam.id, distance: 217})
Repo.insert!(%Route{from_id: bremen.id, to_id: rotterdam.id, distance: 251})
Repo.insert!(%Route{from_id: bremen.id, to_id: hamburg.id, distance: 58})
Repo.insert!(%Route{from_id: bremen.id, to_id: antwerp.id, distance: 310})
Repo.insert!(%Route{from_id: bremen.id, to_id: dunkirk.id, distance: 321})
Repo.insert!(%Route{from_id: bremen.id, to_id: calais.id, distance: 336})
Repo.insert!(%Route{from_id: bremen.id, to_id: dublin.id, distance: 856})
Repo.insert!(%Route{from_id: antwerp.id, to_id: london.id, distance: 168})
Repo.insert!(%Route{from_id: antwerp.id, to_id: edinburgh.id, distance: 421})
Repo.insert!(%Route{from_id: antwerp.id, to_id: bristol.id, distance: 613})
Repo.insert!(%Route{from_id: antwerp.id, to_id: hull.id, distance: 220})
Repo.insert!(%Route{from_id: antwerp.id, to_id: portsmouth.id, distance: 218})
Repo.insert!(%Route{from_id: antwerp.id, to_id: plymouth.id, distance: 347})
Repo.insert!(%Route{from_id: antwerp.id, to_id: glasgow.id, distance: 771})
Repo.insert!(%Route{from_id: antwerp.id, to_id: amsterdam.id, distance: 190})
Repo.insert!(%Route{from_id: antwerp.id, to_id: rotterdam.id, distance: 78})
Repo.insert!(%Route{from_id: antwerp.id, to_id: hamburg.id, distance: 322})
Repo.insert!(%Route{from_id: antwerp.id, to_id: bremen.id, distance: 310})
Repo.insert!(%Route{from_id: antwerp.id, to_id: dunkirk.id, distance: 84})
Repo.insert!(%Route{from_id: antwerp.id, to_id: calais.id, distance: 102})
Repo.insert!(%Route{from_id: antwerp.id, to_id: dublin.id, distance: 625})
Repo.insert!(%Route{from_id: dunkirk.id, to_id: london.id, distance: 104})
Repo.insert!(%Route{from_id: dunkirk.id, to_id: edinburgh.id, distance: 413})
Repo.insert!(%Route{from_id: dunkirk.id, to_id: bristol.id, distance: 543})
Repo.insert!(%Route{from_id: dunkirk.id, to_id: hull.id, distance: 212})
Repo.insert!(%Route{from_id: dunkirk.id, to_id: portsmouth.id, distance: 150})
Repo.insert!(%Route{from_id: dunkirk.id, to_id: plymouth.id, distance: 279})
Repo.insert!(%Route{from_id: dunkirk.id, to_id: glasgow.id, distance: 701})
Repo.insert!(%Route{from_id: dunkirk.id, to_id: amsterdam.id, distance: 207})
Repo.insert!(%Route{from_id: dunkirk.id, to_id: rotterdam.id, distance: 95})
Repo.insert!(%Route{from_id: dunkirk.id, to_id: hamburg.id, distance: 333})
Repo.insert!(%Route{from_id: dunkirk.id, to_id: bremen.id, distance: 321})
Repo.insert!(%Route{from_id: dunkirk.id, to_id: antwerp.id, distance: 84})
Repo.insert!(%Route{from_id: dunkirk.id, to_id: calais.id, distance: 32})
Repo.insert!(%Route{from_id: dunkirk.id, to_id: dublin.id, distance: 555})
Repo.insert!(%Route{from_id: calais.id, to_id: london.id, distance: 93})
Repo.insert!(%Route{from_id: calais.id, to_id: edinburgh.id, distance: 414})
Repo.insert!(%Route{from_id: calais.id, to_id: bristol.id, distance: 514})
Repo.insert!(%Route{from_id: calais.id, to_id: hull.id, distance: 213})
Repo.insert!(%Route{from_id: calais.id, to_id: portsmouth.id, distance: 121})
Repo.insert!(%Route{from_id: calais.id, to_id: plymouth.id, distance: 251})
Repo.insert!(%Route{from_id: calais.id, to_id: glasgow.id, distance: 672})
Repo.insert!(%Route{from_id: calais.id, to_id: amsterdam.id, distance: 224})
Repo.insert!(%Route{from_id: calais.id, to_id: rotterdam.id, distance: 113})
Repo.insert!(%Route{from_id: calais.id, to_id: hamburg.id, distance: 348})
Repo.insert!(%Route{from_id: calais.id, to_id: bremen.id, distance: 336})
Repo.insert!(%Route{from_id: calais.id, to_id: antwerp.id, distance: 102})
Repo.insert!(%Route{from_id: calais.id, to_id: dunkirk.id, distance: 32})
Repo.insert!(%Route{from_id: calais.id, to_id: dublin.id, distance: 526})
Repo.insert!(%Route{from_id: dublin.id, to_id: london.id, distance: 597})
Repo.insert!(%Route{from_id: dublin.id, to_id: edinburgh.id, distance: 627})
Repo.insert!(%Route{from_id: dublin.id, to_id: bristol.id, distance: 379})
Repo.insert!(%Route{from_id: dublin.id, to_id: hull.id, distance: 726})
Repo.insert!(%Route{from_id: dublin.id, to_id: portsmouth.id, distance: 424})
Repo.insert!(%Route{from_id: dublin.id, to_id: plymouth.id, distance: 290})
Repo.insert!(%Route{from_id: dublin.id, to_id: glasgow.id, distance: 177})
Repo.insert!(%Route{from_id: dublin.id, to_id: amsterdam.id, distance: 744})
Repo.insert!(%Route{from_id: dublin.id, to_id: rotterdam.id, distance: 636})
Repo.insert!(%Route{from_id: dublin.id, to_id: hamburg.id, distance: 868})
Repo.insert!(%Route{from_id: dublin.id, to_id: bremen.id, distance: 856})
Repo.insert!(%Route{from_id: dublin.id, to_id: antwerp.id, distance: 625})
Repo.insert!(%Route{from_id: dublin.id, to_id: dunkirk.id, distance: 555})
Repo.insert!(%Route{from_id: dublin.id, to_id: calais.id, distance: 526})

Repo.insert!(%Good{
  name: "Grain",
  description: "Cereal grains for bread and ale",
  category: "Staple",
  base_price: 40,
  volatility: 0.20,
  elasticity: 0.35
})

Repo.insert!(%Good{
  name: "Salt",
  description: "Salt for preserving food and curing fish/meat",
  category: "Staple",
  base_price: 60,
  volatility: 0.10,
  elasticity: 0.30
})

Repo.insert!(%Good{
  name: "Coal",
  description: "Coal for heating and industry",
  category: "Staple",
  base_price: 35,
  volatility: 0.13,
  elasticity: 0.28
})

Repo.insert!(%Good{
  name: "Timber",
  description: "Timber for shipbuilding and construction",
  category: "Material",
  base_price: 50,
  volatility: 0.16,
  elasticity: 0.25
})

Repo.insert!(%Good{
  name: "Iron",
  description: "Iron bars and pig iron for tools and hardware",
  category: "Industrial",
  base_price: 100,
  volatility: 0.14,
  elasticity: 0.22
})

Repo.insert!(%Good{
  name: "Copper",
  description: "Copper for coinage, cookware, and fittings",
  category: "Industrial",
  base_price: 110,
  volatility: 0.17,
  elasticity: 0.20
})

Repo.insert!(%Good{
  name: "Wool",
  description: "Raw wool for spinning and weaving",
  category: "Material",
  base_price: 80,
  volatility: 0.15,
  elasticity: 0.27
})

Repo.insert!(%Good{
  name: "Cloth",
  description: "Finished cloth and textiles",
  category: "Industrial",
  base_price: 150,
  volatility: 0.12,
  elasticity: 0.18
})

Repo.insert!(%Good{
  name: "Fish",
  description: "Salted fish and fresh catch (varies by season)",
  category: "Staple",
  base_price: 45,
  volatility: 0.22,
  elasticity: 0.33
})

Repo.insert!(%Good{
  name: "Wine",
  description: "Barrelled wine from France and Iberia",
  category: "Luxury",
  base_price: 120,
  volatility: 0.18,
  elasticity: 0.16
})

Repo.insert!(%Good{
  name: "Hemp",
  description: "Hemp for rope, sails, and rigging",
  category: "Material",
  base_price: 65,
  volatility: 0.18,
  elasticity: 0.24
})

Repo.insert!(%Good{
  name: "Tar/Pitch",
  description: "Tar and pitch for sealing hulls and rigging",
  category: "Material",
  base_price: 75,
  volatility: 0.19,
  elasticity: 0.23
})

Repo.insert!(%Good{
  name: "Spices",
  description: "High-value spices from long-distance trade",
  category: "Luxury",
  base_price: 300,
  volatility: 0.25,
  elasticity: 0.12
})

Repo.insert!(%Good{
  name: "Silk",
  description: "Fine silk cloth from long-distance trade",
  category: "Luxury",
  base_price: 400,
  volatility: 0.30,
  elasticity: 0.10
})

Repo.insert!(%ShipType{
  name: "Cog",
  description: "Sturdy coastal trader. Cheap, small hold.",
  capacity: 50,
  speed: 4,
  base_price: 3000,
  upkeep: 1500,
  passengers: 0
})

Repo.insert!(%ShipType{
  name: "Caravel",
  description: "Fast and versatile merchant ship.",
  capacity: 100,
  speed: 6,
  base_price: 6000,
  upkeep: 3000,
  passengers: 0
})

Repo.insert!(%ShipType{
  name: "Galleon",
  description: "Large ocean-going hauler. Big hold, expensive upkeep.",
  capacity: 200,
  speed: 5,
  base_price: 12000,
  upkeep: 6000,
  passengers: 0
})

# Shipyards
Repo.insert!(%Shipyard{port_id: london.id})
Repo.insert!(%Shipyard{port_id: amsterdam.id})
Repo.insert!(%Shipyard{port_id: hamburg.id})
Repo.insert!(%Shipyard{port_id: edinburgh.id})
