This is the final **Trade Context Specification**, integrating the core NPC simulation, player-driven trading mechanics, and the "Fog of War" volatility to ensure a long-term, competitive meta.

---

## 1. Core Data Structures (The Physical Layer)

### **NPC Market Logic** (`trader_position`)

Each row represents one `good` at one `port` managed by a specific `trader`.

- **Stock ($S_t$):** Current physical barrels.
- **Target Stock ($S^*$):** The ideal equilibrium the NPC wants to maintain.
- **Supply Rate ($\alpha$):** Daily fractional recovery (e.g., `0.12` = 12% of deficit refilled/day).
- **Demand Rate ($\beta$):** Daily fractional consumption (e.g., `0.04` = 4% of stock consumed/day).
- **Elasticity ($E$):** Price sensitivity (Standard: `0.12`). Higher = more volatile prices.

---

## 2. Daily Simulation Math (The "Rubber Band")

_Frequency: Once every 24 ticks (1 game day)._

### **A. Stock Drift**

NPCs adjust stock toward the target. If empty, they "produce" more; if overfull, they "clearance" stock.

```text
drift = floor((target_stock - current_stock) * supply_rate)
consumption = floor(current_stock * demand_rate)

new_stock = clamp(current_stock + drift - consumption, 0, target_stock * 5)
```

### **B. Base Market Price ($P_{market}$)**

The "Fair Value" before markups, driven by scarcity.

```text
price_ratio = target_stock / (current_stock + 1)
market_price = base_price * (price_ratio ^ elasticity)
```

### **C. Volatility Jitter (The "Noise")**

Injects $ \pm 3\% $ random noise to hide the pure math from players.

```text
noise = 1.0 + random(-0.03, +0.03)
final_base_price = round(market_price * noise)
```

---

## 3. Player Interaction Math (Instant Trade)

### **A. The Spread (NPC Profit)**

The trader always buys low and sells high.

- **Ask (Player Buys):** `quote_price = floor(final_base_price * (1 + spread))`
- **Bid (Player Sells):** `quote_price = floor(final_base_price * (1 - spread))`

### **B. Price Slippage ($Impact$)**

Prevents one player from "wiping" the market at a flat rate. Larger orders move the price against the player.

```text
impact_factor = 1 + (order_qty / (current_stock + 1))
final_unit_price = floor(quote_price * impact_factor)
```

---

## 4. Operational Logic & Rules

### **The "Fog of War" (UI/UX)**

- **Hidden:** `target_stock`, `supply_rate`, `demand_rate`.
- **Obfuscated:** Exact `stock` count.
- **Display:** Use buckets: "Scarce" (<25%), "Common" (25-75%), "Abundant" (>75%).
- **Skill:** Players must watch the **Price Trend** over several ticks to guess if a port is refilling or being drained by rivals.

### **Atomic Trade Execution (Transaction)**

1. **Validation:** Check `player_credits` and `current_stock`.
2. **Execution:**
   - Deduct/Credit `player_credits`.
   - Update `trader_position.stock`.
   - Update `trader_position.quarterly_profit` (Value = `qty * final_base_price * spread`).
   - Transfer `ship_cargo`.
3. **Partial Fills:** Allowed if stock is less than `order_qty`. Honor the `quote_price` for whatever is available.

---

## 5. Economic Safety Rails (Clamps)

Prevents the economy from hitting $0$ or infinity during extreme player wars.

| Boundary              | Value                 | Purpose                              |
| :-------------------- | :-------------------- | :----------------------------------- |
| **Price Floor**       | `base_price * 0.1`    | Prevents free items.                 |
| **Price Ceiling**     | `base_price * 10.0`   | Prevents infinite inflation.         |
| **Stock Ceiling**     | `target_stock * 5`    | NPC eventually stops buying "trash." |
| **Transaction Limit** | 100% of current stock | Cannot buy/sell air.                 |

---
