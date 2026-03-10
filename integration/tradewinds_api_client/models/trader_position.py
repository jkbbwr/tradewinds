from __future__ import annotations

import datetime
from collections.abc import Mapping
from typing import Any, TypeVar
from uuid import UUID

from attrs import define as _attrs_define
from attrs import field as _attrs_field
from dateutil.parser import isoparse

T = TypeVar("T", bound="TraderPosition")


@_attrs_define
class TraderPosition:
    """An NPC trader's position for a specific good at a port.

    Attributes:
        good_id (UUID):
        id (UUID):
        inserted_at (datetime.datetime):
        port_id (UUID):
        stock_bounds (str):
        trader_id (UUID):
        updated_at (datetime.datetime):
    """

    good_id: UUID
    id: UUID
    inserted_at: datetime.datetime
    port_id: UUID
    stock_bounds: str
    trader_id: UUID
    updated_at: datetime.datetime
    additional_properties: dict[str, Any] = _attrs_field(init=False, factory=dict)

    def to_dict(self) -> dict[str, Any]:
        good_id = str(self.good_id)

        id = str(self.id)

        inserted_at = self.inserted_at.isoformat()

        port_id = str(self.port_id)

        stock_bounds = self.stock_bounds

        trader_id = str(self.trader_id)

        updated_at = self.updated_at.isoformat()

        field_dict: dict[str, Any] = {}
        field_dict.update(self.additional_properties)
        field_dict.update(
            {
                "good_id": good_id,
                "id": id,
                "inserted_at": inserted_at,
                "port_id": port_id,
                "stock_bounds": stock_bounds,
                "trader_id": trader_id,
                "updated_at": updated_at,
            }
        )

        return field_dict

    @classmethod
    def from_dict(cls: type[T], src_dict: Mapping[str, Any]) -> T:
        d = dict(src_dict)
        good_id = UUID(d.pop("good_id"))

        id = UUID(d.pop("id"))

        inserted_at = isoparse(d.pop("inserted_at"))

        port_id = UUID(d.pop("port_id"))

        stock_bounds = d.pop("stock_bounds")

        trader_id = UUID(d.pop("trader_id"))

        updated_at = isoparse(d.pop("updated_at"))

        trader_position = cls(
            good_id=good_id,
            id=id,
            inserted_at=inserted_at,
            port_id=port_id,
            stock_bounds=stock_bounds,
            trader_id=trader_id,
            updated_at=updated_at,
        )

        trader_position.additional_properties = d
        return trader_position

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
