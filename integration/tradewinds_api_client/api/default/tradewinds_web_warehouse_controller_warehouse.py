from http import HTTPStatus
from typing import Any
from urllib.parse import quote
from uuid import UUID

import httpx

from ... import errors
from ...client import AuthenticatedClient, Client
from ...models.error_response import ErrorResponse
from ...models.warehouse_response import WarehouseResponse
from ...types import Response


def _get_kwargs(
    warehouse_id: str,
    *,
    tradewinds_company_id: UUID,
) -> dict[str, Any]:
    headers: dict[str, Any] = {}
    headers["tradewinds-company-id"] = tradewinds_company_id

    _kwargs: dict[str, Any] = {
        "method": "get",
        "url": "/api/v1/warehouses/{warehouse_id}".format(
            warehouse_id=quote(str(warehouse_id), safe=""),
        ),
    }

    _kwargs["headers"] = headers
    return _kwargs


def _parse_response(
    *, client: AuthenticatedClient | Client, response: httpx.Response
) -> ErrorResponse | WarehouseResponse | None:
    if response.status_code == 200:
        response_200 = WarehouseResponse.from_dict(response.json())

        return response_200

    if response.status_code == 401:
        response_401 = ErrorResponse.from_dict(response.json())

        return response_401

    if response.status_code == 404:
        response_404 = ErrorResponse.from_dict(response.json())

        return response_404

    if client.raise_on_unexpected_status:
        raise errors.UnexpectedStatus(response.status_code, response.content)
    else:
        return None


def _build_response(
    *, client: AuthenticatedClient | Client, response: httpx.Response
) -> Response[ErrorResponse | WarehouseResponse]:
    return Response(
        status_code=HTTPStatus(response.status_code),
        content=response.content,
        headers=response.headers,
        parsed=_parse_response(client=client, response=response),
    )


def sync_detailed(
    warehouse_id: str,
    *,
    client: AuthenticatedClient,
    tradewinds_company_id: UUID,
) -> Response[ErrorResponse | WarehouseResponse]:
    """Get warehouse details

     Returns the details of a specific warehouse owned by the current company.

    Args:
        warehouse_id (str):
        tradewinds_company_id (UUID):

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        Response[ErrorResponse | WarehouseResponse]
    """

    kwargs = _get_kwargs(
        warehouse_id=warehouse_id,
        tradewinds_company_id=tradewinds_company_id,
    )

    response = client.get_httpx_client().request(
        **kwargs,
    )

    return _build_response(client=client, response=response)


def sync(
    warehouse_id: str,
    *,
    client: AuthenticatedClient,
    tradewinds_company_id: UUID,
) -> ErrorResponse | WarehouseResponse | None:
    """Get warehouse details

     Returns the details of a specific warehouse owned by the current company.

    Args:
        warehouse_id (str):
        tradewinds_company_id (UUID):

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        ErrorResponse | WarehouseResponse
    """

    return sync_detailed(
        warehouse_id=warehouse_id,
        client=client,
        tradewinds_company_id=tradewinds_company_id,
    ).parsed


async def asyncio_detailed(
    warehouse_id: str,
    *,
    client: AuthenticatedClient,
    tradewinds_company_id: UUID,
) -> Response[ErrorResponse | WarehouseResponse]:
    """Get warehouse details

     Returns the details of a specific warehouse owned by the current company.

    Args:
        warehouse_id (str):
        tradewinds_company_id (UUID):

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        Response[ErrorResponse | WarehouseResponse]
    """

    kwargs = _get_kwargs(
        warehouse_id=warehouse_id,
        tradewinds_company_id=tradewinds_company_id,
    )

    response = await client.get_async_httpx_client().request(**kwargs)

    return _build_response(client=client, response=response)


async def asyncio(
    warehouse_id: str,
    *,
    client: AuthenticatedClient,
    tradewinds_company_id: UUID,
) -> ErrorResponse | WarehouseResponse | None:
    """Get warehouse details

     Returns the details of a specific warehouse owned by the current company.

    Args:
        warehouse_id (str):
        tradewinds_company_id (UUID):

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        ErrorResponse | WarehouseResponse
    """

    return (
        await asyncio_detailed(
            warehouse_id=warehouse_id,
            client=client,
            tradewinds_company_id=tradewinds_company_id,
        )
    ).parsed
