#
# Mathematical Formulas for Trading Simulation in Python
#

import math

# --- 1. Variable Definitions & Initial State ---
# These are the initial conditions for our simulation.
# You can change these values to see how they affect the outcomes.

# Time step (not directly used in calculations but good for context)
t = 0

# Merchant's current stock of the good
S_t = 50.0

# Merchant's weighted average cost for the goods they hold
C_avg_t = 100.0

# The ideal amount of stock the merchant wants to have
S_ideal = 100.0

# Target profit margin (1.2 means a 20% markup)
M_target = 1.2

# Maximum spread between buy and sell price (0.4 means 40%)
# This prevents the buy price from dropping to zero.
beta_max = 0.4

# Price elasticity, how much price changes with supply/demand.
# Higher values mean price is more sensitive to changes in stock.
epsilon = 0.5

# Liquidity factor, how much the price is impacted by a large trade.
# Higher values mean a larger quantity trade will move the price more.
lambda_factor = 0.8

# Long-term regional average cost for the good.
# The merchant's cost basis will slowly move towards this value.
C_regional = 95.0

# Passive consumption rate per market tick (e.g., spoilage, local use)
R_consume = 0.5

# Rate at which the merchant's cost memory reverts to the regional average
# This simulates forgetting old purchase prices and adjusting to the market.
R_forget = 0.05


# --- 2. Spot Price Calculation Functions ---

def calculate_sell_price(C_avg_t, M_target, S_ideal, S_t, epsilon):
    """
    Calculates the merchant's spot SELL price.
    The price increases as the merchant's stock (S_t) decreases relative to their ideal stock (S_ideal).
    """
    # We add 1 to S_t to avoid division by zero if stock is empty.
    base_price = C_avg_t * M_target
    supply_factor = (S_ideal / (S_t + 1)) ** epsilon
    return base_price * supply_factor

def calculate_buy_price(P_sell_t, beta_max, S_ideal, S_t):
    """
    Calculates the merchant's spot BUY price.
    It's based on the sell price but discounted. The discount is larger when the merchant
    has a lot of stock, discouraging them from buying more.
    """
    # The spread factor scales from 0 to beta_max as stock (S_t) goes from 0 to ideal (S_ideal).
    # min() ensures the ratio doesn't exceed 1 if stock is over the ideal level.
    spread_factor = beta_max * min(S_t / S_ideal, 1)
    return P_sell_t * (1 - spread_factor)


# --- 3. Transaction Quote (Price Impact) Functions ---

def get_player_buy_quote(P_sell_t, S_t, Q, lambda_factor):
    """
    Calculates the average price per unit for a player BUYING Q items.
    The price increases with the quantity (Q) being bought due to price impact.
    """
    price_impact_factor = (1 + Q / (S_t + Q)) ** lambda_factor
    P_avg_buy = P_sell_t * price_impact_factor
    return P_avg_buy, P_avg_buy * Q # Returns average price and total value

def get_player_sell_quote(P_buy_t, S_ideal, Q, lambda_factor):
    """
    Calculates the average price per unit for a player SELLING Q items.
    The price the merchant is willing to pay decreases as the quantity (Q) increases.
    """
    price_impact_factor = (1 - Q / (S_ideal + Q)) ** lambda_factor
    P_avg_sell = P_buy_t * price_impact_factor
    return P_avg_sell, P_avg_sell * Q # Returns average price and total value


# --- 4. Trade Execution (State Update) Functions ---

def execute_merchant_buy(S_t, C_avg_t, Q, P_avg_sell):
    """
    Updates the merchant's state after they BUY from a player.
    Returns the new stock and new average cost.
    """
    new_S_t = S_t + Q
    # The new average cost is a weighted average of the old stock and the newly purchased stock.
    new_C_avg_t = ((C_avg_t * S_t) + (P_avg_sell * Q)) / (S_t + Q)
    return new_S_t, new_C_avg_t

def execute_merchant_sell(S_t, Q):
    """
    Updates the merchant's state after they SELL to a player.
    Returns the new stock. The average cost does not change when selling.
    """
    new_S_t = S_t - Q
    return new_S_t


# --- 5. Market Tick (State Update) Function ---

def market_tick(S_t, C_avg_t, R_consume, R_forget, C_regional):
    """
    Simulates the passage of one time step for the merchant.
    Applies passive consumption and cost basis mean reversion.
    Returns the new stock and new average cost.
    """
    # Passive consumption (e.g., goods spoiling or being used)
    S_t_after_consumption = max(0, S_t - R_consume)

    # Cost basis mean reversion (merchant's memory of cost drifts towards regional average)
    C_avg_t_after_reversion = (C_avg_t * (1 - R_forget)) + (C_regional * R_forget)

    return S_t_after_consumption, C_avg_t_after_reversion


# --- Example Simulation ---
if __name__ == '__main__':
    print("--- Initial Merchant State ---")
    print(f"Stock (S_t): {S_t:.2f}")
    print(f"Average Cost (C_avg_t): {C_avg_t:.2f}\n")

    # 1. Calculate current spot prices
    P_sell_t = calculate_sell_price(C_avg_t, M_target, S_ideal, S_t, epsilon)
    P_buy_t = calculate_buy_price(P_sell_t, beta_max, S_ideal, S_t)
    print("--- Current Spot Prices ---")
    print(f"Merchant Sell Price (P_sell_t): {P_sell_t:.2f}")
    print(f"Merchant Buy Price (P_buy_t): {P_buy_t:.2f}\n")

    # 2. A player wants to sell 20 items to the merchant
    Q_player_sell = 20
    P_avg_sell, V_sell = get_player_sell_quote(P_buy_t, S_ideal, Q_player_sell, lambda_factor)
    print(f"--- Player Selling {Q_player_sell} Items ---")
    print(f"Average price per item: {P_avg_sell:.2f}")
    print(f"Total value for player: {V_sell:.2f}\n")

    # 3. Execute the trade
    S_t, C_avg_t = execute_merchant_buy(S_t, C_avg_t, Q_player_sell, P_avg_sell)
    print("--- Merchant State After Buying ---")
    print(f"New Stock (S_t): {S_t:.2f}")
    print(f"New Average Cost (C_avg_t): {C_avg_t:.2f}\n")

    # 4. A player wants to buy 15 items from the merchant
    Q_player_buy = 15
    # Recalculate prices based on the new state
    P_sell_t = calculate_sell_price(C_avg_t, M_target, S_ideal, S_t, epsilon)
    P_avg_buy, V_buy = get_player_buy_quote(P_sell_t, S_t, Q_player_buy, lambda_factor)
    print(f"--- Player Buying {Q_player_buy} Items ---")
    print(f"Average price per item: {P_avg_buy:.2f}")
    print(f"Total cost for player: {V_buy:.2f}\n")

    # 5. Execute the trade
    S_t = execute_merchant_sell(S_t, Q_player_buy)
    print("--- Merchant State After Selling ---")
    print(f"New Stock (S_t): {S_t:.2f}")
    print(f"Average Cost (C_avg_t): {C_avg_t:.2f} (unchanged)\n")

    # 6. A market tick passes
    S_t, C_avg_t = market_tick(S_t, C_avg_t, R_consume, R_forget, C_regional)
    print("--- Merchant State After Market Tick ---")
    print(f"New Stock (S_t): {S_t:.2f}")
    print(f"New Average Cost (C_avg_t): {C_avg_t:.2f}\n")
