from http import HTTPStatus
from typing import Any

import httpx

from ... import errors
from ...client import AuthenticatedClient, Client
from ...models.changeset_response import ChangesetResponse
from ...models.error_response import ErrorResponse
from ...models.login_request import LoginRequest
from ...models.login_response import LoginResponse
from ...types import UNSET, Response, Unset


def _get_kwargs(
    *,
    body: LoginRequest | Unset = UNSET,
) -> dict[str, Any]:
    headers: dict[str, Any] = {}

    _kwargs: dict[str, Any] = {
        "method": "post",
        "url": "/api/v1/auth/login",
    }

    if not isinstance(body, Unset):
        _kwargs["json"] = body.to_dict()

    headers["Content-Type"] = "application/json"

    _kwargs["headers"] = headers
    return _kwargs


def _parse_response(
    *, client: AuthenticatedClient | Client, response: httpx.Response
) -> ChangesetResponse | ErrorResponse | LoginResponse | None:
    if response.status_code == 200:
        response_200 = LoginResponse.from_dict(response.json())

        return response_200

    if response.status_code == 401:
        response_401 = ErrorResponse.from_dict(response.json())

        return response_401

    if response.status_code == 422:
        response_422 = ChangesetResponse.from_dict(response.json())

        return response_422

    if client.raise_on_unexpected_status:
        raise errors.UnexpectedStatus(response.status_code, response.content)
    else:
        return None


def _build_response(
    *, client: AuthenticatedClient | Client, response: httpx.Response
) -> Response[ChangesetResponse | ErrorResponse | LoginResponse]:
    return Response(
        status_code=HTTPStatus(response.status_code),
        content=response.content,
        headers=response.headers,
        parsed=_parse_response(client=client, response=response),
    )


def sync_detailed(
    *,
    client: AuthenticatedClient | Client,
    body: LoginRequest | Unset = UNSET,
) -> Response[ChangesetResponse | ErrorResponse | LoginResponse]:
    """Login player

     Authenticates a player and returns a JWT token for subsequent API calls.

    Args:
        body (LoginRequest | Unset): Request schema for player login Example: {'email':
            'kibb@example.com', 'password': 'password123'}.

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        Response[ChangesetResponse | ErrorResponse | LoginResponse]
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
    body: LoginRequest | Unset = UNSET,
) -> ChangesetResponse | ErrorResponse | LoginResponse | None:
    """Login player

     Authenticates a player and returns a JWT token for subsequent API calls.

    Args:
        body (LoginRequest | Unset): Request schema for player login Example: {'email':
            'kibb@example.com', 'password': 'password123'}.

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        ChangesetResponse | ErrorResponse | LoginResponse
    """

    return sync_detailed(
        client=client,
        body=body,
    ).parsed


async def asyncio_detailed(
    *,
    client: AuthenticatedClient | Client,
    body: LoginRequest | Unset = UNSET,
) -> Response[ChangesetResponse | ErrorResponse | LoginResponse]:
    """Login player

     Authenticates a player and returns a JWT token for subsequent API calls.

    Args:
        body (LoginRequest | Unset): Request schema for player login Example: {'email':
            'kibb@example.com', 'password': 'password123'}.

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        Response[ChangesetResponse | ErrorResponse | LoginResponse]
    """

    kwargs = _get_kwargs(
        body=body,
    )

    response = await client.get_async_httpx_client().request(**kwargs)

    return _build_response(client=client, response=response)


async def asyncio(
    *,
    client: AuthenticatedClient | Client,
    body: LoginRequest | Unset = UNSET,
) -> ChangesetResponse | ErrorResponse | LoginResponse | None:
    """Login player

     Authenticates a player and returns a JWT token for subsequent API calls.

    Args:
        body (LoginRequest | Unset): Request schema for player login Example: {'email':
            'kibb@example.com', 'password': 'password123'}.

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        ChangesetResponse | ErrorResponse | LoginResponse
    """

    return (
        await asyncio_detailed(
            client=client,
            body=body,
        )
    ).parsed
