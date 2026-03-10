from __future__ import annotations

import datetime
from collections.abc import Mapping
from typing import Any, TypeVar
from uuid import UUID

from attrs import define as _attrs_define
from attrs import field as _attrs_field
from dateutil.parser import isoparse

T = TypeVar("T", bound="Good")


@_attrs_define
class Good:
    """A tradeable commodity.

    Attributes:
        category (str):
        description (str):
        id (UUID):
        inserted_at (datetime.datetime):
        name (str):
        updated_at (datetime.datetime):
    """

    category: str
    description: str
    id: UUID
    inserted_at: datetime.datetime
    name: str
    updated_at: datetime.datetime
    additional_properties: dict[str, Any] = _attrs_field(init=False, factory=dict)

    def to_dict(self) -> dict[str, Any]:
        category = self.category

        description = self.description

        id = str(self.id)

        inserted_at = self.inserted_at.isoformat()

        name = self.name

        updated_at = self.updated_at.isoformat()

        field_dict: dict[str, Any] = {}
        field_dict.update(self.additional_properties)
        field_dict.update(
            {
                "category": category,
                "description": description,
                "id": id,
                "inserted_at": inserted_at,
                "name": name,
                "updated_at": updated_at,
            }
        )

        return field_dict

    @classmethod
    def from_dict(cls: type[T], src_dict: Mapping[str, Any]) -> T:
        d = dict(src_dict)
        category = d.pop("category")

        description = d.pop("description")

        id = UUID(d.pop("id"))

        inserted_at = isoparse(d.pop("inserted_at"))

        name = d.pop("name")

        updated_at = isoparse(d.pop("updated_at"))

        good = cls(
            category=category,
            description=description,
            id=id,
            inserted_at=inserted_at,
            name=name,
            updated_at=updated_at,
        )

        good.additional_properties = d
        return good

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
