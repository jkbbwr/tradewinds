from __future__ import annotations

from collections.abc import Mapping
from typing import Any, TypeVar

from attrs import define as _attrs_define
from attrs import field as _attrs_field

T = TypeVar("T", bound="CompanyEconomyResponseData")


@_attrs_define
class CompanyEconomyResponseData:
    """
    Attributes:
        reputation (int):
        ship_upkeep (int):
        total_upkeep (int):
        treasury (int):
        warehouse_upkeep (int):
    """

    reputation: int
    ship_upkeep: int
    total_upkeep: int
    treasury: int
    warehouse_upkeep: int
    additional_properties: dict[str, Any] = _attrs_field(init=False, factory=dict)

    def to_dict(self) -> dict[str, Any]:
        reputation = self.reputation

        ship_upkeep = self.ship_upkeep

        total_upkeep = self.total_upkeep

        treasury = self.treasury

        warehouse_upkeep = self.warehouse_upkeep

        field_dict: dict[str, Any] = {}
        field_dict.update(self.additional_properties)
        field_dict.update(
            {
                "reputation": reputation,
                "ship_upkeep": ship_upkeep,
                "total_upkeep": total_upkeep,
                "treasury": treasury,
                "warehouse_upkeep": warehouse_upkeep,
            }
        )

        return field_dict

    @classmethod
    def from_dict(cls: type[T], src_dict: Mapping[str, Any]) -> T:
        d = dict(src_dict)
        reputation = d.pop("reputation")

        ship_upkeep = d.pop("ship_upkeep")

        total_upkeep = d.pop("total_upkeep")

        treasury = d.pop("treasury")

        warehouse_upkeep = d.pop("warehouse_upkeep")

        company_economy_response_data = cls(
            reputation=reputation,
            ship_upkeep=ship_upkeep,
            total_upkeep=total_upkeep,
            treasury=treasury,
            warehouse_upkeep=warehouse_upkeep,
        )

        company_economy_response_data.additional_properties = d
        return company_economy_response_data

    @property
    def additional_keys(self) -> list[str]:
        return list(self.additional_properties.keys())

    def __getitem__(self, key: str) -> Any:
        return self.additional_properties[key]

    def __setitem__(self, key: str, value: Any) -> None:
        self.additional_properties[key] = value

    def __delitem__(self, key: str) -> None:
        del self.additional_properties[key]

    def __contains__(self, key: str) -> bool:
        return key in self.additional_properties
