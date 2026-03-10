# Economic Shocks

Economic Shocks are temporary or permanent global or local events that modify the supply, demand, price, and volatility of goods in the Tradewinds world.

## Data Structure

Each shock is defined by the following values:

### Metadata & Status
- **Name**: A short, descriptive name for the shock (e.g., "Great Famine", "Gold Rush").
- **Description**: A longer text explaining the lore or reason for the shock.
- **Status**: The current state of the shock:
  - `pending`: Scheduled to start in the future.
  - `active`: Currently affecting the economy.
  - `paused`: Temporarily disabled (does not affect calculations).
  - `expired`: Has reached its `end_time` and is no longer active.

### Timing
- **Start Time**: The timestamp when the shock transitions from `pending` to `active`.
- **End Time**: The timestamp when the shock transitions from `active` to `expired`. If `null`, the shock is permanent until manually changed or ended.

### Scope
Shocks can be scoped at different levels:
- **Global**: If both `port_id` and `good_id` are `null`, the shock affects every good at every port in the world.
- **Port-Wide**: If `port_id` is set but `good_id` is `null`, the shock affects all goods traded at that specific port.
- **Good-Specific**: If `good_id` is set, the shock affects that specific good. If `port_id` is also set, it only affects that good at that specific port.

### Modifiers (Basis Points)
All modifiers are stored as integers in **Basis Points (BPS)**, where `10,000` represents a `1.0x` multiplier (no change).
- `5,000` = 0.5x (50% reduction)
- `10,000` = 1.0x (No change)
- `20,000` = 2.0x (100% increase)

#### 1. Price Modifier (`price_modifier`)
Directly multiplies the **base price** of a good.
- **Effect**: Increases or decreases the starting point for market price calculations.
- **Usage**: Used in `Tradewinds.Trade.generate_quote/5` and `execute_immediate/5`.

#### 2. Volatility Modifier (`volatility_modifier`)
Multiplies the random "noise" applied to market prices.
- **Standard Noise**: The system applies a baseline jitter of +/- 3% to every price quote.
- **Effect**: A volatility modifier of `20,000` (2.0x) would double that jitter to +/- 6%.
- **Usage**: Applied in `Tradewinds.Trade.apply_volatility_jitter/2`.

#### 3. Demand Modifier (`demand_modifier`)
Multiplies the **demand rate** of a good during the daily simulation.
- **Effect**: High demand (e.g., 2.0x) causes the NPC trader's stock to be consumed twice as fast.
- **Usage**: Used in `Tradewinds.Trade.simulate_daily_tick/5` during the daily trader simulation.

#### 4. Supply Modifier (`supply_modifier`)
Multiplies the **supply rate** (drift) of a good during the daily simulation.
- **Effect**: High supply (e.g., 2.0x) causes the NPC trader's stock to recover toward its target equilibrium twice as fast. Low supply (e.g., 0.1x) can cause a port to remain "sold out" for much longer.
- **Usage**: Used in `Tradewinds.Trade.simulate_daily_tick/5` during the daily trader simulation.

## Aggregation Logic
If multiple shocks overlap (e.g., a Global Price Shock and a Local Port Price Shock), the modifiers are **multiplied together**.

**Example:**
- Global Shock: `price_modifier = 1.2x`
- Local Shock: `price_modifier = 1.5x`
- **Resulting Multiplier**: `1.2 * 1.5 = 1.8x`

This calculation is handled by `Tradewinds.Economy.get_active_modifiers/3`.
