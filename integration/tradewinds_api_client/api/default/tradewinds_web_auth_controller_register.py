from http import HTTPStatus
from typing import Any

import httpx

from ... import errors
from ...client import AuthenticatedClient, Client
from ...models.changeset_response import ChangesetResponse
from ...models.register_request import RegisterRequest
from ...models.register_response import RegisterResponse
from ...types import UNSET, Response, Unset


def _get_kwargs(
    *,
    body: RegisterRequest | Unset = UNSET,
) -> dict[str, Any]:
    headers: dict[str, Any] = {}

    _kwargs: dict[str, Any] = {
        "method": "post",
        "url": "/api/v1/auth/register",
    }

    if not isinstance(body, Unset):
        _kwargs["json"] = body.to_dict()

    headers["Content-Type"] = "application/json"

    _kwargs["headers"] = headers
    return _kwargs


def _parse_response(
    *, client: AuthenticatedClient | Client, response: httpx.Response
) -> ChangesetResponse | RegisterResponse | None:
    if response.status_code == 201:
        response_201 = RegisterResponse.from_dict(response.json())

        return response_201

    if response.status_code == 422:
        response_422 = ChangesetResponse.from_dict(response.json())

        return response_422

    if client.raise_on_unexpected_status:
        raise errors.UnexpectedStatus(response.status_code, response.content)
    else:
        return None


def _build_response(
    *, client: AuthenticatedClient | Client, response: httpx.Response
) -> Response[ChangesetResponse | RegisterResponse]:
    return Response(
        status_code=HTTPStatus(response.status_code),
        content=response.content,
        headers=response.headers,
        parsed=_parse_response(client=client, response=response),
    )


def sync_detailed(
    *,
    client: AuthenticatedClient | Client,
    body: RegisterRequest | Unset = UNSET,
) -> Response[ChangesetResponse | RegisterResponse]:
    """Register a new player

     Creates a new player account with the provided details.

    Args:
        body (RegisterRequest | Unset): Request schema for player registration Example:
            {'discord_id': '1234567890', 'email': 'kibb@example.com', 'name': 'Kibb', 'password':
            'password123'}.

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        Response[ChangesetResponse | RegisterResponse]
    """

    kwargs = _get_kwargs(
        body=body,
    )

    response = client.get_httpx_client().request(
        **kwargs,
    )

    return _build_response(client=client, response=response)


def sync(
    *,
    client: AuthenticatedClient | Client,
    body: RegisterRequest | Unset = UNSET,
) -> ChangesetResponse | RegisterResponse | None:
    """Register a new player

     Creates a new player account with the provided details.

    Args:
        body (RegisterRequest | Unset): Request schema for player registration Example:
            {'discord_id': '1234567890', 'email': 'kibb@example.com', 'name': 'Kibb', 'password':
            'password123'}.

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        ChangesetResponse | RegisterResponse
    """

    return sync_detailed(
        client=client,
        body=body,
    ).parsed


async def asyncio_detailed(
    *,
    client: AuthenticatedClient | Client,
    body: RegisterRequest | Unset = UNSET,
) -> Response[ChangesetResponse | RegisterResponse]:
    """Register a new player

     Creates a new player account with the provided details.

    Args:
        body (RegisterRequest | Unset): Request schema for player registration Example:
            {'discord_id': '1234567890', 'email': 'kibb@example.com', 'name': 'Kibb', 'password':
            'password123'}.

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        Response[ChangesetResponse | RegisterResponse]
    """

    kwargs = _get_kwargs(
        body=body,
    )

    response = await client.get_async_httpx_client().request(**kwargs)

    return _build_response(client=client, response=response)


async def asyncio(
    *,
    client: AuthenticatedClient | Client,
    body: RegisterRequest | Unset = UNSET,
) -> ChangesetResponse | RegisterResponse | None:
    """Register a new player

     Creates a new player account with the provided details.

    Args:
        body (RegisterRequest | Unset): Request schema for player registration Example:
            {'discord_id': '1234567890', 'email': 'kibb@example.com', 'name': 'Kibb', 'password':
            'password123'}.

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        ChangesetResponse | RegisterResponse
    """

    return (
        await asyncio_detailed(
            client=client,
            body=body,
        )
    ).parsed
