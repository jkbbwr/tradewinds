from http import HTTPStatus
from typing import Any

import httpx

from ... import errors
from ...client import AuthenticatedClient, Client
from ...models.changeset_response import ChangesetResponse
from ...models.company_response import CompanyResponse
from ...models.create_company_request import CreateCompanyRequest
from ...models.error_response import ErrorResponse
from ...types import UNSET, Response, Unset


def _get_kwargs(
    *,
    body: CreateCompanyRequest | Unset = UNSET,
) -> dict[str, Any]:
    headers: dict[str, Any] = {}

    _kwargs: dict[str, Any] = {
        "method": "post",
        "url": "/api/v1/companies",
    }

    if not isinstance(body, Unset):
        _kwargs["json"] = body.to_dict()

    headers["Content-Type"] = "application/json"

    _kwargs["headers"] = headers
    return _kwargs


def _parse_response(
    *, client: AuthenticatedClient | Client, response: httpx.Response
) -> ChangesetResponse | CompanyResponse | ErrorResponse | None:
    if response.status_code == 201:
        response_201 = CompanyResponse.from_dict(response.json())

        return response_201

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
) -> Response[ChangesetResponse | CompanyResponse | ErrorResponse]:
    return Response(
        status_code=HTTPStatus(response.status_code),
        content=response.content,
        headers=response.headers,
        parsed=_parse_response(client=client, response=response),
    )


def sync_detailed(
    *,
    client: AuthenticatedClient,
    body: CreateCompanyRequest | Unset = UNSET,
) -> Response[ChangesetResponse | CompanyResponse | ErrorResponse]:
    """Create a new company

     Creates a new company and assigns the player as its first director.

    Args:
        body (CreateCompanyRequest | Unset): Request body for creating a new company.

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        Response[ChangesetResponse | CompanyResponse | ErrorResponse]
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
    client: AuthenticatedClient,
    body: CreateCompanyRequest | Unset = UNSET,
) -> ChangesetResponse | CompanyResponse | ErrorResponse | None:
    """Create a new company

     Creates a new company and assigns the player as its first director.

    Args:
        body (CreateCompanyRequest | Unset): Request body for creating a new company.

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        ChangesetResponse | CompanyResponse | ErrorResponse
    """

    return sync_detailed(
        client=client,
        body=body,
    ).parsed


async def asyncio_detailed(
    *,
    client: AuthenticatedClient,
    body: CreateCompanyRequest | Unset = UNSET,
) -> Response[ChangesetResponse | CompanyResponse | ErrorResponse]:
    """Create a new company

     Creates a new company and assigns the player as its first director.

    Args:
        body (CreateCompanyRequest | Unset): Request body for creating a new company.

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        Response[ChangesetResponse | CompanyResponse | ErrorResponse]
    """

    kwargs = _get_kwargs(
        body=body,
    )

    response = await client.get_async_httpx_client().request(**kwargs)

    return _build_response(client=client, response=response)


async def asyncio(
    *,
    client: AuthenticatedClient,
    body: CreateCompanyRequest | Unset = UNSET,
) -> ChangesetResponse | CompanyResponse | ErrorResponse | None:
    """Create a new company

     Creates a new company and assigns the player as its first director.

    Args:
        body (CreateCompanyRequest | Unset): Request body for creating a new company.

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        ChangesetResponse | CompanyResponse | ErrorResponse
    """

    return (
        await asyncio_detailed(
            client=client,
            body=body,
        )
    ).parsed
