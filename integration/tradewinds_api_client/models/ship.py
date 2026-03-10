from __future__ import annotations

import datetime
from collections.abc import Mapping
from typing import Any, TypeVar, cast
from uuid import UUID

from attrs import define as _attrs_define
from attrs import field as _attrs_field
from dateutil.parser import isoparse

from ..models.ship_status import ShipStatus
from ..types import UNSET, Unset

T = TypeVar("T", bound="Ship")


@_attrs_define
class Ship:
    """A ship owned by a company.

    Attributes:
        company_id (UUID):
        id (UUID):
        inserted_at (datetime.datetime):
        name (str):
        ship_type_id (UUID):
        status (ShipStatus):
        updated_at (datetime.datetime):
        arriving_at (datetime.datetime | None | Unset):
        port_id (None | Unset | UUID):
        route_id (None | Unset | UUID):
    """

    company_id: UUID
    id: UUID
    inserted_at: datetime.datetime
    name: str
    ship_type_id: UUID
    status: ShipStatus
    updated_at: datetime.datetime
    arriving_at: datetime.datetime | None | Unset = UNSET
    port_id: None | Unset | UUID = UNSET
    route_id: None | Unset | UUID = UNSET
    additional_properties: dict[str, Any] = _attrs_field(init=False, factory=dict)

    def to_dict(self) -> dict[str, Any]:
        company_id = str(self.company_id)

        id = str(self.id)

        inserted_at = self.inserted_at.isoformat()

        name = self.name

        ship_type_id = str(self.ship_type_id)

        status = self.status.value

        updated_at = self.updated_at.isoformat()

        arriving_at: None | str | Unset
        if isinstance(self.arriving_at, Unset):
            arriving_at = UNSET
        elif isinstance(self.arriving_at, datetime.datetime):
            arriving_at = self.arriving_at.isoformat()
        else:
            arriving_at = self.arriving_at

        port_id: None | str | Unset
        if isinstance(self.port_id, Unset):
            port_id = UNSET
        elif isinstance(self.port_id, UUID):
            port_id = str(self.port_id)
        else:
            port_id = self.port_id

        route_id: None | str | Unset
        if isinstance(self.route_id, Unset):
            route_id = UNSET
        elif isinstance(self.route_id, UUID):
            route_id = str(self.route_id)
        else:
            route_id = self.route_id

        field_dict: dict[str, Any] = {}
        field_dict.update(self.additional_properties)
        field_dict.update(
            {
                "company_id": company_id,
                "id": id,
                "inserted_at": inserted_at,
                "name": name,
                "ship_type_id": ship_type_id,
                "status": status,
                "updated_at": updated_at,
            }
        )
        if arriving_at is not UNSET:
            field_dict["arriving_at"] = arriving_at
        if port_id is not UNSET:
            field_dict["port_id"] = port_id
        if route_id is not UNSET:
            field_dict["route_id"] = route_id

        return field_dict

    @classmethod
    def from_dict(cls: type[T], src_dict: Mapping[str, Any]) -> T:
        d = dict(src_dict)
        company_id = UUID(d.pop("company_id"))

        id = UUID(d.pop("id"))

        inserted_at = isoparse(d.pop("inserted_at"))

        name = d.pop("name")

        ship_type_id = UUID(d.pop("ship_type_id"))

        status = ShipStatus(d.pop("status"))

        updated_at = isoparse(d.pop("updated_at"))

        def _parse_arriving_at(data: object) -> datetime.datetime | None | Unset:
            if data is None:
                return data
            if isinstance(data, Unset):
                return data
            try:
                if not isinstance(data, str):
                    raise TypeError()
                arriving_at_type_0 = isoparse(data)

                return arriving_at_type_0
            except (TypeError, ValueError, AttributeError, KeyError):
                pass
            return cast(datetime.datetime | None | Unset, data)

        arriving_at = _parse_arriving_at(d.pop("arriving_at", UNSET))

        def _parse_port_id(data: object) -> None | Unset | UUID:
            if data is None:
                return data
            if isinstance(data, Unset):
                return data
            try:
                if not isinstance(data, str):
                    raise TypeError()
                port_id_type_0 = UUID(data)

                return port_id_type_0
            except (TypeError, ValueError, AttributeError, KeyError):
                pass
            return cast(None | Unset | UUID, data)

        port_id = _parse_port_id(d.pop("port_id", UNSET))

        def _parse_route_id(data: object) -> None | Unset | UUID:
            if data is None:
                return data
            if isinstance(data, Unset):
                return data
            try:
                if not isinstance(data, str):
                    raise TypeError()
                route_id_type_0 = UUID(data)

                return route_id_type_0
            except (TypeError, ValueError, AttributeError, KeyError):
                pass
            return cast(None | Unset | UUID, data)

        route_id = _parse_route_id(d.pop("route_id", UNSET))

        ship = cls(
            company_id=company_id,
            id=id,
            inserted_at=inserted_at,
            name=name,
            ship_type_id=ship_type_id,
            status=status,
            updated_at=updated_at,
            arriving_at=arriving_at,
            port_id=port_id,
            route_id=route_id,
        )

        ship.additional_properties = d
        return ship

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
