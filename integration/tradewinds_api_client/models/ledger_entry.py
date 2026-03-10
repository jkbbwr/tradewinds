from __future__ import annotations

import datetime
from collections.abc import Mapping
from typing import TYPE_CHECKING, Any, TypeVar
from uuid import UUID

from attrs import define as _attrs_define
from attrs import field as _attrs_field
from dateutil.parser import isoparse

from ..models.ledger_entry_reason import LedgerEntryReason
from ..models.ledger_entry_reference_type import LedgerEntryReferenceType
from ..types import UNSET, Unset

if TYPE_CHECKING:
    from ..models.ledger_entry_meta import LedgerEntryMeta


T = TypeVar("T", bound="LedgerEntry")


@_attrs_define
class LedgerEntry:
    """A financial transaction in a company's ledger.

    Attributes:
        amount (int):
        company_id (UUID):
        id (UUID):
        idempotency_key (str):
        inserted_at (datetime.datetime):
        occurred_at (datetime.datetime):
        reason (LedgerEntryReason):
        reference_id (UUID):
        reference_type (LedgerEntryReferenceType):
        meta (LedgerEntryMeta | Unset):
    """

    amount: int
    company_id: UUID
    id: UUID
    idempotency_key: str
    inserted_at: datetime.datetime
    occurred_at: datetime.datetime
    reason: LedgerEntryReason
    reference_id: UUID
    reference_type: LedgerEntryReferenceType
    meta: LedgerEntryMeta | Unset = UNSET
    additional_properties: dict[str, Any] = _attrs_field(init=False, factory=dict)

    def to_dict(self) -> dict[str, Any]:
        amount = self.amount

        company_id = str(self.company_id)

        id = str(self.id)

        idempotency_key = self.idempotency_key

        inserted_at = self.inserted_at.isoformat()

        occurred_at = self.occurred_at.isoformat()

        reason = self.reason.value

        reference_id = str(self.reference_id)

        reference_type = self.reference_type.value

        meta: dict[str, Any] | Unset = UNSET
        if not isinstance(self.meta, Unset):
            meta = self.meta.to_dict()

        field_dict: dict[str, Any] = {}
        field_dict.update(self.additional_properties)
        field_dict.update(
            {
                "amount": amount,
                "company_id": company_id,
                "id": id,
                "idempotency_key": idempotency_key,
                "inserted_at": inserted_at,
                "occurred_at": occurred_at,
                "reason": reason,
                "reference_id": reference_id,
                "reference_type": reference_type,
            }
        )
        if meta is not UNSET:
            field_dict["meta"] = meta

        return field_dict

    @classmethod
    def from_dict(cls: type[T], src_dict: Mapping[str, Any]) -> T:
        from ..models.ledger_entry_meta import LedgerEntryMeta

        d = dict(src_dict)
        amount = d.pop("amount")

        company_id = UUID(d.pop("company_id"))

        id = UUID(d.pop("id"))

        idempotency_key = d.pop("idempotency_key")

        inserted_at = isoparse(d.pop("inserted_at"))

        occurred_at = isoparse(d.pop("occurred_at"))

        reason = LedgerEntryReason(d.pop("reason"))

        reference_id = UUID(d.pop("reference_id"))

        reference_type = LedgerEntryReferenceType(d.pop("reference_type"))

        _meta = d.pop("meta", UNSET)
        meta: LedgerEntryMeta | Unset
        if isinstance(_meta, Unset):
            meta = UNSET
        else:
            meta = LedgerEntryMeta.from_dict(_meta)

        ledger_entry = cls(
            amount=amount,
            company_id=company_id,
            id=id,
            idempotency_key=idempotency_key,
            inserted_at=inserted_at,
            occurred_at=occurred_at,
            reason=reason,
            reference_id=reference_id,
            reference_type=reference_type,
            meta=meta,
        )

        ledger_entry.additional_properties = d
        return ledger_entry

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
