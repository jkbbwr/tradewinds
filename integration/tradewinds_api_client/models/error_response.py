from __future__ import annotations

from collections.abc import Mapping
from typing import TYPE_CHECKING, Any, TypeVar

from attrs import define as _attrs_define
from attrs import field as _attrs_field

if TYPE_CHECKING:
    from ..models.error_response_errors import ErrorResponseErrors


T = TypeVar("T", bound="ErrorResponse")


@_attrs_define
class ErrorResponse:
    """Response schema for standard errors (e.g., 401 Unauthorized)

    Example:
        {'errors': {'detail': 'Unauthorized'}}

    Attributes:
        errors (ErrorResponseErrors):
    """

    errors: ErrorResponseErrors
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
        from ..models.error_response_errors import ErrorResponseErrors

        d = dict(src_dict)
        errors = ErrorResponseErrors.from_dict(d.pop("errors"))

        error_response = cls(
            errors=errors,
        )

        error_response.additional_properties = d
        return error_response

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
