from __future__ import annotations

from collections.abc import Mapping
from typing import TYPE_CHECKING, Any, TypeVar
from uuid import UUID

from attrs import define as _attrs_define
from attrs import field as _attrs_field

from ..models.execute_trade_request_action import ExecuteTradeRequestAction

if TYPE_CHECKING:
    from ..models.trade_destination import TradeDestination


T = TypeVar("T", bound="ExecuteTradeRequest")


@_attrs_define
class ExecuteTradeRequest:
    """Request to execute an immediate trade.

    Attributes:
        action (ExecuteTradeRequestAction):
        destinations (list[TradeDestination]):
        good_id (UUID):
        port_id (UUID):
    """

    action: ExecuteTradeRequestAction
    destinations: list[TradeDestination]
    good_id: UUID
    port_id: UUID
    additional_properties: dict[str, Any] = _attrs_field(init=False, factory=dict)

    def to_dict(self) -> dict[str, Any]:
        action = self.action.value

        destinations = []
        for destinations_item_data in self.destinations:
            destinations_item = destinations_item_data.to_dict()
            destinations.append(destinations_item)

        good_id = str(self.good_id)

        port_id = str(self.port_id)

        field_dict: dict[str, Any] = {}
        field_dict.update(self.additional_properties)
        field_dict.update(
            {
                "action": action,
                "destinations": destinations,
                "good_id": good_id,
                "port_id": port_id,
            }
        )

        return field_dict

    @classmethod
    def from_dict(cls: type[T], src_dict: Mapping[str, Any]) -> T:
        from ..models.trade_destination import TradeDestination

        d = dict(src_dict)
        action = ExecuteTradeRequestAction(d.pop("action"))

        destinations = []
        _destinations = d.pop("destinations")
        for destinations_item_data in _destinations:
            destinations_item = TradeDestination.from_dict(destinations_item_data)

            destinations.append(destinations_item)

        good_id = UUID(d.pop("good_id"))

        port_id = UUID(d.pop("port_id"))

        execute_trade_request = cls(
            action=action,
            destinations=destinations,
            good_id=good_id,
            port_id=port_id,
        )

        execute_trade_request.additional_properties = d
        return execute_trade_request

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
