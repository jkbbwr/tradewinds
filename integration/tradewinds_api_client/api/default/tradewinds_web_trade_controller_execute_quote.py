from http import HTTPStatus
from typing import Any
from uuid import UUID

import httpx

from ... import errors
from ...client import AuthenticatedClient, Client
from ...models.error_response import ErrorResponse
from ...models.execute_quote_request import ExecuteQuoteRequest
from ...models.trade_execution_response import TradeExecutionResponse
from ...types import UNSET, Response, Unset


def _get_kwargs(
    *,
    body: ExecuteQuoteRequest | Unset = UNSET,
    tradewinds_company_id: UUID,
) -> dict[str, Any]:
    headers: dict[str, Any] = {}
    headers["tradewinds-company-id"] = tradewinds_company_id

    _kwargs: dict[str, Any] = {
        "method": "post",
        "url": "/api/v1/trade/quotes/execute",
    }

    if not isinstance(body, Unset):
        _kwargs["json"] = body.to_dict()

    headers["Content-Type"] = "application/json"

    _kwargs["headers"] = headers
    return _kwargs


def _parse_response(
    *, client: AuthenticatedClient | Client, response: httpx.Response
) -> ErrorResponse | TradeExecutionResponse | None:
    if response.status_code == 200:
        response_200 = TradeExecutionResponse.from_dict(response.json())

        return response_200

    if response.status_code == 400:
        response_400 = ErrorResponse.from_dict(response.json())

        return response_400

    if response.status_code == 401:
        response_401 = ErrorResponse.from_dict(response.json())

        return response_401

    if client.raise_on_unexpected_status:
        raise errors.UnexpectedStatus(response.status_code, response.content)
    else:
        return None


def _build_response(
    *, client: AuthenticatedClient | Client, response: httpx.Response
) -> Response[ErrorResponse | TradeExecutionResponse]:
    return Response(
        status_code=HTTPStatus(response.status_code),
        content=response.content,
        headers=response.headers,
        parsed=_parse_response(client=client, response=response),
    )


def sync_detailed(
    *,
    client: AuthenticatedClient,
    body: ExecuteQuoteRequest | Unset = UNSET,
    tradewinds_company_id: UUID,
) -> Response[ErrorResponse | TradeExecutionResponse]:
    """Execute a signed quote

     Executes a trade based on a previously generated quote token.

    Args:
        tradewinds_company_id (UUID):
        body (ExecuteQuoteRequest | Unset): Request to execute a quote.

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        Response[ErrorResponse | TradeExecutionResponse]
    """

    kwargs = _get_kwargs(
        body=body,
        tradewinds_company_id=tradewinds_company_id,
    )

    response = client.get_httpx_client().request(
        **kwargs,
    )

    return _build_response(client=client, response=response)


def sync(
    *,
    client: AuthenticatedClient,
    body: ExecuteQuoteRequest | Unset = UNSET,
    tradewinds_company_id: UUID,
) -> ErrorResponse | TradeExecutionResponse | None:
    """Execute a signed quote

     Executes a trade based on a previously generated quote token.

    Args:
        tradewinds_company_id (UUID):
        body (ExecuteQuoteRequest | Unset): Request to execute a quote.

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        ErrorResponse | TradeExecutionResponse
    """

    return sync_detailed(
        client=client,
        body=body,
        tradewinds_company_id=tradewinds_company_id,
    ).parsed


async def asyncio_detailed(
    *,
    client: AuthenticatedClient,
    body: ExecuteQuoteRequest | Unset = UNSET,
    tradewinds_company_id: UUID,
) -> Response[ErrorResponse | TradeExecutionResponse]:
    """Execute a signed quote

     Executes a trade based on a previously generated quote token.

    Args:
        tradewinds_company_id (UUID):
        body (ExecuteQuoteRequest | Unset): Request to execute a quote.

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        Response[ErrorResponse | TradeExecutionResponse]
    """

    kwargs = _get_kwargs(
        body=body,
        tradewinds_company_id=tradewinds_company_id,
    )

    response = await client.get_async_httpx_client().request(**kwargs)

    return _build_response(client=client, response=response)


async def asyncio(
    *,
    client: AuthenticatedClient,
    body: ExecuteQuoteRequest | Unset = UNSET,
    tradewinds_company_id: UUID,
) -> ErrorResponse | TradeExecutionResponse | None:
    """Execute a signed quote

     Executes a trade based on a previously generated quote token.

    Args:
        tradewinds_company_id (UUID):
        body (ExecuteQuoteRequest | Unset): Request to execute a quote.

    Raises:
        errors.UnexpectedStatus: If the server returns an undocumented status code and Client.raise_on_unexpected_status is True.
        httpx.TimeoutException: If the request takes longer than Client.timeout.

    Returns:
        ErrorResponse | TradeExecutionResponse
    """

    return (
        await asyncio_detailed(
            client=client,
            body=body,
            tradewinds_company_id=tradewinds_company_id,
        )
    ).parsed
