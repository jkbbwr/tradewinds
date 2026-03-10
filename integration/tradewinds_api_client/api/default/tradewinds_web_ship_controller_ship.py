from http import HTTPStatus
from typing import Any
from urllib.parse import quote
from uuid import UUID

import httpx

from ... import errors
from ...client import AuthenticatedClient, Client
from ...models.error_response import ErrorResponse
from ...models.ship_response import ShipResponse
from ...types import Response


def _get_kwargs(
    ship_id: str,
    *,
    tradewinds_company_id: UUID,
) -> dict[str, Any]:
    headers: dict[str, Any] = {}
    headers["tradewinds-company-id"] = tradewinds_company_id

    _kwargs: dict[str, Any] = {
        "method": "get",
        "url": "/api/v1/ships/{ship_id}".format(
            ship_id=quote(str(ship_id), safe=""),
        ),
    }

    _kwargs["headers"] = headers
    return _kwargs


def _parse_response(
    *, client: AuthenticatedClient | Client, response: httpx.Response
) -> ErrorResponse | ShipResponse | None:
    if response.status_code == 200:
        response_200 = ShipResponse.from_dict(response.json())

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
) -> Response[ErrorResponse | ShipResponse]:
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
    tradewinds_company_id: UUID,
) -> Response[ErrorResponse | ShipResponse]:
    """Get ship details

     Returns the details of a specific ship owned by the current company.

    Args:
        ship_id (str):
        tradewinds_company_id (UUID):

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        Response[ErrorResponse | ShipResponse]
    """

    kwargs = _get_kwargs(
        ship_id=ship_id,
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
    tradewinds_company_id: UUID,
) -> ErrorResponse | ShipResponse | None:
    """Get ship details

     Returns the details of a specific ship owned by the current company.

    Args:
        ship_id (str):
        tradewinds_company_id (UUID):

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        ErrorResponse | ShipResponse
    """

    return sync_detailed(
        ship_id=ship_id,
        client=client,
        tradewinds_company_id=tradewinds_company_id,
    ).parsed


async def asyncio_detailed(
    ship_id: str,
    *,
    client: AuthenticatedClient,
    tradewinds_company_id: UUID,
) -> Response[ErrorResponse | ShipResponse]:
    """Get ship details

     Returns the details of a specific ship owned by the current company.

    Args:
        ship_id (str):
        tradewinds_company_id (UUID):

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        Response[ErrorResponse | ShipResponse]
    """

    kwargs = _get_kwargs(
        ship_id=ship_id,
        tradewinds_company_id=tradewinds_company_id,
    )

    response = await client.get_async_httpx_client().request(**kwargs)

    return _build_response(client=client, response=response)


async def asyncio(
    ship_id: str,
    *,
    client: AuthenticatedClient,
    tradewinds_company_id: UUID,
) -> ErrorResponse | ShipResponse | None:
    """Get ship details

     Returns the details of a specific ship owned by the current company.

    Args:
        ship_id (str):
        tradewinds_company_id (UUID):

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        ErrorResponse | ShipResponse
    """

    return (
        await asyncio_detailed(
            ship_id=ship_id,
            client=client,
            tradewinds_company_id=tradewinds_company_id,
        )
    ).parsed
