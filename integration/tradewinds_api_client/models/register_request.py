from __future__ import annotations

from collections.abc import Mapping
from typing import Any, TypeVar, cast

from attrs import define as _attrs_define
from attrs import field as _attrs_field

from ..types import UNSET, Unset

T = TypeVar("T", bound="RegisterRequest")


@_attrs_define
class RegisterRequest:
    """Request schema for player registration

    Example:
        {'discord_id': '1234567890', 'email': 'kibb@example.com', 'name': 'Kibb', 'password': 'password123'}

    Attributes:
        email (str):
        name (str):
        password (str):
        discord_id (None | str | Unset):
    """

    email: str
    name: str
    password: str
    discord_id: None | str | Unset = UNSET
    additional_properties: dict[str, Any] = _attrs_field(init=False, factory=dict)

    def to_dict(self) -> dict[str, Any]:
        email = self.email

        name = self.name

        password = self.password

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
                "name": name,
                "password": password,
            }
        )
        if discord_id is not UNSET:
            field_dict["discord_id"] = discord_id

        return field_dict

    @classmethod
    def from_dict(cls: type[T], src_dict: Mapping[str, Any]) -> T:
        d = dict(src_dict)
        email = d.pop("email")

        name = d.pop("name")

        password = d.pop("password")

        def _parse_discord_id(data: object) -> None | str | Unset:
            if data is None:
                return data
            if isinstance(data, Unset):
                return data
            return cast(None | str | Unset, data)

        discord_id = _parse_discord_id(d.pop("discord_id", UNSET))

        register_request = cls(
            email=email,
            name=name,
            password=password,
            discord_id=discord_id,
        )

        register_request.additional_properties = d
        return register_request

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
