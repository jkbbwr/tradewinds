from __future__ import annotations

import datetime
from collections.abc import Mapping
from typing import Any, TypeVar, cast

from attrs import define as _attrs_define
from attrs import field as _attrs_field
from dateutil.parser import isoparse

from ..types import UNSET, Unset

T = TypeVar("T", bound="Player")


@_attrs_define
class Player:
    """A player in the system

    Example:
        {'discord_id': '1234567890', 'email': 'kibb@example.com', 'enabled': True, 'id': 1, 'inserted_at':
            '2026-03-08T16:00:00Z', 'name': 'Kibb'}

    Attributes:
        email (str): The player's email
        enabled (bool): Whether the player account is enabled
        id (int): The player ID
        inserted_at (datetime.datetime): When the player was created
        name (str): The player's name
        discord_id (None | str | Unset): The player's Discord ID
    """

    email: str
    enabled: bool
    id: int
    inserted_at: datetime.datetime
    name: str
    discord_id: None | str | Unset = UNSET
    additional_properties: dict[str, Any] = _attrs_field(init=False, factory=dict)

    def to_dict(self) -> dict[str, Any]:
        email = self.email

        enabled = self.enabled

        id = self.id

        inserted_at = self.inserted_at.isoformat()

        name = self.name

        discord_id: None | str | Unset
        if isinstance(self.discord_id, Unset):
            discord_id = UNSET
        else:
            discord_id = self.discord_id

        field_dict: dict[str, Any] = {}
        field_dict.update(self.additional_properties)
        field_dict.update(
            {
                "email": email,
                "enabled": enabled,
                "id": id,
                "inserted_at": inserted_at,
                "name": name,
            }
        )
        if discord_id is not UNSET:
            field_dict["discord_id"] = discord_id

        return field_dict

    @classmethod
    def from_dict(cls: type[T], src_dict: Mapping[str, Any]) -> T:
        d = dict(src_dict)
        email = d.pop("email")

        enabled = d.pop("enabled")

        id = d.pop("id")

        inserted_at = isoparse(d.pop("inserted_at"))

        name = d.pop("name")

        def _parse_discord_id(data: object) -> None | str | Unset:
            if data is None:
                return data
            if isinstance(data, Unset):
                return data
            return cast(None | str | Unset, data)

        discord_id = _parse_discord_id(d.pop("discord_id", UNSET))

        player = cls(
            email=email,
            enabled=enabled,
            id=id,
            inserted_at=inserted_at,
            name=name,
            discord_id=discord_id,
        )

        player.additional_properties = d
        return player

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
