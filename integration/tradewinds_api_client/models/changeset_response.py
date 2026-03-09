from __future__ import annotations

from collections.abc import Mapping
from typing import TYPE_CHECKING, Any, TypeVar

from attrs import define as _attrs_define
from attrs import field as _attrs_field

if TYPE_CHECKING:
    from ..models.changeset_response_errors import ChangesetResponseErrors


T = TypeVar("T", bound="ChangesetResponse")


@_attrs_define
class ChangesetResponse:
    """Response schema for validation errors (422 Unprocessable Entity)

    Example:
        {'errors': {'email': ['has invalid format', 'has already been taken'], 'password': ['should be at least 8
            character(s)']}}

    Attributes:
        errors (ChangesetResponseErrors): A map of field names to lists of error messages
    """

    errors: ChangesetResponseErrors
    additional_properties: dict[str, Any] = _attrs_field(init=False, factory=dict)

    def to_dict(self) -> dict[str, Any]:
        errors = self.errors.to_dict()

        field_dict: dict[str, Any] = {}
        field_dict.update(self.additional_properties)
        field_dict.update(
            {
                "errors": errors,
            }
        )

        return field_dict

    @classmethod
    def from_dict(cls: type[T], src_dict: Mapping[str, Any]) -> T:
        from ..models.changeset_response_errors import ChangesetResponseErrors

        d = dict(src_dict)
        errors = ChangesetResponseErrors.from_dict(d.pop("errors"))

        changeset_response = cls(
            errors=errors,
        )

        changeset_response.additional_properties = d
        return changeset_response

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
