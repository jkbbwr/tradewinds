from enum import Enum


class TradeDestinationType(str, Enum):
    SHIP = "ship"
    WAREHOUSE = "warehouse"

    def __str__(self) -> str:
        return str(self.value)
