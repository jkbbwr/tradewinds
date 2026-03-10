from __future__ import annotations

import datetime
from collections.abc import Mapping
from typing import Any, TypeVar
from uuid import UUID

from attrs import define as _attrs_define
from attrs import field as _attrs_field
from dateutil.parser import isoparse

from ..models.quote_response_data_quote_action import QuoteResponseDataQuoteAction

T = TypeVar("T", bound="QuoteResponseDataQuote")


@_attrs_define
class QuoteResponseDataQuote:
    """
    Attributes:
        action (QuoteResponseDataQuoteAction):
        company_id (UUID):
        good_id (UUID):
        port_id (UUID):
        quantity (int):
        timestamp (datetime.datetime):
        total_price (int):
        unit_price (int):
    """

    action: QuoteResponseDataQuoteAction
    company_id: UUID
    good_id: UUID
    port_id: UUID
    quantity: int
    timestamp: datetime.datetime
    total_price: int
    unit_price: int
    additional_properties: dict[str, Any] = _attrs_field(init=False, factory=dict)

    def to_dict(self) -> dict[str, Any]:
        action = self.action.value

        company_id = str(self.company_id)

        good_id = str(self.good_id)

        port_id = str(self.port_id)

        quantity = self.quantity

        timestamp = self.timestamp.isoformat()

        total_price = self.total_price

        unit_price = self.unit_price

        field_dict: dict[str, Any] = {}
        field_dict.update(self.additional_properties)
        field_dict.update(
            {
                "action": action,
                "company_id": company_id,
                "good_id": good_id,
                "port_id": port_id,
                "quantity": quantity,
                "timestamp": timestamp,
                "total_price": total_price,
                "unit_price": unit_price,
            }
        )

        return field_dict

    @classmethod
    def from_dict(cls: type[T], src_dict: Mapping[str, Any]) -> T:
        d = dict(src_dict)
        action = QuoteResponseDataQuoteAction(d.pop("action"))

        company_id = UUID(d.pop("company_id"))

        good_id = UUID(d.pop("good_id"))

        port_id = UUID(d.pop("port_id"))

        quantity = d.pop("quantity")

        timestamp = isoparse(d.pop("timestamp"))

        total_price = d.pop("total_price")

        unit_price = d.pop("unit_price")

        quote_response_data_quote = cls(
            action=action,
            company_id=company_id,
            good_id=good_id,
            port_id=port_id,
            quantity=quantity,
            timestamp=timestamp,
            total_price=total_price,
            unit_price=unit_price,
        )

        quote_response_data_quote.additional_properties = d
        return quote_response_data_quote

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
