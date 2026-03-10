from http import HTTPStatus
from typing import Any, cast
from urllib.parse import quote
from uuid import UUID

import httpx

from ... import errors
from ...client import AuthenticatedClient, Client
from ...models.changeset_response import ChangesetResponse
from ...models.error_response import ErrorResponse
from ...models.transfer_to_warehouse_request import TransferToWarehouseRequest
from ...types import UNSET, Response, Unset


def _get_kwargs(
    ship_id: str,
    *,
    body: TransferToWarehouseRequest | Unset = UNSET,
    tradewinds_company_id: UUID,
) -> dict[str, Any]:
    headers: dict[str, Any] = {}
    headers["tradewinds-company-id"] = tradewinds_company_id

    _kwargs: dict[str, Any] = {
        "method": "post",
        "url": "/api/v1/ships/{ship_id}/transfer-to-warehouse".format(
            ship_id=quote(str(ship_id), safe=""),
        ),
    }

    if not isinstance(body, Unset):
        _kwargs["json"] = body.to_dict()

    headers["Content-Type"] = "application/json"

    _kwargs["headers"] = headers
    return _kwargs


def _parse_response(
    *, client: AuthenticatedClient | Client, response: httpx.Response
) -> Any | ChangesetResponse | ErrorResponse | None:
    if response.status_code == 204:
        response_204 = cast(Any, None)
        return response_204

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
) -> Response[Any | ChangesetResponse | ErrorResponse]:
    return Response(
        status_code=HTTPStatus(response.status_code),
        content=response.content,
        headers=response.headers,
        parsed=_parse_response(client=client, response=response),
    )


def sync_detailed(
    ship_id: str,
    *,
    client: AuthenticatedClient,
    body: TransferToWarehouseRequest | Unset = UNSET,
    tradewinds_company_id: UUID,
) -> Response[Any | ChangesetResponse | ErrorResponse]:
    """Transfer cargo to warehouse

     Transfers cargo from a docked ship to a warehouse.

    Args:
        ship_id (str):
        tradewinds_company_id (UUID):
        body (TransferToWarehouseRequest | Unset): Request schema to transfer cargo from a ship to
            a warehouse.

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        Response[Any | ChangesetResponse | ErrorResponse]
    """

    kwargs = _get_kwargs(
        ship_id=ship_id,
        body=body,
        tradewinds_company_id=tradewinds_company_id,
    )

    response = client.get_httpx_client().request(
        **kwargs,
    )

    return _build_response(client=client, response=response)


def sync(
    ship_id: str,
    *,
    client: AuthenticatedClient,
    body: TransferToWarehouseRequest | Unset = UNSET,
    tradewinds_company_id: UUID,
) -> Any | ChangesetResponse | ErrorResponse | None:
    """Transfer cargo to warehouse

     Transfers cargo from a docked ship to a warehouse.

    Args:
        ship_id (str):
        tradewinds_company_id (UUID):
        body (TransferToWarehouseRequest | Unset): Request schema to transfer cargo from a ship to
            a warehouse.

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        Any | ChangesetResponse | ErrorResponse
    """

    return sync_detailed(
        ship_id=ship_id,
        client=client,
        body=body,
        tradewinds_company_id=tradewinds_company_id,
    ).parsed


async def asyncio_detailed(
    ship_id: str,
    *,
    client: AuthenticatedClient,
    body: TransferToWarehouseRequest | Unset = UNSET,
    tradewinds_company_id: UUID,
) -> Response[Any | ChangesetResponse | ErrorResponse]:
    """Transfer cargo to warehouse

     Transfers cargo from a docked ship to a warehouse.

    Args:
        ship_id (str):
        tradewinds_company_id (UUID):
        body (TransferToWarehouseRequest | Unset): Request schema to transfer cargo from a ship to
            a warehouse.

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        Response[Any | ChangesetResponse | ErrorResponse]
    """

    kwargs = _get_kwargs(
        ship_id=ship_id,
        body=body,
        tradewinds_company_id=tradewinds_company_id,
    )

    response = await client.get_async_httpx_client().request(**kwargs)

    return _build_response(client=client, response=response)


async def asyncio(
    ship_id: str,
    *,
    client: AuthenticatedClient,
    body: TransferToWarehouseRequest | Unset = UNSET,
    tradewinds_company_id: UUID,
) -> Any | ChangesetResponse | ErrorResponse | None:
    """Transfer cargo to warehouse

     Transfers cargo from a docked ship to a warehouse.

    Args:
        ship_id (str):
        tradewinds_company_id (UUID):
        body (TransferToWarehouseRequest | Unset): Request schema to transfer cargo from a ship to
            a warehouse.

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        Any | ChangesetResponse | ErrorResponse
    """

    return (
        await asyncio_detailed(
            ship_id=ship_id,
            client=client,
            body=body,
            tradewinds_company_id=tradewinds_company_id,
        )
    ).parsed
