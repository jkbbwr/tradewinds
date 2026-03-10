from enum import Enum


class LedgerEntryReason(str, Enum):
    BAILOUT = "bailout"
    INITIAL_DEPOSIT = "initial_deposit"
    MARKET_LISTING_FEE = "market_listing_fee"
    MARKET_PENALTY_FINE = "market_penalty_fine"
    MARKET_TRADE = "market_trade"
    NPC_TRADE = "npc_trade"
    SHIP_PURCHASE = "ship_purchase"
    SHIP_UPKEEP = "ship_upkeep"
    TAX = "tax"
    TRANSFER = "transfer"
    WAREHOUSE_UPGRADE = "warehouse_upgrade"
    WAREHOUSE_UPKEEP = "warehouse_upkeep"

    def __str__(self) -> str:
        return str(self.value)
