from http import HTTPStatus
from typing import Any
from urllib.parse import quote

import httpx

from ... import errors
from ...client import AuthenticatedClient, Client
from ...models.error_response import ErrorResponse
from ...models.inventory_response import InventoryResponse
from ...types import Response


def _get_kwargs(
    shipyard_id: str,
) -> dict[str, Any]:

    _kwargs: dict[str, Any] = {
        "method": "get",
        "url": "/api/v1/shipyards/{shipyard_id}/inventory".format(
            shipyard_id=quote(str(shipyard_id), safe=""),
        ),
    }

    return _kwargs


def _parse_response(
    *, client: AuthenticatedClient | Client, response: httpx.Response
) -> ErrorResponse | InventoryResponse | None:
    if response.status_code == 200:
        response_200 = InventoryResponse.from_dict(response.json())

        return response_200

    if response.status_code == 404:
        response_404 = ErrorResponse.from_dict(response.json())

        return response_404

    if client.raise_on_unexpected_status:
        raise errors.UnexpectedStatus(response.status_code, response.content)
    else:
        return None


def _build_response(
    *, client: AuthenticatedClient | Client, response: httpx.Response
) -> Response[ErrorResponse | InventoryResponse]:
    return Response(
        status_code=HTTPStatus(response.status_code),
        content=response.content,
        headers=response.headers,
        parsed=_parse_response(client=client, response=response),
    )


def sync_detailed(
    shipyard_id: str,
    *,
    client: AuthenticatedClient | Client,
) -> Response[ErrorResponse | InventoryResponse]:
    """Get shipyard inventory

     Returns all unowned ships available for purchase at a shipyard.

    Args:
        shipyard_id (str):

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        Response[ErrorResponse | InventoryResponse]
    """

    kwargs = _get_kwargs(
        shipyard_id=shipyard_id,
    )

    response = client.get_httpx_client().request(
        **kwargs,
    )

    return _build_response(client=client, response=response)


def sync(
    shipyard_id: str,
    *,
    client: AuthenticatedClient | Client,
) -> ErrorResponse | InventoryResponse | None:
    """Get shipyard inventory

     Returns all unowned ships available for purchase at a shipyard.

    Args:
        shipyard_id (str):

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        ErrorResponse | InventoryResponse
    """

    return sync_detailed(
        shipyard_id=shipyard_id,
        client=client,
    ).parsed


async def asyncio_detailed(
    shipyard_id: str,
    *,
    client: AuthenticatedClient | Client,
) -> Response[ErrorResponse | InventoryResponse]:
    """Get shipyard inventory

     Returns all unowned ships available for purchase at a shipyard.

    Args:
        shipyard_id (str):

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        Response[ErrorResponse | InventoryResponse]
    """

    kwargs = _get_kwargs(
        shipyard_id=shipyard_id,
    )

    response = await client.get_async_httpx_client().request(**kwargs)

    return _build_response(client=client, response=response)


async def asyncio(
    shipyard_id: str,
    *,
    client: AuthenticatedClient | Client,
) -> ErrorResponse | InventoryResponse | None:
    """Get shipyard inventory

     Returns all unowned ships available for purchase at a shipyard.

    Args:
        shipyard_id (str):

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        ErrorResponse | InventoryResponse
    """

    return (
        await asyncio_detailed(
            shipyard_id=shipyard_id,
            client=client,
        )
    ).parsed
