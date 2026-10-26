# Recovery as a gauge too

This revises ADR 0005, where Recovery was bar-only. Recovery can now also be picked as a gauge, as Stress already could, and it can show on a bar and a gauge at the same time. The gauge shows whole hours with an hourglass icon, and its ring fills against the same recovery peak as the bar, so both always agree.

## Consequences

- A Recovery gauge is a field, so it relocates and can hide behind the hands like any other field.
- Stored `field` values of 2 (Recovery), which used to fall back to the position's default, now show Recovery.
