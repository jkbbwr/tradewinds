# MVP Critical Path Task List (Tax moved to the end)

Time model:

- Canonical: `tick :: integer` where **1 tick = 1 game hour**
- Mapping: **1 tick = 24 seconds realtime**
- Derived: 1 day = 24 ticks, 7 days = 168 ticks, 30 days = 720 ticks
- Rule: all logic uses ticks.

---

## Milestone 1 — World + identity + scope

- [x] Implement `World` context API (ports/goods/countries/ship_types/distances; read-only)
- [x] Seed world data: 14 ports + shipyard flags + countries/regions
- [x] Seed goods (14) with base params (base_price, volatility, elasticity)
- [x] Seed ship types (MVP ships)
  - Cog (cap 50), Caravel (cap 100), Galleon (cap 200)
  - Speed is **knots** (nm/hour); routes store **distance in nm**
- [x] Seed distance matrix in nm (bidirectional)
- [x] Implement `Accounts` stubs (player auth) sufficient to obtain `player_id`
- [x] Implement `Scope` module + hydration from player + `authorizes?/2`

---

## Milestone 2 — Companies + Credits ledger (no taxes here)

- [x] Implement company + director membership model (player can direct many companies)
- [x] Implement `Companies.create_company(scope, attrs)` (starting port is player choice)
- [x] Implement company balance storage (`companies.credits_balance` integer)
- [x] Implement append-only `company_ledger_entries`
  - Signed `amount` (+ inflow, - outflow), `reason`, `tick`, `ref_type/ref_id`, `meta`
  - Add `idempotency_key` unique per company to prevent double-posting
- [x] Implement atomic money movement primitive (spec)
  - Within one transaction: lock company row, check sufficient funds (no negative),
    insert ledger entry, update cached balance

---

## Milestone 3 — Fleet (ships): buying, cargo, transit time, arrival processing (no Oban yet)

- [ ] Implement ship persistence + ownership + state fields
- [ ] Implement ship purchase from shipyard port (scope + company_id required)
- [ ] Implement ship cargo persistence (barrels only) + capacity enforcement
- [ ] Implement transit time formula with nm + knots + modifiers
  - `travel_ticks = ceil_div(distance_nm, effective_knots)`
  - `effective_knots = floor(base_knots * (10_000 + bonus_bps) / 10_000)` clamped to >= 1
- [ ] Implement `Fleet.sail_ship(scope, ship_id, destination_port_id, current_tick)`
- [ ] Implement `Fleet.process_arrivals(current_tick)` (idempotent docking)

---

## Milestone 4 — Shipyards: inventory + construction/restocking (no Oban yet)

- [ ] Implement shipyard inventory per `(port_id, ship_type)` with `inventory_count`
- [ ] Implement ship purchase consumes shipyard inventory
- [ ] Implement ship construction function `Shipyards.produce_ships(current_tick)`
  - Produce at day boundary (every 24 ticks), idempotent via `last_produced_day`

---

## Milestone 5 — Logistics (warehouses): store/withdraw, grow/shrink, cost curve

- [ ] Implement warehouse persistence unique `(company_id, port_id)` + tier + contents
- [ ] Implement warehouse pricing functions (quote-only)
  - Upgrade cost per tier: `100 * 1.1^(tier-1)` (int)
  - Monthly upkeep rate per 10 bbl: `10 * 1.05^(tier-1)` (int)
- [ ] Implement grow warehouse tier (scope auth + ledger debit)
- [ ] Implement shrink warehouse tier (scope auth, cannot shrink below used)
- [ ] Implement deposit ship→warehouse (scope auth, ship docked at port, atomic)
- [ ] Implement withdraw warehouse→ship (scope auth, ship docked, atomic)

---

## Milestone 6 — Economy scaffolding: clock + shocks + day/month boundaries

- [ ] Implement `game_clock` storage + `Clock.current_tick/0`
- [ ] Implement `Economy.Shocks` persistence (scoped target: global/port/good)
- [ ] Implement day boundary helper (idempotent daily work guard)
- [ ] Implement month boundary helper (idempotent monthly work guard)

---

## Milestone 7 — Commerce (NPC trader): trader maths, restocking, instant buy/sell

- [ ] Implement `npc_stock` + `npc_trader` persistence + seeding
- [ ] Implement effective supply/demand/volatility computation with active shocks
- [ ] Implement daily NPC simulation `Commerce.simulate_day(day)`
  - stock drift/restocking + clamps + volatility update + idempotent guard
- [ ] Implement NPC price function (quantities hidden) + availability buckets
- [ ] Implement slippage/impact model (quantity-based, capped)
- [ ] Implement instant buy from NPC trader (atomic: ledger + cargo + npc state)
- [ ] Implement instant sell to NPC trader (atomic)
- [ ] Implement monthly reset for NPC trader stance (profit/spread reset)
- [ ] Implement net-player-flow aggregation for NPC simulation (from trade log)

---

## Milestone 8 — Market (order book): orders, matching, settlement (taxless for now)

- [ ] Implement order persistence (tick expiry) + 7-day expiry default
- [ ] Implement place limit order (scope auth)
- [ ] Implement cancel order (scope auth)
- [ ] Implement matching engine (per port+good) + fill emission
- [ ] Implement settlement for a matched fill (atomic ledger + inventory)
- [ ] Implement order expiry sweep (release/cancel logic TBD)
- [ ] Implement market read functions (best N levels + recent trades)

---

## Milestone 9 — Cross-cutting: trade logs + upkeep

- [ ] Implement trade log (unambiguous buyer/seller, qty, price, port, tick, source)
- [ ] Implement monthly company upkeep calculation (ships + warehouses)
- [ ] Implement monthly upkeep processing function (delinquency flags, dormant/evict rules)

---

## Milestone 10 — Oban/Cron LAST (replace temp scheduler + scale-out)

- [ ] Add Oban + queues config + migrations
- [ ] Replace GenServer tick runner with Oban Cron job(s)
- [ ] Replace arrival scanning with “schedule on departure” Oban jobs
- [ ] Split heavy sweeps into workers (idempotent day/month guards)

---

## Milestone 11 — Taxes (added at the end)

- [ ] Define tax configuration model (initially “burn it” sink)
  - At minimum: per-port bps for `npc_trade`, `market_trade`, `ship_purchase`, `warehouse_upgrade`
- [ ] Implement shared tax calculator helper (integer rounding rule)
- [ ] Apply tax to NPC trader instant buy/sell
  - Additional ledger outflow entry with `reason="tax"` and metadata
- [ ] Apply tax to market fills (order book settlement)
- [ ] Apply tax to ship purchases
- [ ] Apply tax to warehouse upgrades
- [ ] Add reporting hooks (optional): accumulate tax burned totals for debugging
