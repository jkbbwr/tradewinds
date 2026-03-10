from enum import Enum


class ShipStatus(str, Enum):
    DOCKED = "docked"
    TRAVELING = "traveling"

    def __str__(self) -> str:
        return str(self.value)
