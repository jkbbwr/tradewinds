from __future__ import annotations

from collections.abc import Mapping
from typing import Any, TypeVar
from uuid import UUID

from attrs import define as _attrs_define
from attrs import field as _attrs_field

from ..models.trade_execution_response_data_action import TradeExecutionResponseDataAction

T = TypeVar("T", bound="TradeExecutionResponseData")


@_attrs_define
class TradeExecutionResponseData:
    """
    Attributes:
        action (TradeExecutionResponseDataAction):
        company_id (UUID):
        good_id (UUID):
        port_id (UUID):
        quantity (int):
        total_price (int):
        unit_price (int):
    """

    action: TradeExecutionResponseDataAction
    company_id: UUID
    good_id: UUID
    port_id: UUID
    quantity: int
    total_price: int
    unit_price: int
    additional_properties: dict[str, Any] = _attrs_field(init=False, factory=dict)

    def to_dict(self) -> dict[str, Any]:
        action = self.action.value

        company_id = str(self.company_id)

        good_id = str(self.good_id)

        port_id = str(self.port_id)

        quantity = self.quantity

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
                "total_price": total_price,
                "unit_price": unit_price,
            }
        )

        return field_dict

    @classmethod
    def from_dict(cls: type[T], src_dict: Mapping[str, Any]) -> T:
        d = dict(src_dict)
        action = TradeExecutionResponseDataAction(d.pop("action"))

        company_id = UUID(d.pop("company_id"))

        good_id = UUID(d.pop("good_id"))

        port_id = UUID(d.pop("port_id"))

        quantity = d.pop("quantity")

        total_price = d.pop("total_price")

        unit_price = d.pop("unit_price")

        trade_execution_response_data = cls(
            action=action,
            company_id=company_id,
            good_id=good_id,
            port_id=port_id,
            quantity=quantity,
            total_price=total_price,
            unit_price=unit_price,
        )

        trade_execution_response_data.additional_properties = d
        return trade_execution_response_data

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
