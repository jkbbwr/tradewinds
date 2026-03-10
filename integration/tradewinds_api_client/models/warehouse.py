from __future__ import annotations

import datetime
from collections.abc import Mapping
from typing import Any, TypeVar
from uuid import UUID

from attrs import define as _attrs_define
from attrs import field as _attrs_field
from dateutil.parser import isoparse

T = TypeVar("T", bound="Warehouse")


@_attrs_define
class Warehouse:
    """A warehouse owned by a company.

    Attributes:
        capacity (int):
        company_id (UUID):
        id (UUID):
        inserted_at (datetime.datetime):
        level (int):
        port_id (UUID):
        updated_at (datetime.datetime):
    """

    capacity: int
    company_id: UUID
    id: UUID
    inserted_at: datetime.datetime
    level: int
    port_id: UUID
    updated_at: datetime.datetime
    additional_properties: dict[str, Any] = _attrs_field(init=False, factory=dict)

    def to_dict(self) -> dict[str, Any]:
        capacity = self.capacity

        company_id = str(self.company_id)

        id = str(self.id)

        inserted_at = self.inserted_at.isoformat()

        level = self.level

        port_id = str(self.port_id)

        updated_at = self.updated_at.isoformat()

        field_dict: dict[str, Any] = {}
        field_dict.update(self.additional_properties)
        field_dict.update(
            {
                "capacity": capacity,
                "company_id": company_id,
                "id": id,
                "inserted_at": inserted_at,
                "level": level,
                "port_id": port_id,
                "updated_at": updated_at,
            }
        )

        return field_dict

    @classmethod
    def from_dict(cls: type[T], src_dict: Mapping[str, Any]) -> T:
        d = dict(src_dict)
        capacity = d.pop("capacity")

        company_id = UUID(d.pop("company_id"))

        id = UUID(d.pop("id"))

        inserted_at = isoparse(d.pop("inserted_at"))

        level = d.pop("level")

        port_id = UUID(d.pop("port_id"))

        updated_at = isoparse(d.pop("updated_at"))

        warehouse = cls(
            capacity=capacity,
            company_id=company_id,
            id=id,
            inserted_at=inserted_at,
            level=level,
            port_id=port_id,
            updated_at=updated_at,
        )

        warehouse.additional_properties = d
        return warehouse

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
