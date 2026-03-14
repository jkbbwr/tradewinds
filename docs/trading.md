# Tradewinds NPC Trading System

The Tradewinds economy features a robust, dynamic trading simulation where players interact with non-player character (NPC) guilds. These guilds maintain "Trader Positions" at specific ports, simulating localized supply and demand.

This document breaks down the pricing math, taxes, execution flow, and the continuous daily/quarterly market simulations.

## 1. Core Mechanics & Pricing

NPC Traders hold "Positions" for specific goods at specific ports. A position tracks:
*   **Stock:** Current inventory of the good.
*   **Target Stock:** The equilibrium inventory level.
*   **Supply/Demand Rates:** How fast the NPC naturally produces or consumes the good.
*   **Elasticity:** How aggressively the price responds to deviations from the target stock.
*   **Spread:** The NPC's profit margin (the difference between buying and selling prices).

### How Prices are Calculated
When a player requests a quote, the system processes the price through multiple stages:

1.  **Economic Shocks:** Active global or localized shocks (e.g., famine, war) apply modifiers to supply, demand, base price, and volatility.
2.  **Base Market Price:** Calculates how scarce the item is based on elasticity.
    `Price Ratio = Target Stock / (Current Stock + 1)`
    `Market Price = (Base Price * Price Modifier) * (Price Ratio ^ Elasticity)`
3.  **Volatility Jitter:** Random noise is injected into the price (+/- 2% multiplied by the shock volatility modifier) to ensure the market feels organic.
4.  **The Spread (Ask vs. Bid):** 
    *   **Ask (Player Buys):** `Market Price * (1 + Spread)`
    *   **Bid (Player Sells):** `Market Price * (1 - Spread)`
5.  **Volume Slippage:** The more volume a player trades, the worse their average execution price. 
    *   *Buying:* `Final Ask = Ask + (Ask * Quantity) / (4 * (Current Stock + 1))`
    *   *Selling:* `Final Bid = (Bid * 4 * (Current Stock + 1)) / (4 * (Current Stock + 1) + Quantity)`
6.  **Hard Clamping:** Final execution prices are strictly clamped between `10%` and `1000%` of the item's raw base price to prevent runaway hyperinflation or zero-value exploits.

## 2. Trade Execution & Tax

Trades can be executed via a pre-signed 120-second **Quote Token** or as an **Immediate Market Order**. 

1.  **Validation:** The transaction guarantees the player's company is active, their target ships/warehouses are physically located at the port, and the NPC has sufficient stock (if the player is buying).
2.  **Financials & Ledger:** The company's treasury is updated via an atomic DB transaction (`lock("FOR UPDATE")`). This creates a `Ledger` entry categorized as `:npc_trade` and references the market.
3.  **Taxes:** 
    *   **Buying from NPCs** triggers the port's tax rate (`tax_rate_bps` where 100 bps = 1%). The tax is pulled as a secondary deduction on the company ledger.
    *   **Selling to NPCs** is completely tax-free to encourage supply.
4.  **Logistics:** The goods are formally injected or extracted from the specified ships/warehouses.
5.  **Trade Log:** The system records a `TradeLog` connecting the company (as buyer or seller) to the `system_npc_id`. This log is critical for tracking macro-economic flow.

## 3. The Market Simulation (Jobs)

The economy is not static; it breathes via Oban background workers.

### Daily: `TraderSimulationJob`
Runs every 1 "Game Day" (4,320 real seconds / 1.2 hours).
*   **Flow Tracking:** Analyzes the `trade_log` over the last quarter to determine net player trade flow. 
*   **Spread Adjustment:** 
    *   If there is high absolute trade flow, the NPC *increases* its spread (up to 15%) to capitalize on high demand/volatility.
    *   If trade flow is stagnant, the NPC *decays* its spread (down to 3%) to encourage player interactions.
*   **Stock Drift & Consumption:** The NPC naturally creates and consumes items toward their target stock.
    *   `Drift = Floor(Target Stock * Supply Rate * Modifiers)`
    *   `Consumption = Floor(Current Stock * Demand Rate * Modifiers)`
    *   `New Stock = Current Stock + Drift - Consumption` (Clamped at a maximum of `Target Stock * 5`).

### Quarterly: `TraderQuarterlyJob`
Runs every 1 "Game Quarter" (51,840 real seconds / 14.4 hours).
*   Resets the accrued `quarterly_profit` on all positions back to `0`, clearing seasonal accounting ledgers.

---

## 4. Explicit Examples

Let's look at a few mathematical examples using two fictional ports (`Port Royal`, `Tortuga`) and four fictional goods (`Grain`, `Wood`, `Iron`, `Rum`).

### Example 1: Player Buys Bulk Grain (Port Royal)
*   **Environment:** Port Royal (Tax: 5%). Grain Base Price: 100.
*   **NPC Position:** Stock: 1000, Target: 1000, Elasticity: 1.0, Spread: 5%.
*   **Order:** Player BUYS 100 Grain.

*Math Breakdown:*
*   **Market Price:** Stock equals Target, so ratio is ~1.0. Market Price = `100`.
*   **Base Ask:** `100 * 1.05` = `105`.
*   **Slippage (Buying):** Buying 10% of the NPC's stock creates slippage. `105 + (105 * 100) / (4 * 1001)` = `105 + 2.62` = `107` per unit.
*   **Total Item Cost:** `107 * 100` = `10,700`.
*   **Taxes (5%):** `10,700 * 0.05` = `535`.
*   **Net Company Deduction:** `11,235`.
*   *NPC Stock drops to 900. NPC logs virtual profit.*

### Example 2: Player Sells Scarce Wood (Tortuga)
*   **Environment:** Tortuga (Tax: 10% - Ignored for selling). Wood Base Price: 200.
*   **NPC Position:** Stock: 500, Target: 1000, Elasticity: 0.5, Spread: 5%.
*   **Order:** Player SELLS 200 Wood.

*Math Breakdown:*
*   **Market Price:** Scarce! `200 * ((1000 / 501) ^ 0.5)` = `200 * 1.41` = `282`.
*   **Base Bid:** `282 * 0.95` = `267`.
*   **Slippage (Selling):** High volume dump lowers the return. `(267 * 4 * 501) / (4 * 501 + 200)` = `535,068 / 2204` = `242` per unit.
*   **Total Revenue:** `242 * 200` = `48,400`.
*   **Taxes:** `0`.
*   **Net Company Addition:** `48,400`.
*   *NPC Stock increases to 700. NPC logs virtual profit.*

### Example 3: Daily Simulation of Iron & Rum
*   **Iron (High Volatility):** Players bought massive amounts of Iron yesterday. The daily job detects a high negative flow. To capitalize, the NPC raises its spread from `5%` to `9%` (`min(0.15, 0.05 + 0.0004 * Volume)`).
*   **Rum (Stagnant & Overstocked):** No players bought Rum. Spread decays down by `0.1%`. Additionally, stock drift applies: The NPC has 1500 stock but a target of 1000. `Consumption` outpaces `Drift`, so the `New Stock` naturally drops by ~5 units down to 1495, slowly correcting the market.
