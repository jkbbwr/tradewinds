from http import HTTPStatus
from typing import Any
from uuid import UUID

import httpx

from ... import errors
from ...client import AuthenticatedClient, Client
from ...models.company_response import CompanyResponse
from ...models.error_response import ErrorResponse
from ...types import Response


def _get_kwargs(
    *,
    tradewinds_company_id: UUID,
) -> dict[str, Any]:
    headers: dict[str, Any] = {}
    headers["tradewinds-company-id"] = tradewinds_company_id

    _kwargs: dict[str, Any] = {
        "method": "get",
        "url": "/api/v1/company",
    }

    _kwargs["headers"] = headers
    return _kwargs


def _parse_response(
    *, client: AuthenticatedClient | Client, response: httpx.Response
) -> CompanyResponse | ErrorResponse | None:
    if response.status_code == 200:
        response_200 = CompanyResponse.from_dict(response.json())

        return response_200

    if response.status_code == 401:
        response_401 = ErrorResponse.from_dict(response.json())

        return response_401

    if response.status_code == 403:
        response_403 = ErrorResponse.from_dict(response.json())

        return response_403

    if client.raise_on_unexpected_status:
        raise errors.UnexpectedStatus(response.status_code, response.content)
    else:
        return None


def _build_response(
    *, client: AuthenticatedClient | Client, response: httpx.Response
) -> Response[CompanyResponse | ErrorResponse]:
    return Response(
        status_code=HTTPStatus(response.status_code),
        content=response.content,
        headers=response.headers,
        parsed=_parse_response(client=client, response=response),
    )


def sync_detailed(
    *,
    client: AuthenticatedClient,
    tradewinds_company_id: UUID,
) -> Response[CompanyResponse | ErrorResponse]:
    """Get current company

     Returns the details of the company specified in the 'tradewinds-company-id' header.

    Args:
        tradewinds_company_id (UUID):

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        Response[CompanyResponse | ErrorResponse]
    """

    kwargs = _get_kwargs(
        tradewinds_company_id=tradewinds_company_id,
    )

    response = client.get_httpx_client().request(
        **kwargs,
    )

    return _build_response(client=client, response=response)


def sync(
    *,
    client: AuthenticatedClient,
    tradewinds_company_id: UUID,
) -> CompanyResponse | ErrorResponse | None:
    """Get current company

     Returns the details of the company specified in the 'tradewinds-company-id' header.

    Args:
        tradewinds_company_id (UUID):

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        CompanyResponse | ErrorResponse
    """

    return sync_detailed(
        client=client,
        tradewinds_company_id=tradewinds_company_id,
    ).parsed


async def asyncio_detailed(
    *,
    client: AuthenticatedClient,
    tradewinds_company_id: UUID,
) -> Response[CompanyResponse | ErrorResponse]:
    """Get current company

     Returns the details of the company specified in the 'tradewinds-company-id' header.

    Args:
        tradewinds_company_id (UUID):

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        Response[CompanyResponse | ErrorResponse]
    """

    kwargs = _get_kwargs(
        tradewinds_company_id=tradewinds_company_id,
    )

    response = await client.get_async_httpx_client().request(**kwargs)

    return _build_response(client=client, response=response)


async def asyncio(
    *,
    client: AuthenticatedClient,
    tradewinds_company_id: UUID,
) -> CompanyResponse | ErrorResponse | None:
    """Get current company

     Returns the details of the company specified in the 'tradewinds-company-id' header.

    Args:
        tradewinds_company_id (UUID):

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        CompanyResponse | ErrorResponse
    """

    return (
        await asyncio_detailed(
            client=client,
            tradewinds_company_id=tradewinds_company_id,
        )
    ).parsed
