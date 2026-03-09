from __future__ import annotations

from collections.abc import Mapping
from typing import TYPE_CHECKING, Any, TypeVar

from attrs import define as _attrs_define
from attrs import field as _attrs_field

if TYPE_CHECKING:
    from ..models.player import Player


T = TypeVar("T", bound="RegisterResponse")


@_attrs_define
class RegisterResponse:
    """Response schema for successful registration

    Attributes:
        data (Player): A player in the system Example: {'discord_id': '1234567890', 'email': 'kibb@example.com',
            'enabled': True, 'id': 1, 'inserted_at': '2026-03-08T16:00:00Z', 'name': 'Kibb'}.
    """

    data: Player
    additional_properties: dict[str, Any] = _attrs_field(init=False, factory=dict)

    def to_dict(self) -> dict[str, Any]:
        data = self.data.to_dict()

        field_dict: dict[str, Any] = {}
        field_dict.update(self.additional_properties)
        field_dict.update(
            {
                "data": data,
            }
        )

        return field_dict

    @classmethod
    def from_dict(cls: type[T], src_dict: Mapping[str, Any]) -> T:
        from ..models.player import Player

        d = dict(src_dict)
        data = Player.from_dict(d.pop("data"))

        register_response = cls(
            data=data,
        )

        register_response.additional_properties = d
        return register_response

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
