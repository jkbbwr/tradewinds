from __future__ import annotations

import datetime
from collections.abc import Mapping
from typing import Any, TypeVar
from uuid import UUID

from attrs import define as _attrs_define
from attrs import field as _attrs_field
from dateutil.parser import isoparse

T = TypeVar("T", bound="Shipyard")


@_attrs_define
class Shipyard:
    """A shipyard at a specific port.

    Attributes:
        id (UUID):
        inserted_at (datetime.datetime):
        port_id (UUID):
        updated_at (datetime.datetime):
    """

    id: UUID
    inserted_at: datetime.datetime
    port_id: UUID
    updated_at: datetime.datetime
    additional_properties: dict[str, Any] = _attrs_field(init=False, factory=dict)

    def to_dict(self) -> dict[str, Any]:
        id = str(self.id)

        inserted_at = self.inserted_at.isoformat()

        port_id = str(self.port_id)

        updated_at = self.updated_at.isoformat()

        field_dict: dict[str, Any] = {}
        field_dict.update(self.additional_properties)
        field_dict.update(
            {
                "id": id,
                "inserted_at": inserted_at,
                "port_id": port_id,
                "updated_at": updated_at,
            }
        )

        return field_dict

    @classmethod
    def from_dict(cls: type[T], src_dict: Mapping[str, Any]) -> T:
        d = dict(src_dict)
        id = UUID(d.pop("id"))

        inserted_at = isoparse(d.pop("inserted_at"))

        port_id = UUID(d.pop("port_id"))

        updated_at = isoparse(d.pop("updated_at"))

        shipyard = cls(
            id=id,
            inserted_at=inserted_at,
            port_id=port_id,
            updated_at=updated_at,
        )

        shipyard.additional_properties = d
        return shipyard

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
