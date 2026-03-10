# Tradewinds REST API Plan

This document describes the main HTTP API surface for Tradewinds.

The API is mostly resource-oriented, but it intentionally uses action-style endpoints where that better matches gameplay operations such as transit, cargo transfer, quoting, and trade execution.

Admin and internal routes are intentionally omitted here.

## Base URL

All routes are under:

- `/api/v1`

## Authentication

Authenticated requests use:

- `Authorization: Bearer <token>`

## Company Context

Most game actions operate in the context of a specific company. Those routes also require:

- `Tradewinds-Company-Id: <company_uuid>`

The authenticated player must be a director of that company.

## Health and Status Semantics

The health endpoint is public and reports:

- database connectivity
- Oban lag
- overall status

Suggested interpretation:

- `healthy`: database connected and queue lag within acceptable threshold
- `degraded`: database connected, but job lag is too high
- `unhealthy`: hard dependency failure such as database outage

---

# Route Groups

## Auth

No company header required.

### `POST /api/v1/auth/register`

Register a new player.

### `POST /api/v1/auth/login`

Authenticate a player and return a bearer token.

### `POST /api/v1/auth/revoke`

Revoke the current token.

Requires:

- `Authorization`

---

## Session

Authenticated, but no company header required.

### `GET /api/v1/me`

Return information about the current player/session.

### `GET /api/v1/me/companies`

List companies the current player may act on behalf of.

Requires:

- `Authorization`

---

## Health

Public.

### `GET /api/v1/health`

Return service health, database connectivity, queue lag, and server time.

---

## Companies

### `POST /api/v1/companies`

Create a new company.

Requires:

- `Authorization`

### `GET /api/v1/company`

Return the currently selected company.

Requires:

- `Authorization`
- `Tradewinds-Company-Id`

### `GET /api/v1/company/economy`

Return a company economy summary such as treasury, reputation, and upkeep-related information.

Requires:

- `Authorization`
- `Tradewinds-Company-Id`

### `GET /api/v1/company/ledger`

Return the selected company's ledger entries and transaction history.

Suggested query params:

- `limit`
- `before`
- `after`
- `reason`
- `reference_type`

Requires:

- `Authorization`
- `Tradewinds-Company-Id`

---

## World

Read-only reference data. No company header required.

### `GET /api/v1/world/ports`

List ports.

### `GET /api/v1/world/ports/:id`

Fetch a single port.

### `GET /api/v1/world/ports/:port_id/shipyard`

Fetch the shipyard for a given port.

### `GET /api/v1/world/goods`

List goods.

### `GET /api/v1/world/goods/:id`

Fetch a single good.

### `GET /api/v1/world/ship-types`

List ship types.

### `GET /api/v1/world/ship-types/:id`

Fetch a single ship type.

### `GET /api/v1/world/routes/:id`

Fetch a single route.

---

## Shipyards

### `GET /api/v1/shipyards/:shipyard_id/inventory`

List ships currently available for purchase at a shipyard.

No company header required.

### `POST /api/v1/shipyards/:shipyard_id/purchase`

Purchase a ship from a shipyard for the selected company.

Requires:

- `Authorization`
- `Tradewinds-Company-Id`

Suggested body:

- `ship_type_id`

---

## Ships

All ship routes are company-scoped.

### `GET /api/v1/ships`

List ships owned by the selected company.

### `GET /api/v1/ships/:ship_id`

Fetch a single ship and its current state.

### `PATCH /api/v1/ships/:ship_id`

Rename a ship.

Suggested body:

- `name`

### `POST /api/v1/ships/:ship_id/transit`

Send a docked ship onto a route.

Suggested body:

- `route_id`

### `POST /api/v1/ships/:ship_id/transfer-to-warehouse`

Move cargo from a ship into a warehouse at the same port.

Suggested body:

- `warehouse_id`
- `good_id`
- `quantity`

Requires for all routes in this section:

- `Authorization`
- `Tradewinds-Company-Id`

---

## Warehouses

All warehouse routes are company-scoped.

### `GET /api/v1/warehouses`

List warehouses owned by the selected company.

### `GET /api/v1/warehouses/:warehouse_id`

Fetch a single warehouse and its inventory.

### `POST /api/v1/warehouses/:warehouse_id/grow`

Upgrade a warehouse.

### `POST /api/v1/warehouses/:warehouse_id/shrink`

Downgrade a warehouse.

### `POST /api/v1/warehouses/:warehouse_id/transfer-to-ship`

Move cargo from a warehouse into a ship at the same port.

Suggested body:

- `ship_id`
- `good_id`
- `quantity`

Requires for all routes in this section:

- `Authorization`
- `Tradewinds-Company-Id`

---

## Trade

This namespace is for direct trading against NPC/system liquidity, distinct from the player order book in `market`.

All trade routes are company-scoped.

### `POST /api/v1/trade/quote`

Generate a signed trade quote.

Suggested body:

- `port_id`
- `good_id`
- `action` (`buy` or `sell`)
- `quantity`

### `POST /api/v1/trade/quotes/execute`

Execute a previously issued quote.

Suggested body:

- `token`
- `destinations`

`destinations` distributes cargo across ships and/or warehouses as supported by the application.

### `POST /api/v1/trade/execute`

Execute an immediate trade without a quote.

Suggested body:

- `port_id`
- `good_id`
- `action`
- `destinations`

Requires for all routes in this section:

- `Authorization`
- `Tradewinds-Company-Id`

---

## Market

This namespace is for the player-to-player order book.

### `GET /api/v1/market/orders`

List open market orders.

Suggested query params:

- `port_id`
- `good_id`
- `side`

No company header required.

### `GET /api/v1/market/blended-price`

Calculate the blended price for a requested quantity from the available order book.

Suggested query params:

- `port_id`
- `good_id`
- `side`
- `quantity`

No company header required.

### `POST /api/v1/market/orders`

Create a new market order.

Suggested body:

- `port_id`
- `good_id`
- `side`
- `price`
- `total`

### `POST /api/v1/market/orders/:order_id/fill`

Fill an existing market order.

Suggested body:

- `quantity`

### `DELETE /api/v1/market/orders/:order_id`

Cancel an order owned by the selected company.

Requires for mutating routes in this section:

- `Authorization`
- `Tradewinds-Company-Id`

---

# Complete Route List

## Public or non-company-scoped

- `POST /api/v1/auth/register`
- `POST /api/v1/auth/login`
- `POST /api/v1/auth/revoke`
- `GET /api/v1/health`
- `GET /api/v1/me`
- `GET /api/v1/me/companies`
- `POST /api/v1/companies`
- `GET /api/v1/world/ports`
- `GET /api/v1/world/ports/:id`
- `GET /api/v1/world/ports/:port_id/shipyard`
- `GET /api/v1/world/goods`
- `GET /api/v1/world/goods/:id`
- `GET /api/v1/world/ship-types`
- `GET /api/v1/world/ship-types/:id`
- `GET /api/v1/world/routes/:id`
- `GET /api/v1/shipyards/:shipyard_id/inventory`
- `GET /api/v1/market/orders`
- `GET /api/v1/market/blended-price`

## Requires `Tradewinds-Company-Id`

- `GET /api/v1/company`
- `GET /api/v1/company/economy`
- `GET /api/v1/company/ledger`
- `POST /api/v1/shipyards/:shipyard_id/purchase`
- `GET /api/v1/ships`
- `GET /api/v1/ships/:ship_id`
- `PATCH /api/v1/ships/:ship_id`
- `POST /api/v1/ships/:ship_id/transit`
- `POST /api/v1/ships/:ship_id/transfer-to-warehouse`
- `GET /api/v1/warehouses`
- `GET /api/v1/warehouses/:warehouse_id`
- `POST /api/v1/warehouses/:warehouse_id/grow`
- `POST /api/v1/warehouses/:warehouse_id/shrink`
- `POST /api/v1/warehouses/:warehouse_id/transfer-to-ship`
- `POST /api/v1/trade/quote`
- `POST /api/v1/trade/quotes/execute`
- `POST /api/v1/trade/execute`
- `POST /api/v1/market/orders`
- `POST /api/v1/market/orders/:order_id/fill`
- `DELETE /api/v1/market/orders/:order_id`

---

# Notes

- Route naming is client-facing and should stay simple even where the internal domain context names differ.
- `ships` is preferred over `fleet` at the HTTP layer.
- `trade` is used for NPC/system trading to keep it distinct from `market`, which is the player order book.
- Resource reads remain more REST-like, while game actions use explicit action endpoints where that improves clarity.
