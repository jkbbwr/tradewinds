from __future__ import annotations

from collections.abc import Mapping
from typing import TYPE_CHECKING, Any, TypeVar

from attrs import define as _attrs_define
from attrs import field as _attrs_field

if TYPE_CHECKING:
    from ..models.page_metadata import PageMetadata
    from ..models.trader_position import TraderPosition


T = TypeVar("T", bound="TraderPositionsResponse")


@_attrs_define
class TraderPositionsResponse:
    """Response schema for a list of trader positions.

    Attributes:
        data (list[TraderPosition]):
        metadata (PageMetadata): Pagination metadata for cursor-based paginated results.
    """

    data: list[TraderPosition]
    metadata: PageMetadata
    additional_properties: dict[str, Any] = _attrs_field(init=False, factory=dict)

    def to_dict(self) -> dict[str, Any]:
        data = []
        for data_item_data in self.data:
            data_item = data_item_data.to_dict()
            data.append(data_item)

        metadata = self.metadata.to_dict()

        field_dict: dict[str, Any] = {}
        field_dict.update(self.additional_properties)
        field_dict.update(
            {
                "data": data,
                "metadata": metadata,
            }
        )

        return field_dict

    @classmethod
    def from_dict(cls: type[T], src_dict: Mapping[str, Any]) -> T:
        from ..models.page_metadata import PageMetadata
        from ..models.trader_position import TraderPosition

        d = dict(src_dict)
        data = []
        _data = d.pop("data")
        for data_item_data in _data:
            data_item = TraderPosition.from_dict(data_item_data)

            data.append(data_item)

        metadata = PageMetadata.from_dict(d.pop("metadata"))

        trader_positions_response = cls(
            data=data,
            metadata=metadata,
        )

        trader_positions_response.additional_properties = d
        return trader_positions_response

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
