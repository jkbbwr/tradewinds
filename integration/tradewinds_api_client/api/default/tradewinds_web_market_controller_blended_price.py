from http import HTTPStatus
from typing import Any

import httpx

from ... import errors
from ...client import AuthenticatedClient, Client
from ...models.blended_price_response import BlendedPriceResponse
from ...models.changeset_response import ChangesetResponse
from ...models.error_response import ErrorResponse
from ...types import UNSET, Response, Unset


def _get_kwargs(
    *,
    port_id: str | Unset = UNSET,
    good_id: str | Unset = UNSET,
    side: str | Unset = UNSET,
    quantity: int | Unset = UNSET,
) -> dict[str, Any]:

    params: dict[str, Any] = {}

    params["port_id"] = port_id

    params["good_id"] = good_id

    params["side"] = side

    params["quantity"] = quantity

    params = {k: v for k, v in params.items() if v is not UNSET and v is not None}

    _kwargs: dict[str, Any] = {
        "method": "get",
        "url": "/api/v1/market/blended-price",
        "params": params,
    }

    return _kwargs


def _parse_response(
    *, client: AuthenticatedClient | Client, response: httpx.Response
) -> BlendedPriceResponse | ChangesetResponse | ErrorResponse | None:
    if response.status_code == 200:
        response_200 = BlendedPriceResponse.from_dict(response.json())

        return response_200

    if response.status_code == 400:
        response_400 = ErrorResponse.from_dict(response.json())

        return response_400

    if response.status_code == 422:
        response_422 = ChangesetResponse.from_dict(response.json())

        return response_422

    if client.raise_on_unexpected_status:
        raise errors.UnexpectedStatus(response.status_code, response.content)
    else:
        return None


def _build_response(
    *, client: AuthenticatedClient | Client, response: httpx.Response
) -> Response[BlendedPriceResponse | ChangesetResponse | ErrorResponse]:
    return Response(
        status_code=HTTPStatus(response.status_code),
        content=response.content,
        headers=response.headers,
        parsed=_parse_response(client=client, response=response),
    )


def sync_detailed(
    *,
    client: AuthenticatedClient | Client,
    port_id: str | Unset = UNSET,
    good_id: str | Unset = UNSET,
    side: str | Unset = UNSET,
    quantity: int | Unset = UNSET,
) -> Response[BlendedPriceResponse | ChangesetResponse | ErrorResponse]:
    """Calculate blended price

     Calculates the blended price for filling a specific quantity of an order.

    Args:
        port_id (str | Unset):
        good_id (str | Unset):
        side (str | Unset):
        quantity (int | Unset):

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        Response[BlendedPriceResponse | ChangesetResponse | ErrorResponse]
    """

    kwargs = _get_kwargs(
        port_id=port_id,
        good_id=good_id,
        side=side,
        quantity=quantity,
    )

    response = client.get_httpx_client().request(
        **kwargs,
    )

    return _build_response(client=client, response=response)


def sync(
    *,
    client: AuthenticatedClient | Client,
    port_id: str | Unset = UNSET,
    good_id: str | Unset = UNSET,
    side: str | Unset = UNSET,
    quantity: int | Unset = UNSET,
) -> BlendedPriceResponse | ChangesetResponse | ErrorResponse | None:
    """Calculate blended price

     Calculates the blended price for filling a specific quantity of an order.

    Args:
        port_id (str | Unset):
        good_id (str | Unset):
        side (str | Unset):
        quantity (int | Unset):

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        BlendedPriceResponse | ChangesetResponse | ErrorResponse
    """

    return sync_detailed(
        client=client,
        port_id=port_id,
        good_id=good_id,
        side=side,
        quantity=quantity,
    ).parsed


async def asyncio_detailed(
    *,
    client: AuthenticatedClient | Client,
    port_id: str | Unset = UNSET,
    good_id: str | Unset = UNSET,
    side: str | Unset = UNSET,
    quantity: int | Unset = UNSET,
) -> Response[BlendedPriceResponse | ChangesetResponse | ErrorResponse]:
    """Calculate blended price

     Calculates the blended price for filling a specific quantity of an order.

    Args:
        port_id (str | Unset):
        good_id (str | Unset):
        side (str | Unset):
        quantity (int | Unset):

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        Response[BlendedPriceResponse | ChangesetResponse | ErrorResponse]
    """

    kwargs = _get_kwargs(
        port_id=port_id,
        good_id=good_id,
        side=side,
        quantity=quantity,
    )

    response = await client.get_async_httpx_client().request(**kwargs)

    return _build_response(client=client, response=response)


async def asyncio(
    *,
    client: AuthenticatedClient | Client,
    port_id: str | Unset = UNSET,
    good_id: str | Unset = UNSET,
    side: str | Unset = UNSET,
    quantity: int | Unset = UNSET,
) -> BlendedPriceResponse | ChangesetResponse | ErrorResponse | None:
    """Calculate blended price

     Calculates the blended price for filling a specific quantity of an order.

    Args:
        port_id (str | Unset):
        good_id (str | Unset):
        side (str | Unset):
        quantity (int | Unset):

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        BlendedPriceResponse | ChangesetResponse | ErrorResponse
    """

    return (
        await asyncio_detailed(
            client=client,
            port_id=port_id,
            good_id=good_id,
            side=side,
            quantity=quantity,
        )
    ).parsed
