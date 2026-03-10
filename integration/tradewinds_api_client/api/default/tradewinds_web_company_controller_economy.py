from http import HTTPStatus
from typing import Any
from uuid import UUID

import httpx

from ... import errors
from ...client import AuthenticatedClient, Client
from ...models.company_economy_response import CompanyEconomyResponse
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
        "url": "/api/v1/company/economy",
    }

    _kwargs["headers"] = headers
    return _kwargs


def _parse_response(
    *, client: AuthenticatedClient | Client, response: httpx.Response
) -> CompanyEconomyResponse | ErrorResponse | None:
    if response.status_code == 200:
        response_200 = CompanyEconomyResponse.from_dict(response.json())

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
) -> Response[CompanyEconomyResponse | ErrorResponse]:
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
) -> Response[CompanyEconomyResponse | ErrorResponse]:
    """Get company economy summary

     Returns financial summary and upkeep information for the current company.

    Args:
        tradewinds_company_id (UUID):

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        Response[CompanyEconomyResponse | ErrorResponse]
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
) -> CompanyEconomyResponse | ErrorResponse | None:
    """Get company economy summary

     Returns financial summary and upkeep information for the current company.

    Args:
        tradewinds_company_id (UUID):

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        CompanyEconomyResponse | ErrorResponse
    """

    return sync_detailed(
        client=client,
        tradewinds_company_id=tradewinds_company_id,
    ).parsed


async def asyncio_detailed(
    *,
    client: AuthenticatedClient,
    tradewinds_company_id: UUID,
) -> Response[CompanyEconomyResponse | ErrorResponse]:
    """Get company economy summary

     Returns financial summary and upkeep information for the current company.

    Args:
        tradewinds_company_id (UUID):

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        Response[CompanyEconomyResponse | ErrorResponse]
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
) -> CompanyEconomyResponse | ErrorResponse | None:
    """Get company economy summary

     Returns financial summary and upkeep information for the current company.

    Args:
        tradewinds_company_id (UUID):

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        CompanyEconomyResponse | ErrorResponse
    """

    return (
        await asyncio_detailed(
            client=client,
            tradewinds_company_id=tradewinds_company_id,
        )
    ).parsed
