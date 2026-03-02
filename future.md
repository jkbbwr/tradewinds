List of things I want to add in the future

- [ ] State driven taxes / banking

## Milestone ? - Insurance: event-driven risk pools

- [ ] Implement `insurance_policy` persistence (insurer_id, insured_id, subject_ref, premium, coverage_max, end_tick, status)
- [ ] Implement policy creation (scope auth, atomic ledger deduct premium from insured -> credit insurer)
- [ ] Implement event interceptors (hook into `Fleet` loss events like ship sunk, cargo lost)
- [ ] Implement claim trigger (find active policy for `subject_ref` upon loss event)
- [ ] Implement claim settlement (atomic ledger deduct from insurer -> credit insured up to `coverage_max`, mark settled)
- [ ] Implement policy expiry sweep (mark policies expired if `current_tick > end_tick` and no claims filed)
