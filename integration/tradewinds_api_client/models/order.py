from __future__ import annotations

import datetime
from collections.abc import Mapping
from typing import Any, TypeVar
from uuid import UUID

from attrs import define as _attrs_define
from attrs import field as _attrs_field
from dateutil.parser import isoparse

from ..models.order_side import OrderSide
from ..models.order_status import OrderStatus

T = TypeVar("T", bound="Order")


@_attrs_define
class Order:
    """An order on the market.

    Attributes:
        company_id (UUID):
        created_at (datetime.datetime):
        expires_at (datetime.datetime):
        good_id (UUID):
        id (UUID):
        inserted_at (datetime.datetime):
        port_id (UUID):
        posted_reputation (int):
        price (int):
        remaining (int):
        side (OrderSide):
        status (OrderStatus):
        total (int):
        updated_at (datetime.datetime):
    """

    company_id: UUID
    created_at: datetime.datetime
    expires_at: datetime.datetime
    good_id: UUID
    id: UUID
    inserted_at: datetime.datetime
    port_id: UUID
    posted_reputation: int
    price: int
    remaining: int
    side: OrderSide
    status: OrderStatus
    total: int
    updated_at: datetime.datetime
    additional_properties: dict[str, Any] = _attrs_field(init=False, factory=dict)

    def to_dict(self) -> dict[str, Any]:
        company_id = str(self.company_id)

        created_at = self.created_at.isoformat()

        expires_at = self.expires_at.isoformat()

        good_id = str(self.good_id)

        id = str(self.id)

        inserted_at = self.inserted_at.isoformat()

        port_id = str(self.port_id)

        posted_reputation = self.posted_reputation

        price = self.price

        remaining = self.remaining

        side = self.side.value

        status = self.status.value

        total = self.total

        updated_at = self.updated_at.isoformat()

        field_dict: dict[str, Any] = {}
        field_dict.update(self.additional_properties)
        field_dict.update(
            {
                "company_id": company_id,
                "created_at": created_at,
                "expires_at": expires_at,
                "good_id": good_id,
                "id": id,
                "inserted_at": inserted_at,
                "port_id": port_id,
                "posted_reputation": posted_reputation,
                "price": price,
                "remaining": remaining,
                "side": side,
                "status": status,
                "total": total,
                "updated_at": updated_at,
            }
        )

        return field_dict

    @classmethod
    def from_dict(cls: type[T], src_dict: Mapping[str, Any]) -> T:
        d = dict(src_dict)
        company_id = UUID(d.pop("company_id"))

        created_at = isoparse(d.pop("created_at"))

        expires_at = isoparse(d.pop("expires_at"))

        good_id = UUID(d.pop("good_id"))

        id = UUID(d.pop("id"))

        inserted_at = isoparse(d.pop("inserted_at"))

        port_id = UUID(d.pop("port_id"))

        posted_reputation = d.pop("posted_reputation")

        price = d.pop("price")

        remaining = d.pop("remaining")

        side = OrderSide(d.pop("side"))

        status = OrderStatus(d.pop("status"))

        total = d.pop("total")

        updated_at = isoparse(d.pop("updated_at"))

        order = cls(
            company_id=company_id,
            created_at=created_at,
            expires_at=expires_at,
            good_id=good_id,
            id=id,
            inserted_at=inserted_at,
            port_id=port_id,
            posted_reputation=posted_reputation,
            price=price,
            remaining=remaining,
            side=side,
            status=status,
            total=total,
            updated_at=updated_at,
        )

        order.additional_properties = d
        return order

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
