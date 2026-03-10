from __future__ import annotations

import datetime
from collections.abc import Mapping
from typing import Any, TypeVar
from uuid import UUID

from attrs import define as _attrs_define
from attrs import field as _attrs_field
from dateutil.parser import isoparse

from ..types import UNSET, Unset

T = TypeVar("T", bound="ShipType")


@_attrs_define
class ShipType:
    """A class of ship with its static stats.

    Attributes:
        base_price (int):
        capacity (int):
        description (str):
        id (UUID):
        inserted_at (datetime.datetime):
        name (str):
        speed (int):
        updated_at (datetime.datetime):
        upkeep (int):
        passengers (int | Unset):
    """

    base_price: int
    capacity: int
    description: str
    id: UUID
    inserted_at: datetime.datetime
    name: str
    speed: int
    updated_at: datetime.datetime
    upkeep: int
    passengers: int | Unset = UNSET
    additional_properties: dict[str, Any] = _attrs_field(init=False, factory=dict)

    def to_dict(self) -> dict[str, Any]:
        base_price = self.base_price

        capacity = self.capacity

        description = self.description

        id = str(self.id)

        inserted_at = self.inserted_at.isoformat()

        name = self.name

        speed = self.speed

        updated_at = self.updated_at.isoformat()

        upkeep = self.upkeep

        passengers = self.passengers

        field_dict: dict[str, Any] = {}
        field_dict.update(self.additional_properties)
        field_dict.update(
            {
                "base_price": base_price,
                "capacity": capacity,
                "description": description,
                "id": id,
                "inserted_at": inserted_at,
                "name": name,
                "speed": speed,
                "updated_at": updated_at,
                "upkeep": upkeep,
            }
        )
        if passengers is not UNSET:
            field_dict["passengers"] = passengers

        return field_dict

    @classmethod
    def from_dict(cls: type[T], src_dict: Mapping[str, Any]) -> T:
        d = dict(src_dict)
        base_price = d.pop("base_price")

        capacity = d.pop("capacity")

        description = d.pop("description")

        id = UUID(d.pop("id"))

        inserted_at = isoparse(d.pop("inserted_at"))

        name = d.pop("name")

        speed = d.pop("speed")

        updated_at = isoparse(d.pop("updated_at"))

        upkeep = d.pop("upkeep")

        passengers = d.pop("passengers", UNSET)

        ship_type = cls(
            base_price=base_price,
            capacity=capacity,
            description=description,
            id=id,
            inserted_at=inserted_at,
            name=name,
            speed=speed,
            updated_at=updated_at,
            upkeep=upkeep,
            passengers=passengers,
        )

        ship_type.additional_properties = d
        return ship_type

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
