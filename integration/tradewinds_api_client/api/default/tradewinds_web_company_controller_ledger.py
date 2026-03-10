from http import HTTPStatus
from typing import Any
from uuid import UUID

import httpx

from ... import errors
from ...client import AuthenticatedClient, Client
from ...models.error_response import ErrorResponse
from ...models.ledger_response import LedgerResponse
from ...types import UNSET, Response, Unset


def _get_kwargs(
    *,
    after: str | Unset = UNSET,
    before: str | Unset = UNSET,
    limit: int | Unset = UNSET,
    tradewinds_company_id: UUID,
) -> dict[str, Any]:
    headers: dict[str, Any] = {}
    headers["tradewinds-company-id"] = tradewinds_company_id

    params: dict[str, Any] = {}

    params["after"] = after

    params["before"] = before

    params["limit"] = limit

    params = {k: v for k, v in params.items() if v is not UNSET and v is not None}

    _kwargs: dict[str, Any] = {
        "method": "get",
        "url": "/api/v1/company/ledger",
        "params": params,
    }

    _kwargs["headers"] = headers
    return _kwargs


def _parse_response(
    *, client: AuthenticatedClient | Client, response: httpx.Response
) -> ErrorResponse | LedgerResponse | None:
    if response.status_code == 200:
        response_200 = LedgerResponse.from_dict(response.json())

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
) -> Response[ErrorResponse | LedgerResponse]:
    return Response(
        status_code=HTTPStatus(response.status_code),
        content=response.content,
        headers=response.headers,
        parsed=_parse_response(client=client, response=response),
    )


def sync_detailed(
    *,
    client: AuthenticatedClient,
    after: str | Unset = UNSET,
    before: str | Unset = UNSET,
    limit: int | Unset = UNSET,
    tradewinds_company_id: UUID,
) -> Response[ErrorResponse | LedgerResponse]:
    """Get company ledger

     Returns the financial ledger entries for the current company, ordered by most recent first.

    Args:
        after (str | Unset):
        before (str | Unset):
        limit (int | Unset):
        tradewinds_company_id (UUID):

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        Response[ErrorResponse | LedgerResponse]
    """

    kwargs = _get_kwargs(
        after=after,
        before=before,
        limit=limit,
        tradewinds_company_id=tradewinds_company_id,
    )

    response = client.get_httpx_client().request(
        **kwargs,
    )

    return _build_response(client=client, response=response)


def sync(
    *,
    client: AuthenticatedClient,
    after: str | Unset = UNSET,
    before: str | Unset = UNSET,
    limit: int | Unset = UNSET,
    tradewinds_company_id: UUID,
) -> ErrorResponse | LedgerResponse | None:
    """Get company ledger

     Returns the financial ledger entries for the current company, ordered by most recent first.

    Args:
        after (str | Unset):
        before (str | Unset):
        limit (int | Unset):
        tradewinds_company_id (UUID):

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        ErrorResponse | LedgerResponse
    """

    return sync_detailed(
        client=client,
        after=after,
        before=before,
        limit=limit,
        tradewinds_company_id=tradewinds_company_id,
    ).parsed


async def asyncio_detailed(
    *,
    client: AuthenticatedClient,
    after: str | Unset = UNSET,
    before: str | Unset = UNSET,
    limit: int | Unset = UNSET,
    tradewinds_company_id: UUID,
) -> Response[ErrorResponse | LedgerResponse]:
    """Get company ledger

     Returns the financial ledger entries for the current company, ordered by most recent first.

    Args:
        after (str | Unset):
        before (str | Unset):
        limit (int | Unset):
        tradewinds_company_id (UUID):

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        Response[ErrorResponse | LedgerResponse]
    """

    kwargs = _get_kwargs(
        after=after,
        before=before,
        limit=limit,
        tradewinds_company_id=tradewinds_company_id,
    )

    response = await client.get_async_httpx_client().request(**kwargs)

    return _build_response(client=client, response=response)


async def asyncio(
    *,
    client: AuthenticatedClient,
    after: str | Unset = UNSET,
    before: str | Unset = UNSET,
    limit: int | Unset = UNSET,
    tradewinds_company_id: UUID,
) -> ErrorResponse | LedgerResponse | None:
    """Get company ledger

     Returns the financial ledger entries for the current company, ordered by most recent first.

    Args:
        after (str | Unset):
        before (str | Unset):
        limit (int | Unset):
        tradewinds_company_id (UUID):

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        ErrorResponse | LedgerResponse
    """

    return (
        await asyncio_detailed(
            client=client,
            after=after,
            before=before,
            limit=limit,
            tradewinds_company_id=tradewinds_company_id,
        )
    ).parsed
