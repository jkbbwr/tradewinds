from __future__ import annotations

from collections.abc import Mapping
from typing import TYPE_CHECKING, Any, TypeVar

from attrs import define as _attrs_define
from attrs import field as _attrs_field

if TYPE_CHECKING:
    from ..models.quote_response_data_quote import QuoteResponseDataQuote


T = TypeVar("T", bound="QuoteResponseData")


@_attrs_define
class QuoteResponseData:
    """
    Attributes:
        quote (QuoteResponseDataQuote):
        token (str):
    """

    quote: QuoteResponseDataQuote
    token: str
    additional_properties: dict[str, Any] = _attrs_field(init=False, factory=dict)

    def to_dict(self) -> dict[str, Any]:
        quote = self.quote.to_dict()

        token = self.token

        field_dict: dict[str, Any] = {}
        field_dict.update(self.additional_properties)
        field_dict.update(
            {
                "quote": quote,
                "token": token,
            }
        )

        return field_dict

    @classmethod
    def from_dict(cls: type[T], src_dict: Mapping[str, Any]) -> T:
        from ..models.quote_response_data_quote import QuoteResponseDataQuote

        d = dict(src_dict)
        quote = QuoteResponseDataQuote.from_dict(d.pop("quote"))

        token = d.pop("token")

        quote_response_data = cls(
            quote=quote,
            token=token,
        )

        quote_response_data.additional_properties = d
        return quote_response_data

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
