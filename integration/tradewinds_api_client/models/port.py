from __future__ import annotations

import datetime
from collections.abc import Mapping
from typing import Any, TypeVar
from uuid import UUID

from attrs import define as _attrs_define
from attrs import field as _attrs_field
from dateutil.parser import isoparse

T = TypeVar("T", bound="Port")


@_attrs_define
class Port:
    """A port location in the world.

    Attributes:
        country_id (UUID):
        id (UUID):
        inserted_at (datetime.datetime):
        is_hub (bool):
        name (str):
        shortcode (str):
        tax_rate_bps (int):
        updated_at (datetime.datetime):
    """

    country_id: UUID
    id: UUID
    inserted_at: datetime.datetime
    is_hub: bool
    name: str
    shortcode: str
    tax_rate_bps: int
    updated_at: datetime.datetime
    additional_properties: dict[str, Any] = _attrs_field(init=False, factory=dict)

    def to_dict(self) -> dict[str, Any]:
        country_id = str(self.country_id)

        id = str(self.id)

        inserted_at = self.inserted_at.isoformat()

        is_hub = self.is_hub

        name = self.name

        shortcode = self.shortcode

        tax_rate_bps = self.tax_rate_bps

        updated_at = self.updated_at.isoformat()

        field_dict: dict[str, Any] = {}
        field_dict.update(self.additional_properties)
        field_dict.update(
            {
                "country_id": country_id,
                "id": id,
                "inserted_at": inserted_at,
                "is_hub": is_hub,
                "name": name,
                "shortcode": shortcode,
                "tax_rate_bps": tax_rate_bps,
                "updated_at": updated_at,
            }
        )

        return field_dict

    @classmethod
    def from_dict(cls: type[T], src_dict: Mapping[str, Any]) -> T:
        d = dict(src_dict)
        country_id = UUID(d.pop("country_id"))

        id = UUID(d.pop("id"))

        inserted_at = isoparse(d.pop("inserted_at"))

        is_hub = d.pop("is_hub")

        name = d.pop("name")

        shortcode = d.pop("shortcode")

        tax_rate_bps = d.pop("tax_rate_bps")

        updated_at = isoparse(d.pop("updated_at"))

        port = cls(
            country_id=country_id,
            id=id,
            inserted_at=inserted_at,
            is_hub=is_hub,
            name=name,
            shortcode=shortcode,
            tax_rate_bps=tax_rate_bps,
            updated_at=updated_at,
        )

        port.additional_properties = d
        return port

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
