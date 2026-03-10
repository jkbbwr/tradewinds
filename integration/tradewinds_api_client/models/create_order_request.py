from __future__ import annotations

from collections.abc import Mapping
from typing import Any, TypeVar
from uuid import UUID

from attrs import define as _attrs_define
from attrs import field as _attrs_field

from ..models.create_order_request_side import CreateOrderRequestSide

T = TypeVar("T", bound="CreateOrderRequest")


@_attrs_define
class CreateOrderRequest:
    """Request schema to create a new market order.

    Attributes:
        good_id (UUID):
        port_id (UUID):
        price (int):
        side (CreateOrderRequestSide):
        total (int):
    """

    good_id: UUID
    port_id: UUID
    price: int
    side: CreateOrderRequestSide
    total: int
    additional_properties: dict[str, Any] = _attrs_field(init=False, factory=dict)

    def to_dict(self) -> dict[str, Any]:
        good_id = str(self.good_id)

        port_id = str(self.port_id)

        price = self.price

        side = self.side.value

        total = self.total

        field_dict: dict[str, Any] = {}
        field_dict.update(self.additional_properties)
        field_dict.update(
            {
                "good_id": good_id,
                "port_id": port_id,
                "price": price,
                "side": side,
                "total": total,
            }
        )

        return field_dict

    @classmethod
    def from_dict(cls: type[T], src_dict: Mapping[str, Any]) -> T:
        d = dict(src_dict)
        good_id = UUID(d.pop("good_id"))

        port_id = UUID(d.pop("port_id"))

        price = d.pop("price")

        side = CreateOrderRequestSide(d.pop("side"))

        total = d.pop("total")

        create_order_request = cls(
            good_id=good_id,
            port_id=port_id,
            price=price,
            side=side,
            total=total,
        )

        create_order_request.additional_properties = d
        return create_order_request

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
