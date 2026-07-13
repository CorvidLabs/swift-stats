---
spec: stats.spec.md
---

## Tasks

- [x] Map all 17 Stats implementation files.
- [x] Inventory all 105 distinct public exports.
- [x] Document descriptive, correlation, distribution, random, regression, hypothesis, interval, and error contracts.
- [x] Assign stable requirement IDs and link existing native evidence.

## Gaps

TTest and ChiSquaredTest do not currently have dedicated native test files. Their implemented behavior is documented
without claiming test coverage; adding focused numerical tests is a follow-up product-quality task, not part of this
governance-only PR.

## Review Sign-offs

- **Product**: not applicable; behavior is unchanged
- **QA**: native package tests plus hosted Trust
- **Design**: not applicable
- **Dev**: contract checked against all mapped implementation files
