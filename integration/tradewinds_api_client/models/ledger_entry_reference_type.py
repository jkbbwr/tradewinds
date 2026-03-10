from enum import Enum


class LedgerEntryReferenceType(str, Enum):
    MARKET = "market"
    ORDER = "order"
    SHIP = "ship"
    SYSTEM = "system"
    WAREHOUSE = "warehouse"

    def __str__(self) -> str:
        return str(self.value)
