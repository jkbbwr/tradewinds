from __future__ import annotations

from collections.abc import Mapping
from typing import TYPE_CHECKING, Any, TypeVar

from attrs import define as _attrs_define
from attrs import field as _attrs_field

if TYPE_CHECKING:
    from ..models.trade_destination import TradeDestination


T = TypeVar("T", bound="ExecuteQuoteRequest")


@_attrs_define
class ExecuteQuoteRequest:
    """Request to execute a quote.

    Attributes:
        destinations (list[TradeDestination]):
        token (str):
    """

    destinations: list[TradeDestination]
    token: str
    additional_properties: dict[str, Any] = _attrs_field(init=False, factory=dict)

    def to_dict(self) -> dict[str, Any]:
        destinations = []
        for destinations_item_data in self.destinations:
            destinations_item = destinations_item_data.to_dict()
            destinations.append(destinations_item)

        token = self.token

        field_dict: dict[str, Any] = {}
        field_dict.update(self.additional_properties)
        field_dict.update(
            {
                "destinations": destinations,
                "token": token,
            }
        )

        return field_dict

    @classmethod
    def from_dict(cls: type[T], src_dict: Mapping[str, Any]) -> T:
        from ..models.trade_destination import TradeDestination

        d = dict(src_dict)
        destinations = []
        _destinations = d.pop("destinations")
        for destinations_item_data in _destinations:
            destinations_item = TradeDestination.from_dict(destinations_item_data)

            destinations.append(destinations_item)

        token = d.pop("token")

        execute_quote_request = cls(
            destinations=destinations,
            token=token,
        )

        execute_quote_request.additional_properties = d
        return execute_quote_request

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
