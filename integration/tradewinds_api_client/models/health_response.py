from __future__ import annotations

import datetime
from collections.abc import Mapping
from typing import Any, TypeVar

from attrs import define as _attrs_define
from attrs import field as _attrs_field
from dateutil.parser import isoparse

from ..models.health_response_database import HealthResponseDatabase
from ..models.health_response_status import HealthResponseStatus

T = TypeVar("T", bound="HealthResponse")


@_attrs_define
class HealthResponse:
    """Response schema for the health check endpoint

    Example:
        {'database': 'connected', 'oban_lag_seconds': 0, 'server_time': '2026-03-08T16:00:00Z', 'status': 'healthy'}

    Attributes:
        database (HealthResponseDatabase):
        oban_lag_seconds (int):
        server_time (datetime.datetime):
        status (HealthResponseStatus):
    """

    database: HealthResponseDatabase
    oban_lag_seconds: int
    server_time: datetime.datetime
    status: HealthResponseStatus
    additional_properties: dict[str, Any] = _attrs_field(init=False, factory=dict)

    def to_dict(self) -> dict[str, Any]:
        database = self.database.value

        oban_lag_seconds = self.oban_lag_seconds

        server_time = self.server_time.isoformat()

        status = self.status.value

        field_dict: dict[str, Any] = {}
        field_dict.update(self.additional_properties)
        field_dict.update(
            {
                "database": database,
                "oban_lag_seconds": oban_lag_seconds,
                "server_time": server_time,
                "status": status,
            }
        )

        return field_dict

    @classmethod
    def from_dict(cls: type[T], src_dict: Mapping[str, Any]) -> T:
        d = dict(src_dict)
        database = HealthResponseDatabase(d.pop("database"))

        oban_lag_seconds = d.pop("oban_lag_seconds")

        server_time = isoparse(d.pop("server_time"))

        status = HealthResponseStatus(d.pop("status"))

        health_response = cls(
            database=database,
            oban_lag_seconds=oban_lag_seconds,
            server_time=server_time,
            status=status,
        )

        health_response.additional_properties = d
        return health_response

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
