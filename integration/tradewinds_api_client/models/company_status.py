from enum import Enum


class CompanyStatus(str, Enum):
    ACTIVE = "active"
    BANKRUPT = "bankrupt"

    def __str__(self) -> str:
        return str(self.value)
