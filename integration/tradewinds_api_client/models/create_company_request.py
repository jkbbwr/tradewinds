from __future__ import annotations

from collections.abc import Mapping
from typing import Any, TypeVar
from uuid import UUID

from attrs import define as _attrs_define
from attrs import field as _attrs_field

T = TypeVar("T", bound="CreateCompanyRequest")


@_attrs_define
class CreateCompanyRequest:
    """Request body for creating a new company.

    Attributes:
        home_port_id (UUID):
        name (str):
        ticker (str):
    """

    home_port_id: UUID
    name: str
    ticker: str
    additional_properties: dict[str, Any] = _attrs_field(init=False, factory=dict)

    def to_dict(self) -> dict[str, Any]:
        home_port_id = str(self.home_port_id)

        name = self.name

        ticker = self.ticker

        field_dict: dict[str, Any] = {}
        field_dict.update(self.additional_properties)
        field_dict.update(
            {
                "home_port_id": home_port_id,
                "name": name,
                "ticker": ticker,
            }
        )

        return field_dict

    @classmethod
    def from_dict(cls: type[T], src_dict: Mapping[str, Any]) -> T:
        d = dict(src_dict)
        home_port_id = UUID(d.pop("home_port_id"))

        name = d.pop("name")

        ticker = d.pop("ticker")

        create_company_request = cls(
            home_port_id=home_port_id,
            name=name,
            ticker=ticker,
        )

        create_company_request.additional_properties = d
        return create_company_request

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
