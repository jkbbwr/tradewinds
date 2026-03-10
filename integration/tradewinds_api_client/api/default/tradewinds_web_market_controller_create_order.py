from http import HTTPStatus
from typing import Any
from uuid import UUID

import httpx

from ... import errors
from ...client import AuthenticatedClient, Client
from ...models.changeset_response import ChangesetResponse
from ...models.create_order_request import CreateOrderRequest
from ...models.error_response import ErrorResponse
from ...models.order_response import OrderResponse
from ...types import UNSET, Response, Unset


def _get_kwargs(
    *,
    body: CreateOrderRequest | Unset = UNSET,
    tradewinds_company_id: UUID,
) -> dict[str, Any]:
    headers: dict[str, Any] = {}
    headers["tradewinds-company-id"] = tradewinds_company_id

    _kwargs: dict[str, Any] = {
        "method": "post",
        "url": "/api/v1/market/orders",
    }

    if not isinstance(body, Unset):
        _kwargs["json"] = body.to_dict()

    headers["Content-Type"] = "application/json"

    _kwargs["headers"] = headers
    return _kwargs


def _parse_response(
    *, client: AuthenticatedClient | Client, response: httpx.Response
) -> ChangesetResponse | ErrorResponse | OrderResponse | None:
    if response.status_code == 201:
        response_201 = OrderResponse.from_dict(response.json())

        return response_201

    if response.status_code == 401:
        response_401 = ErrorResponse.from_dict(response.json())

        return response_401

    if response.status_code == 403:
        response_403 = ErrorResponse.from_dict(response.json())

        return response_403

    if response.status_code == 422:
        response_422 = ChangesetResponse.from_dict(response.json())

        return response_422

    if client.raise_on_unexpected_status:
        raise errors.UnexpectedStatus(response.status_code, response.content)
    else:
        return None


def _build_response(
    *, client: AuthenticatedClient | Client, response: httpx.Response
) -> Response[ChangesetResponse | ErrorResponse | OrderResponse]:
    return Response(
        status_code=HTTPStatus(response.status_code),
        content=response.content,
        headers=response.headers,
        parsed=_parse_response(client=client, response=response),
    )


def sync_detailed(
    *,
    client: AuthenticatedClient,
    body: CreateOrderRequest | Unset = UNSET,
    tradewinds_company_id: UUID,
) -> Response[ChangesetResponse | ErrorResponse | OrderResponse]:
    """Create a market order

     Posts a new order to the market.

    Args:
        tradewinds_company_id (UUID):
        body (CreateOrderRequest | Unset): Request schema to create a new market order.

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        Response[ChangesetResponse | ErrorResponse | OrderResponse]
    """

    kwargs = _get_kwargs(
        body=body,
        tradewinds_company_id=tradewinds_company_id,
    )

    response = client.get_httpx_client().request(
        **kwargs,
    )

    return _build_response(client=client, response=response)


def sync(
    *,
    client: AuthenticatedClient,
    body: CreateOrderRequest | Unset = UNSET,
    tradewinds_company_id: UUID,
) -> ChangesetResponse | ErrorResponse | OrderResponse | None:
    """Create a market order

     Posts a new order to the market.

    Args:
        tradewinds_company_id (UUID):
        body (CreateOrderRequest | Unset): Request schema to create a new market order.

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        ChangesetResponse | ErrorResponse | OrderResponse
    """

    return sync_detailed(
        client=client,
        body=body,
        tradewinds_company_id=tradewinds_company_id,
    ).parsed


async def asyncio_detailed(
    *,
    client: AuthenticatedClient,
    body: CreateOrderRequest | Unset = UNSET,
    tradewinds_company_id: UUID,
) -> Response[ChangesetResponse | ErrorResponse | OrderResponse]:
    """Create a market order

     Posts a new order to the market.

    Args:
        tradewinds_company_id (UUID):
        body (CreateOrderRequest | Unset): Request schema to create a new market order.

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        Response[ChangesetResponse | ErrorResponse | OrderResponse]
    """

    kwargs = _get_kwargs(
        body=body,
        tradewinds_company_id=tradewinds_company_id,
    )

    response = await client.get_async_httpx_client().request(**kwargs)

    return _build_response(client=client, response=response)


async def asyncio(
    *,
    client: AuthenticatedClient,
    body: CreateOrderRequest | Unset = UNSET,
    tradewinds_company_id: UUID,
) -> ChangesetResponse | ErrorResponse | OrderResponse | None:
    """Create a market order

     Posts a new order to the market.

    Args:
        tradewinds_company_id (UUID):
        body (CreateOrderRequest | Unset): Request schema to create a new market order.

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        ChangesetResponse | ErrorResponse | OrderResponse
    """

    return (
        await asyncio_detailed(
            client=client,
            body=body,
            tradewinds_company_id=tradewinds_company_id,
        )
    ).parsed
