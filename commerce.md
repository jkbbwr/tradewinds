# NPC Trading System (Commerce Context) — Full Specification

This is the **NPC trader / Commerce** subsystem that models port merchants, supply/demand curves, restocking, and pricing logic.

---

## Core Purpose

- Each **port–good pair** has its own simulated supply/demand equilibrium.
- Players can **buy from** or **sell to** NPC traders instantly (no waiting or order book).
- NPC traders keep the economy alive by creating baseline liquidity and price movement.

---

## Database Model

### 1. `npc_stock` (physical economy layer)

| `                  | **Field** | **Type**                      | **Note** |
| ------------------ | --------- | ----------------------------- | -------- |
| **port_id**        | UUID      | Composite PK Part 1           |
| **good_id**        | UUID      | Composite PK Part 2           |
| **stock**          | Integer   | Current inventory             |
| **target_stock**   | Integer   | Equilibrium point             |
| **supply_rate**    | Float     | Daily production              |
| **demand_rate**    | Float     | Daily consumption             |
| **elasticity**     | Float     | Price sensitivity coefficient |
| **spread**         | Float     | Dynamic markup (NPC "greed")  |
| **monthly_profit** | Integer   | Performance tracking          |

## `

## Key Economic Formulas

### 1. Supply & Demand Update (Daily Tick)

At each daily tick (every 24 ticks ~ 9m36s realtime):

```
effective_supply = base_supply_rate * supply_mod
effective_demand = base_demand_rate * demand_mod
```

Where `supply_mod` and `demand_mod` are derived from **active shocks**:

| Shock Type | Effect                                   |
| ---------- | ---------------------------------------- |
| surplus    | supply ×2, demand ×0.5                   |
| shortage   | supply ×0.5, demand ×2                   |
| war        | demand ×3 for iron, demand ×0.3 for wine |
| blight     | supply ×0.3 on grain                     |

Then adjust stock:

```
new_stock = stock + effective_supply - effective_demand - net_player_flow
```

- `net_player_flow` = barrels bought by players (positive, reduces stock) minus barrels sold to NPCs (negative, increases stock).
- Clamp stock between 0 and 500 (or your chosen capacity).

---

### 2. Volatility Update

Each day:

```
volatility = clamp(0.02, 0.15, volatility + random_step)
random_step ∈ Normal(0, 0.002)
```

Used for Gaussian price “noise”.

---

### 3. Mid Price Formation

```
P_base = good.base_price

P_mid = P_base * (
  1
  + 0.4 * (demand_eff - supply_eff) / supply_eff
  + 0.3 * (target_stock - stock) / target_stock
)
```

Then apply volatility noise:

```
P_mid *= (1 + Normal(0, volatility))
```

Apply inflation if tracking:

```
P_mid *= (1 + π)
```

Clamp sense-maker guard (0.3× to 3× base).

---

### 4. Spread Adjustment (Profit Feedback)

After player trades settle, `monthly_profit` adjusts.
Each daily tick:

```
spread = clamp(0.03, 0.15, spread + (monthly_profit / 10_000) * 0.001)
```

- Profit ↑ → spread ↓ (NPC more competitive)
- Profit ↓ → spread ↑ (NPC widens margin)

---

### 5. Slippage (Trade Price Impact)

When a player executes a sizeable transaction:

```
impact = min(0.5, (quantity / 100) * 0.05)
```

Applied on top of the NPC spread.

Effective trade prices:

- **Player buys (outflow):**
    ```
    P_fill = P_mid * (1 + spread + impact)
    ```
- **Player sells (inflow):**
    ```
    P_fill = P_mid * (1 - spread - impact)
    ```

After each trade:

- Update `npc_stock.stock`
- Update `npc_trader.monthly_profit`
- Record transaction in player/company ledger

---

### 6. Monthly Reset

At day % 30 == 0:

- profit → 0
- spread → default (e.g. 5%)
- volatility → base value
- shocks cleared if any stale entries remain

---

## Shocks Model

**Table:** `shocks`

| Field           | Type             | Notes                          |
| --------------- | ---------------- | ------------------------------ |
| type            | enum             | surplus, shortage, war, blight |
| start_tick      | integer          | when it started                |
| duration_ticks  | integer          | active length                  |
| multiplier      | float            | optional numeric factor        |
| port_id         | UUID?            | nullable = global              |
| good_id         | UUID?            | nullable = affects all goods   |
| expires_at_tick | computed virtual |

**Trigger Rule:**

- 5% chance per day of a new shock starting in any given good (randomly picked).
- Volatility doubles during shock.

At tick boundaries:

- Decay `days_left--`, remove expired shocks.

---

## Player Interaction (Commerce Context)

### Instant Buy (Company Scope)

```elixir
Commerce.buy_from_trader(scope, ship_id, good_id, quantity)
```

- Validate:
    - ship owned by scope.company_id
    - ship docked at port
    - company has enough credits
- Compute price with spread+impact
- Deduct Credits (`amount + tax` if applicable)
- Add barrels to ship cargo
- Update NPC stock & profit
- Ledger entries:
    - debit: trade cost (reason `npc_trade`)
    - debit: tax (reason `tax`) if tax applied

### Instant Sell

Mirror logic (Earn Credits, remove from cargo, add to npc stock).

---

## Data Visibility

To players:

- **No raw quantities** (stock hidden)
- **Report:**
    - current price
    - trend (↑, ↓, →)
    - availability descriptor (`scarce`, `limited`, `adequate`, `plentiful`)
- Optionally: limited price history (24h sampled curve)

Availability heuristic:
| Stock | Tag |
|--------|------|
| <50 | scarce |
| <150 | limited |
| <350 | adequate |
| ≥350 | plentiful |

---

## Daily Simulation Pseudocode

```elixir
for each {port, good} do
  shocks = Shocks.active(port, good, tick)
  supply_eff, demand_eff, volatility_eff = compute_effective_rates(stock, shocks)
  new_stock = clamp(0, MAX_STOCK, stock + supply_eff - demand_eff - net_player_flow)
  volatility = update_volatility(volatility_base, volatility_eff)
  P_mid = compute_price(base_price, stock, target_stock, supply_eff, demand_eff, volatility)
  spread = adjust_spread(monthly_profit)

  update npc_stock(...)
  update npc_trader(...)
end
```

---

## Economy Integration

- NPC trader acts as **money sink/generator**:
    - When players buy: Credits leave their company and disappear (plus tax burned).
    - When players sell: Credits are conjured (NPC pays out) — effectively minting new money.
- Global money supply tracked via `economy_stats_daily.money_supply_total`
- Shocks and prices create economic waves across ports without deterministic patterns.

---

## Ledger Entries Example (Buy)

| Company    | Amount  | Reason    | Meta                                                                 |
| ---------- | ------- | --------- | -------------------------------------------------------------------- |
| Player Co. | -12,000 | npc_trade | %{good: "cloth", qty: 100, port: "London", price: 120, spread: 0.05} |
| Player Co. | -600    | tax       | %{tax_kind: "npc_trade", port: "London", bps: 500, tax_amount: 600}  |

---

## Typical Tunables (starting constants)

| Parameter               | Value         | Description            |
| ----------------------- | ------------- | ---------------------- |
| Max stock per port-good | 500 barrels   | clamp for comfort      |
| Base supply/demand      | 10–30 bbl/day | depends on good        |
| Default spread          | 5%            | trader margin          |
| Min–max spread          | 3–15%         | spread guard           |
| Volatility range        | 0.02–0.15     | normal random walk     |
| Shock chance            | 5% daily      | random event trigger   |
| Shock duration          | 3–5 days      | typical                |
| Shock impact            | 0.3–3.0×      | modifies supply/demand |

---

## Context Functions Summary (expected interface)

```elixir
defmodule Tradewinds.Commerce do
  # Player-facing
  def buy_from_trader(scope, ship_id, good_id, qty), do: {:ok, ...}
  def sell_to_trader(scope, ship_id, good_id, qty), do: {:ok, ...}
  def get_market_prices(scope, port_id), do: [price_info]

  # System-facing (workers)
  def simulate_day(day), do: :ok
  def reset_month(month), do: :ok
  def compute_mid_price(port_id, good_id), do: {:ok, price}
  def update_trader_state(port_id, good_id, attrs), do: :ok
end
```

---

## Conceptual Flow (Buy Example)

1. Player’s ship is docked at port.
2. Player buys 50 barrels of wine.
3. Price = base_price × (market imbalance) × (1 + spread + impact).
4. Credits deducted from company (ledger: trade + tax).
5. Ship gains cargo.
6. NPC stock decreases by 50.
7. Profit recorded, spread adjusted slightly.
8. Next day simulation slowly restocks port’s wine supply.

---

This specification defines the **NPC economy driver** that keeps trade dynamic and prevents static prices.
