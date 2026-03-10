from __future__ import annotations

import datetime
from collections.abc import Mapping
from typing import Any, TypeVar
from uuid import UUID

from attrs import define as _attrs_define
from attrs import field as _attrs_field
from dateutil.parser import isoparse

from ..models.company_status import CompanyStatus
from ..types import UNSET, Unset

T = TypeVar("T", bound="Company")


@_attrs_define
class Company:
    """A company directed by a player.

    Attributes:
        home_port_id (UUID):
        id (UUID):
        name (str):
        reputation (int):
        status (CompanyStatus):
        ticker (str):
        treasury (int):
        inserted_at (datetime.datetime | Unset):
        updated_at (datetime.datetime | Unset):
    """

    home_port_id: UUID
    id: UUID
    name: str
    reputation: int
    status: CompanyStatus
    ticker: str
    treasury: int
    inserted_at: datetime.datetime | Unset = UNSET
    updated_at: datetime.datetime | Unset = UNSET
    additional_properties: dict[str, Any] = _attrs_field(init=False, factory=dict)

    def to_dict(self) -> dict[str, Any]:
        home_port_id = str(self.home_port_id)

        id = str(self.id)

        name = self.name

        reputation = self.reputation

        status = self.status.value

        ticker = self.ticker

        treasury = self.treasury

        inserted_at: str | Unset = UNSET
        if not isinstance(self.inserted_at, Unset):
            inserted_at = self.inserted_at.isoformat()

        updated_at: str | Unset = UNSET
        if not isinstance(self.updated_at, Unset):
            updated_at = self.updated_at.isoformat()

        field_dict: dict[str, Any] = {}
        field_dict.update(self.additional_properties)
        field_dict.update(
            {
                "home_port_id": home_port_id,
                "id": id,
                "name": name,
                "reputation": reputation,
                "status": status,
                "ticker": ticker,
                "treasury": treasury,
            }
        )
        if inserted_at is not UNSET:
            field_dict["inserted_at"] = inserted_at
        if updated_at is not UNSET:
            field_dict["updated_at"] = updated_at

        return field_dict

    @classmethod
    def from_dict(cls: type[T], src_dict: Mapping[str, Any]) -> T:
        d = dict(src_dict)
        home_port_id = UUID(d.pop("home_port_id"))

        id = UUID(d.pop("id"))

        name = d.pop("name")

        reputation = d.pop("reputation")

        status = CompanyStatus(d.pop("status"))

        ticker = d.pop("ticker")

        treasury = d.pop("treasury")

        _inserted_at = d.pop("inserted_at", UNSET)
        inserted_at: datetime.datetime | Unset
        if isinstance(_inserted_at, Unset):
            inserted_at = UNSET
        else:
            inserted_at = isoparse(_inserted_at)

        _updated_at = d.pop("updated_at", UNSET)
        updated_at: datetime.datetime | Unset
        if isinstance(_updated_at, Unset):
            updated_at = UNSET
        else:
            updated_at = isoparse(_updated_at)

        company = cls(
            home_port_id=home_port_id,
            id=id,
            name=name,
            reputation=reputation,
            status=status,
            ticker=ticker,
            treasury=treasury,
            inserted_at=inserted_at,
            updated_at=updated_at,
        )

        company.additional_properties = d
        return company

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
