from enum import Enum


class OrderStatus(str, Enum):
    CANCELLED = "cancelled"
    EXPIRED = "expired"
    FILLED = "filled"
    OPEN = "open"

    def __str__(self) -> str:
        return str(self.value)
