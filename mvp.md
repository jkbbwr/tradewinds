# 1600 Trading Game (API-driven) — Compressed Spec Summary

## Core Premise

- Setting: ~1600 maritime trading.
- Region (MVP map): England + NW Europe.
- Players form **Companies**.
- Companies own **Ships**, trade **Goods** by the **barrel**.
- Currency: **Credit** (integer only, non-fractional).
- No combat for MVP.

## Time

- Compressed realtime: **1 hour realtime = 6 days 6 hours game time**.
- Treat “game day” as the fundamental unit.
- Strong recommendation: represent time as a **monotonically increasing integer tick** (e.g., `tick = game_day`), use real timestamps only for UI.

## World

- Ports: **14**
  - Shipyards: **London, Amsterdam, Hamburg, Edinburgh**
  - Other ports: **Bristol, Hull, Portsmouth, Plymouth, Rotterdam, Antwerp, Dunkirk, Dublin, Calais, Bremen**
- Ports connected by a **distance matrix** in game-days (initially NW Europe; later extend to global routes).

## Goods

- 12 global goods, all **1 barrel per unit** (no weight/volume).
- Example set (base price, volatility):
  - wool 80 (0.15), cloth 150 (0.12), grain 40 (0.20), wine 120 (0.18),
    salt 60 (0.10), iron 100 (0.14), timber 50 (0.16), fish 45 (0.22),
    hops 70 (0.19), coal 35 (0.13), spices 300 (0.25), silk 400 (0.30)

## Ships

- 3 types (capacity in barrels):
  - cog: cap 50, base 3000
  - caravel: cap 100, base 6000
  - galleon: cap 200, base 12000
- Upkeep: **monthly** (not per voyage). No travel cost.
- No max ships per company; upkeep is the sink.

## Warehouses

- Companies can buy storage in ports.
- Storage has **increasing marginal cost** (“cost curve”) so big storage is expensive.
  - Suggested: capacity in 100-barrel tiers:
    - Purchase per tier: `100 * 1.1^(tier-1)`
    - Monthly upkeep per 10 barrels: `10 * 1.05^(tier-1)`
- Warehouses have monthly upkeep; failure leads to eviction/auction rules (see edge cases).

## Markets (Two Separate Mechanisms)

### 1) NPC Trader (instant execution)

- NPC “Trader” is NOT the same as the player order book.
- Quantities/stock are **hidden** from players.
- Trader must model: **supply, demand, stock, total stock bounds, price shocks, volatility, profit, sources & sinks**.
- Player trades affect trader pricing decisions (slippage + profit feedback).

### 2) Player Order Book (limit orders)

- Separate per port per good.
- Orders: buy stack (high→low), sell stack (low→high).
- Order expiration: **7 game days**.
- Players can place/cancel limit orders (remote allowed is a design choice; instant NPC trades should require being docked).
- “Ghost orders”: NPC-posted liquidity in the order book (synthetic orders), refreshed periodically.

## NPC Trader Maths (High-level)

- Split state into two DB tables:
  - `npc_stock` (daily physical/economic state): stock, target_stock, base supply/demand, volatility base, elasticity, active shock refs or computed via shocks.
  - `npc_trader` (monthly trading stance): spread, profit (resets monthly).
- Each day/tick:
  - Apply shock decay + compute effective supply/demand.
  - Update stock from supply - demand - net player flow.
  - Compute mid price from stock imbalance + supply/demand imbalance + inflation + noise.
  - Apply slippage on each trade (`impact` grows with Q, capped).
  - Update profit and adjust spread (clamped).
- Monthly:
  - reset NPC profit/spread/volatility to base; clear shocks if desired.

## Shocks

- Model shocks as first-class rows in a `shocks` table:
  - global/port/good scoped: (port_id nullable, good_id nullable)
  - start_tick, duration_ticks, multiplier, type
- Apply shocks at runtime during tick calculations (don’t denormalize into every port-good row).

## Inflation (optional but discussed)

- Global inflation factor π based on money supply vs target; clamp to ±5%.
- Apply π to NPC pricing and upkeep.

## “Ghost Orders”

- Synthetic NPC limit orders in the player order book to ensure liquidity.
- Distinct from instant NPC trader endpoint.
- Marked `is_npc: true`.
- Refresh interval discussed (e.g., every 6 “game hours” mapped to a cron period).
- Players see top-of-book; quantities can be hidden if desired.

## Transaction Logging (make buy/sell unambiguous)

- Avoid ambiguous `type: buy|sell` without perspective.
- Log trades as **actor-action pairs**:
  - e.g., `player bought` and `npc sold` in same record (dual-entry), or two linked rows.
- This clarifies “buy/sell from whose perspective”.

## Time Processing / Ticks + Oban

- At scale (100 players \* 100 ships = 10,000 ships), avoid a single sequential tick loop.
- Use **Oban** for concurrency + reliability.
- Oban OSS includes **Cron plugin** (free) for periodic jobs.
- Preferred pattern:
  - Periodic jobs via `Oban.Plugins.Cron`:
    - economic tick (daily) job
    - ghost refresh job
    - monthly upkeep/reset job (or check inside economic tick)
  - Ship arrivals:
    - Strong option: **schedule arrival job at departure** with `scheduled_at` computed from travel duration.
    - Worker should be idempotent and confirm ship is still traveling & ETA matches.
- Use ticks as canonical time, but Oban scheduling uses real `scheduled_at`; keep mapping stable.

## Access Rules (design)

- Suggested hybrid:
  - Allow remote viewing/order placement (possibly with info delay).
  - Require being docked for instant NPC trades + warehouse transfers.

## Edge Cases (sensible defaults)

- NPC stock 0: can’t sell (to player) / availability “scarce”; widen spread.
- NPC stock > max: stop buying; tighten/widen as desired; optional spoilage for perishables.
- Spread clamped (3%–15%).
- Warehouse unpaid: eviction after grace window; contents auctioned (e.g., 50% NPC price), proceeds to sink/NPC profit pool.
- Ship unpaid upkeep: mark dormant after grace window; cannot sail until arrears paid.
- Orders expire before matching at tick boundary.

## Phoenix Contexts (stubs only)

- `World` (read-only lookups):
  - `World.Goods`, `World.Ports`, `World.Countries`, `World.ShipTypes`, `World.Config`
- Stateful contexts:
  - `Companies` (credits, solvency, upkeep)
  - `Ships` (purchase, sail, cargo, dock)
  - `Warehouses` (rent/purchase, transfers, upkeep/eviction)
  - `Trading.NPCTrading` (instant trader, profit/spread)
  - `Trading.Market` (order books, matching, ghost orders)
  - `Economy` (inflation, shocks, daily/monthly tick logic)
- Workers:
  - `Workers.EconomicTick`, `Workers.GhostRefresh`, `Workers.ShipArrival`, `Workers.MonthlyUpkeep` (as needed)

## API (conceptual)

- Companies: create/get.
- Ships: buy/get/sail; cargo operations.
- Ports: view trader (no quantities), view order book.
- Trader: instant buy/sell at port (requires ship docked).
- Orders: place/cancel, execute trades vs order book.
- Warehouses: buy capacity, load/unload.

## Key Decisions Locked In

- Credit integer currency.
- 14 NW Europe ports.
- 12 goods, all 1 barrel units.
- No travel cost; monthly upkeep.
- Trader and order book separate.
- Stock hidden.
- Orders expire after 7 days.
- Shocks stored in DB, applied at runtime.
- Oban + cron for periodic work; schedule arrivals at departure is acceptable/preferred.
- Use monotonic ticks as canonical time.
