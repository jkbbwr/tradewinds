from __future__ import annotations

from collections.abc import Mapping
from typing import Any, TypeVar
from uuid import UUID

from attrs import define as _attrs_define
from attrs import field as _attrs_field

from ..models.quote_request_action import QuoteRequestAction

T = TypeVar("T", bound="QuoteRequest")


@_attrs_define
class QuoteRequest:
    """Request to get a quote from a trader.

    Attributes:
        action (QuoteRequestAction):
        good_id (UUID):
        port_id (UUID):
        quantity (int):
    """

    action: QuoteRequestAction
    good_id: UUID
    port_id: UUID
    quantity: int
    additional_properties: dict[str, Any] = _attrs_field(init=False, factory=dict)

    def to_dict(self) -> dict[str, Any]:
        action = self.action.value

        good_id = str(self.good_id)

        port_id = str(self.port_id)

        quantity = self.quantity

        field_dict: dict[str, Any] = {}
        field_dict.update(self.additional_properties)
        field_dict.update(
            {
                "action": action,
                "good_id": good_id,
                "port_id": port_id,
                "quantity": quantity,
            }
        )

        return field_dict

    @classmethod
    def from_dict(cls: type[T], src_dict: Mapping[str, Any]) -> T:
        d = dict(src_dict)
        action = QuoteRequestAction(d.pop("action"))

        good_id = UUID(d.pop("good_id"))

        port_id = UUID(d.pop("port_id"))

        quantity = d.pop("quantity")

        quote_request = cls(
            action=action,
            good_id=good_id,
            port_id=port_id,
            quantity=quantity,
        )

        quote_request.additional_properties = d
        return quote_request

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
