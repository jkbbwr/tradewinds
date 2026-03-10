from http import HTTPStatus
from typing import Any
from urllib.parse import quote

import httpx

from ... import errors
from ...client import AuthenticatedClient, Client
from ...models.error_response import ErrorResponse
from ...models.shipyard_response import ShipyardResponse
from ...types import Response


def _get_kwargs(
    port_id: str,
) -> dict[str, Any]:

    _kwargs: dict[str, Any] = {
        "method": "get",
        "url": "/api/v1/world/ports/{port_id}/shipyard".format(
            port_id=quote(str(port_id), safe=""),
        ),
    }

    return _kwargs


def _parse_response(
    *, client: AuthenticatedClient | Client, response: httpx.Response
) -> ErrorResponse | ShipyardResponse | None:
    if response.status_code == 200:
        response_200 = ShipyardResponse.from_dict(response.json())

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
) -> Response[ErrorResponse | ShipyardResponse]:
    return Response(
        status_code=HTTPStatus(response.status_code),
        content=response.content,
        headers=response.headers,
        parsed=_parse_response(client=client, response=response),
    )


def sync_detailed(
    port_id: str,
    *,
    client: AuthenticatedClient | Client,
) -> Response[ErrorResponse | ShipyardResponse]:
    """Get shipyard for port

     Returns the shipyard located at a specific port.

    Args:
        port_id (str):

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        Response[ErrorResponse | ShipyardResponse]
    """

    kwargs = _get_kwargs(
        port_id=port_id,
    )

    response = client.get_httpx_client().request(
        **kwargs,
    )

    return _build_response(client=client, response=response)


def sync(
    port_id: str,
    *,
    client: AuthenticatedClient | Client,
) -> ErrorResponse | ShipyardResponse | None:
    """Get shipyard for port

     Returns the shipyard located at a specific port.

    Args:
        port_id (str):

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        ErrorResponse | ShipyardResponse
    """

    return sync_detailed(
        port_id=port_id,
        client=client,
    ).parsed


async def asyncio_detailed(
    port_id: str,
    *,
    client: AuthenticatedClient | Client,
) -> Response[ErrorResponse | ShipyardResponse]:
    """Get shipyard for port

     Returns the shipyard located at a specific port.

    Args:
        port_id (str):

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        Response[ErrorResponse | ShipyardResponse]
    """

    kwargs = _get_kwargs(
        port_id=port_id,
    )

    response = await client.get_async_httpx_client().request(**kwargs)

    return _build_response(client=client, response=response)


async def asyncio(
    port_id: str,
    *,
    client: AuthenticatedClient | Client,
) -> ErrorResponse | ShipyardResponse | None:
    """Get shipyard for port

     Returns the shipyard located at a specific port.

    Args:
        port_id (str):

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        ErrorResponse | ShipyardResponse
    """

    return (
        await asyncio_detailed(
            port_id=port_id,
            client=client,
        )
    ).parsed
