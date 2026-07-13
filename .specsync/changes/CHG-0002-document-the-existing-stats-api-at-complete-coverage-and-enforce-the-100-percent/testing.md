---
change: CHG-0002-document-the-existing-stats-api-at-complete-coverage-and-enforce-the-100-percent
artifact: testing
---

# Testing

- `StatisticsTests.swift`: REQ-stats-001.
- `PercentileTests.swift`: REQ-stats-002.
- `HistogramTests.swift`: REQ-stats-003.
- `CorrelationTests.swift`: REQ-stats-004.
- `DistributionTests.swift`: REQ-stats-005.
- `RandomSourceTests.swift`: REQ-stats-006.
- `RegressionTests.swift`: REQ-stats-007 and REQ-stats-008.
- Source review only, explicitly not native-test evidence: REQ-stats-009, REQ-stats-010, REQ-stats-011.

Verification commands are strict SpecSync at 100, `specsync agents status`, `fledge lanes run verify`,
`fledge trust doctor`, and `fledge trust verify`.
