from http import HTTPStatus
from typing import Any
from urllib.parse import quote
from uuid import UUID

import httpx

from ... import errors
from ...client import AuthenticatedClient, Client
from ...models.changeset_response import ChangesetResponse
from ...models.error_response import ErrorResponse
from ...models.fill_order_request import FillOrderRequest
from ...models.order_response import OrderResponse
from ...types import UNSET, Response, Unset


def _get_kwargs(
    order_id: str,
    *,
    body: FillOrderRequest | Unset = UNSET,
    tradewinds_company_id: UUID,
) -> dict[str, Any]:
    headers: dict[str, Any] = {}
    headers["tradewinds-company-id"] = tradewinds_company_id

    _kwargs: dict[str, Any] = {
        "method": "post",
        "url": "/api/v1/market/orders/{order_id}/fill".format(
            order_id=quote(str(order_id), safe=""),
        ),
    }

    if not isinstance(body, Unset):
        _kwargs["json"] = body.to_dict()

    headers["Content-Type"] = "application/json"

    _kwargs["headers"] = headers
    return _kwargs


def _parse_response(
    *, client: AuthenticatedClient | Client, response: httpx.Response
) -> ChangesetResponse | ErrorResponse | OrderResponse | None:
    if response.status_code == 200:
        response_200 = OrderResponse.from_dict(response.json())

        return response_200

    if response.status_code == 400:
        response_400 = ErrorResponse.from_dict(response.json())

        return response_400

    if response.status_code == 401:
        response_401 = ErrorResponse.from_dict(response.json())

        return response_401

    if response.status_code == 404:
        response_404 = ErrorResponse.from_dict(response.json())

        return response_404

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
    order_id: str,
    *,
    client: AuthenticatedClient,
    body: FillOrderRequest | Unset = UNSET,
    tradewinds_company_id: UUID,
) -> Response[ChangesetResponse | ErrorResponse | OrderResponse]:
    """Fill an order

     Fills a specified quantity of an open order.

    Args:
        order_id (str):
        tradewinds_company_id (UUID):
        body (FillOrderRequest | Unset): Request schema to fill an existing market order.

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        Response[ChangesetResponse | ErrorResponse | OrderResponse]
    """

    kwargs = _get_kwargs(
        order_id=order_id,
        body=body,
        tradewinds_company_id=tradewinds_company_id,
    )

    response = client.get_httpx_client().request(
        **kwargs,
    )

    return _build_response(client=client, response=response)


def sync(
    order_id: str,
    *,
    client: AuthenticatedClient,
    body: FillOrderRequest | Unset = UNSET,
    tradewinds_company_id: UUID,
) -> ChangesetResponse | ErrorResponse | OrderResponse | None:
    """Fill an order

     Fills a specified quantity of an open order.

    Args:
        order_id (str):
        tradewinds_company_id (UUID):
        body (FillOrderRequest | Unset): Request schema to fill an existing market order.

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        ChangesetResponse | ErrorResponse | OrderResponse
    """

    return sync_detailed(
        order_id=order_id,
        client=client,
        body=body,
        tradewinds_company_id=tradewinds_company_id,
    ).parsed


async def asyncio_detailed(
    order_id: str,
    *,
    client: AuthenticatedClient,
    body: FillOrderRequest | Unset = UNSET,
    tradewinds_company_id: UUID,
) -> Response[ChangesetResponse | ErrorResponse | OrderResponse]:
    """Fill an order

     Fills a specified quantity of an open order.

    Args:
        order_id (str):
        tradewinds_company_id (UUID):
        body (FillOrderRequest | Unset): Request schema to fill an existing market order.

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        Response[ChangesetResponse | ErrorResponse | OrderResponse]
    """

    kwargs = _get_kwargs(
        order_id=order_id,
        body=body,
        tradewinds_company_id=tradewinds_company_id,
    )

    response = await client.get_async_httpx_client().request(**kwargs)

    return _build_response(client=client, response=response)


async def asyncio(
    order_id: str,
    *,
    client: AuthenticatedClient,
    body: FillOrderRequest | Unset = UNSET,
    tradewinds_company_id: UUID,
) -> ChangesetResponse | ErrorResponse | OrderResponse | None:
    """Fill an order

     Fills a specified quantity of an open order.

    Args:
        order_id (str):
        tradewinds_company_id (UUID):
        body (FillOrderRequest | Unset): Request schema to fill an existing market order.

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        ChangesetResponse | ErrorResponse | OrderResponse
    """

    return (
        await asyncio_detailed(
            order_id=order_id,
            client=client,
            body=body,
            tradewinds_company_id=tradewinds_company_id,
        )
    ).parsed
