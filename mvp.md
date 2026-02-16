# MVP Critical Path Task List (Oban/Cron moved to the end)

Time model:

- Canonical: `tick :: integer` where **1 tick = 1 game hour**
- Mapping (fixed): **1 tick = 24 seconds realtime**
- Derived: 1 day = 24 ticks, 7 days = 168 ticks, 30 days = 720 ticks

Rule: **All logic uses ticks**. Real timestamps are UI-only.

---

## Milestone 1 — World + identity + scope

- [x] Implement `World` context API (ports/goods/countries/ship_types/distances; read-only)
  - `World.list_ports/0`, `World.get_port!/1`, `World.list_goods/0`, `World.get_good!/1` - `World.get_distance_days!/2`, `World.ship_type!/1`

- [x] Seed world data: 14 ports + shipyard flags + countries/regions
  - Shipyards: London, Amsterdam, Hamburg, Edinburgh
  - Others: Bristol, Hull, Portsmouth, Plymouth, Rotterdam, Antwerp, Dunkirk, Dublin, Calais, Bremen

- [x] Seed goods (12) with base params (base_price, volatility, elasticity)

- [x] Seed ship types (**MVP ships**) as static definitions
  - cog: capacity 50, base_price 3000, speed (if used), monthly_upkeep
  - caravel: capacity 100, base_price 6000, speed, monthly_upkeep
  - galleon: capacity 200, base_price 12000, speed, monthly_upkeep

- [x] Seed distance matrix in game-days (bidirectional)

- [x] Implement `Accounts` stubs (player auth) sufficient to obtain a `player_id`

- [x] Implement `Scope` module + hydration from player
  - `%Scope{player, company_ids}`
  - `Scope.authorizes?(scope, company_id)`

---

## Milestone 2 — Companies + Credits ledger + taxes

- [ ] Implement company + director membership model (player can direct many companies)

- [ ] Implement `Companies.create_company(scope, attrs)` (starting port is player choice)

- [ ] Implement Credits ledger (append-only) + company balance update rule
  - Every credit movement writes a ledger record: `{company_id, delta, reason, tick, meta}`

- [ ] Implement tax config model (per port bps) + shared tax calculator
  - Decide rounding rule (recommend: `ceil(amount * bps / 10_000)`)

- [ ] Implement “apply tax” ledger flow (sink/tax account or burned counter)

---

## Milestone 3 — Fleet (ships): buying, cargo, transit time, arrival processing (no Oban yet)

- [ ] Implement ship persistence + ownership (company_id) + state fields
  - `status: docked|traveling|dormant`, `location_port_id`, `destination_port_id`, `arrival_tick`, `age_days`

- [ ] Implement ship purchase from shipyard port (scope + company_id required)
  - Validate: scope authorizes company, port has shipyard, credits >= price + tax
  - Debit via ledger, create ship in `docked` at port

- [ ] Implement ship cargo persistence (barrels only)
  - Enforce: `sum(qty) <= capacity`

- [ ] Implement transit time calculation (ticks) from world distance + (optional) ship speed
  - If you keep speed: `travel_days = distance_days * (base_speed / ship_speed)`
  - Convert to ticks: `travel_ticks = ceil(travel_days * 24)`

- [ ] Implement `Fleet.sail_ship(scope, ship_id, destination_port_id, current_tick)`
  - Validate: owned by scope, ship docked, route exists
  - Set traveling + destination + `arrival_tick = current_tick + travel_ticks`

- [ ] Implement arrival processing function `Fleet.process_arrivals(current_tick)`
  - Finds ships with `status=traveling AND arrival_tick <= current_tick` and docks them
  - Idempotent update (safe to run repeatedly)

---

## Milestone 4 — Shipyards: construction/restocking of ships (no Oban yet)

- [ ] Implement shipyard inventory model per `(port_id, ship_type_id)` with `inventory_count`

- [ ] Implement ship purchase consumes shipyard inventory
  - If `inventory_count == 0` return error (MVP) OR allow backorder (pick one)

- [ ] Implement ship construction function `Shipyards.produce_ships(current_tick)`
  - Production cadence: on day boundary (every 24 ticks), add N inventory per type per shipyard (e.g., 1/day/type)
  - Must be idempotent for the same day boundary (store `last_produced_tick`)

---

## Milestone 5 — Logistics (warehouses): store/withdraw, grow/shrink, cost curve

- [ ] Implement warehouse persistence with unique `(company_id, port_id)` and tier/capacity
  - Capacity = `tier * 100` barrels
  - Contents = `{good_id => qty}`

- [ ] Implement warehouse pricing functions (quote-only)
  - Upgrade cost per tier: `100 * 1.1^(tier-1)` (integer)
  - Monthly upkeep rate per 10 bbl: `10 * 1.05^(tier-1)` (integer)
  - Total upkeep = `(capacity/10) * rate`

- [ ] Implement grow warehouse tier (scope auth + ledger debit + tax)
  - Increase tier by 1 (or to target tier), update capacity

- [ ] Implement shrink warehouse tier (scope auth)
  - Cannot shrink below `used` capacity; decide refund rule (recommend none for MVP)

- [ ] Implement deposit from ship → warehouse (scope auth + port-local)
  - Validate: ship owned, ship docked at warehouse port, warehouse owned, capacity available
  - Atomic: decrement ship cargo, increment warehouse contents

- [ ] Implement withdraw from warehouse → ship (scope auth + port-local)
  - Validate: ship owned + docked, warehouse owned, ship capacity available, enough stock
  - Atomic: decrement warehouse contents, increment ship cargo

---

## Milestone 6 — Economy scaffolding: shocks + tick boundaries + restocking hooks

- [ ] Implement `game_clock` storage: `{epoch_realtime, epoch_tick}` and `Clock.current_tick/0`

- [ ] Implement `Economy.Shocks` persistence (scoped shock targeting)
  - Fields: type, start_tick, duration_ticks, multiplier, optional port_id, optional good_id
  - Function: list active shocks for a given tick

- [ ] Implement a “day boundary” helper
  - `day = div(tick, 24)` and “did we already process this day?” guard

---

## Milestone 7 — Commerce (NPC trader): trader maths, restocking, instant buy/sell

Data split (per port-good):

- `npc_stock` (physical): stock, target_stock, base_supply, base_demand, elasticity, volatility_base
- `npc_trader` (stance): monthly_profit, spread, last_reset_day

- [ ] Implement `npc_stock` + `npc_trader` persistence and initial seeding

- [ ] Implement effective supply/demand computation with shocks
  - Given `(port_id, good_id, tick)` -> `{supply_eff, demand_eff, volatility_eff}`

- [ ] Implement daily NPC restocking/simulation `Commerce.simulate_day(day)`
  - Update stock: `stock += supply_eff - demand_eff - net_player_flow`
  - Clamp stock bounds
  - Update volatility (bounded random walk / mean reversion)
  - Record `last_simulated_day` for idempotency

- [ ] Implement NPC price function (quantities hidden)
  - Compute `mid_price` from imbalance (stock vs target, demand vs supply) + noise
  - Return: `{price, spread, trend, availability_bucket}` only

- [ ] Implement slippage/impact model per instant trade (quantity-based, capped)

- [ ] Implement instant buy from NPC trader (`Commerce.buy_from_trader/4`)
  - Validate: ship owned, docked at port, credits sufficient, apply tax
  - Atomic: ledger debit, ship cargo +Q, npc_stock -Q, npc_trader profit/spread update

- [ ] Implement instant sell to NPC trader (`Commerce.sell_to_trader/4`)
  - Validate: ship owned, docked, cargo sufficient, apply tax
  - Atomic: ledger credit, ship cargo -Q, npc_stock +Q, npc_trader profit/spread update

- [ ] Implement monthly NPC reset (`Commerce.reset_month(month)`)
  - Every 30 days: reset monthly_profit, reset spread to default, optional shock cleanup

- [ ] Implement net-player-flow aggregation for NPC simulation
  - From trade log (NPC trades only), by `(port_id, good_id, day)`

---

## Milestone 8 — Market (player order book): orders, matching, settlement, taxes

- [ ] Implement order persistence (tick-based expiry)
  - Fields: company_id, port_id, good_id, side, price, qty_remaining, inserted_tick, expires_tick, is_npc

- [ ] Decide and implement reserve model (MVP choice) for limit orders
  - Buy orders: reserve Credits (escrow ledger lock)
  - Sell orders: reserve goods from **warehouse at that port** (simplest + avoids “ship not here”)

- [ ] Implement place limit order (scope auth + reserves + expiry = now+168 ticks)

- [ ] Implement cancel order (scope auth + release reserves)

- [ ] Implement matching engine for one `(port_id, good_id)` book
  - Price-time priority, partial fills, emits fill records

- [ ] Implement settlement for a matched fill (atomic)
  - Move Credits (buyer→seller), apply taxes, update reserves, update warehouse holdings
  - Write trade log (unambiguous buyer/seller)

- [ ] Implement order expiry sweep function (releases reserves)
  - Expire `expires_tick <= current_tick`

- [ ] Implement market read endpoints/functions
  - Best N levels per side (e.g., 3) + last 24h fills (anonymized)

---

## Milestone 9 — Cross-cutting: trade logs, invariants, upkeep

- [ ] Implement trade log (dual-entry clarity)
  - Store buyer/seller identities, qty, price, port, tick, source (`npc_instant` / `market`)

- [ ] Implement monthly company upkeep calculation (ships + warehouses)
  - Ships: monthly upkeep by type (and any age factor if you keep it)
  - Warehouses: computed from tier curve

- [ ] Implement monthly upkeep processing function (ledger debits + delinquency flags)
  - If unpaid: ships become dormant after grace; warehouses evict after grace (MVP rules)

---

## Milestone 10 — Temporary scheduler (non-Oban) to make the game “run”

(You need something to call these regularly before Oban.)

- [ ] Implement `GameTick.run(current_tick)` orchestrator function
  - Calls: `Fleet.process_arrivals/1`, day-boundary ship production, day-boundary NPC simulate, order expiry, monthly reset/upkeep

- [ ] Implement a simple in-process tick runner (GenServer) calling `GameTick.run/1`
  - Interval: every 24 seconds; can be disabled in dev/tests

---

## Milestone 11 — Oban/Cron LAST (replace temp scheduler + scale-out)

- [ ] Add Oban + queues configuration (`economy`, `market`, `travel`, `upkeep`) and migrations

- [ ] Replace GenServer tick runner with Oban Cron jobs
  - Cron job: every 24s -> run `GameTick.run/1` (or split into separate workers)

- [ ] Replace arrival scanning with “schedule on departure” Oban jobs
  - When sailing: enqueue `ShipArrival` at `scheduled_at`
  - Keep `Fleet.process_arrivals/1` as fallback/repair tool (admin)

- [ ] Move heavy sweeps (order expiry, shipyard production, NPC simulation) to Oban workers
  - Ensure idempotency with day/month boundary guards

---

If you want, I can turn this into a sprint plan (Sprint 1/2/3) with “demoable outputs” at the end of each sprint.
