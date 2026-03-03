List of things I want to add in the future

- [ ] State driven taxes / banking

---

## Milestone ? - Insurance: event-driven risk pools

- [ ] Implement `insurance_policy` persistence (insurer_id, insured_id, subject_ref, premium, coverage_max, end_tick, status)
- [ ] Implement policy creation (scope auth, atomic ledger deduct premium from insured -> credit insurer)
- [ ] Implement event interceptors (hook into `Fleet` loss events like ship sunk, cargo lost)
- [ ] Implement claim trigger (find active policy for `subject_ref` upon loss event)
- [ ] Implement claim settlement (atomic ledger deduct from insurer -> credit insured up to `coverage_max`, mark settled)
- [ ] Implement policy expiry sweep (mark policies expired if `current_tick > end_tick` and no claims filed)

---

## Milestone 12 — Quotes: short-lived price promises (soft lock)

- [ ] Implement `npc_quote` persistence (market_id, company_id, quoted_price, max_qty, expires_tick)
- [ ] Implement quote generation (snapshot current NPC price, set expiry to current_tick + 5)
- [ ] Implement quote exercise (scope auth, verify `current_tick <= expires_tick`)
- [ ] Implement dynamic stock check on exercise (honor up to available `npc_market.stock`, allow partial fill)
- [ ] Implement settlement for exercised quote (atomic ledger debit, inventory credit, stock deduct)

---

## Milestone 13 — Options: transferable quotes

- [ ] Add `owner_id` (company) and `transfer_count` (integer) to `npc_quote`
- [ ] Implement option list/read (view quotes owned by others open for sale)
- [ ] Implement option transfer/purchase (scope auth, check `transfer_count < max_transfers`)
- [ ] Implement premium settlement for transfer (atomic ledger debit buyer -> credit seller)
- [ ] Implement ownership re-assignment + increment `transfer_count`
- [ ] Update quote exercise logic to validate current `owner_id`

---

## Milestone 14 — Futures: deferred delivery contracts

- [ ] Implement `future_contract` persistence (buyer_id, seller_id, port_id, good_id, qty, price, maturity_tick, collateral)
- [ ] Implement contract creation (scope auth both parties, agree on terms)
- [ ] Implement collateral escrow (atomic ledger deduct from both buyer and seller on creation)
- [ ] Implement successful settlement (atomic transfer of goods/credits at agreed price, refund collateral)
- [ ] Implement default settlement (if funds/goods missing: forfeit collateral to victim, void contract)

---
