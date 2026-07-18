# Thrust-Stand Labs (Exp 09 & 10) — Validation Protocol

Purpose: prove the labs work end-to-end on real hardware **before**
committing to the full 15-station buy. One prototype station, run by
instructor + TAs playing students, against explicit go/no-go criteria.
Budget exposure at this stage: one station ≈ $130 + rig stock.

## Phase 0 — Prototype procurement (1 order)

- [ ] 2× motor, 1× ESC, 2× each prop, 2× load cell, 1× AD620 module,
      1× ACS712-20A, 1× 12 V/10 A supply, kill switch + fuse, connectors
      (pull quantities/specs from `ME3300_ThrustLab_BOM.xlsx`)
- [ ] Fabricate one rig per `Rig_Design_Brief.md`
- [ ] Run the brief's **acceptance tests** table; record results in this doc

## Phase 1 — Hardware bring-up (instructor, ~half day)

- [ ] AD620 gain set (≈200) and fixed; 500 g → ≈ 0.5 V above tare confirmed
- [ ] Motor direction verified (exhaust UP); phase wiring color-coded
- [ ] ESC deadband measured (record: ____ %); arming behavior documented
- [ ] `set_throttle()` verified against the real device: scope DIO-0 in
      WaveForms first (pulse width vs. commanded %), then via pydwf.
      **This is the highest-risk software item — do it first.**
- [ ] Full sweep to 70% on both props: log max bus current (must be < 8 A),
      max motor temp after 3 consecutive sweeps (should be touchable, < 60 °C)
- [ ] Buffer check: 5 s × 1 kHz × 2 channels acquisition completes (Lab 10
      hover record is the largest single capture)

## Phase 2 — TA dry run, Lab 09 (2 TAs as a team, timed, ≤ 2 h)

Run the manual verbatim; do not shortcut. Log wall-clock time per part:

| Part | Budgeted | Actual | Notes |
|------|----------|--------|-------|
| 1 Wire & verify | 25 min | | |
| 2 Arm & first spin | 10 min | | |
| 3 Dead-weight calibration | 20 min | | |
| 4 Tare + 6 sweeps + prop swap | 30 min | | |
| 5 Analysis through thrust curves | 25 min | | |
| 6 Design point | 10 min | | buffer: 10 min |

Go/no-go criteria:

- [ ] Calibration: residuals < 5 mN RMS, c1 within 20% of the design value
- [ ] Run-to-run thrust repeatability at 50%: CI half-width < 5 g
- [ ] Both props clearly separated on the thrust plot (curves don't cross
      inside their CIs above 30%)
- [ ] Momentum fit visibly linear; FM lands in 0.25–0.55
- [ ] Hover throttle lands in 30–50% (design problem is solvable mid-curve)
- [ ] Team finished in ≤ 2 h including analysis figures

## Phase 3 — TA dry run, Lab 10 (same team, ≤ 2 h)

| Part | Budgeted | Actual | Notes |
|------|----------|--------|-------|
| 1 Checkout + tare | 15 min | | |
| 2 Tap test ×3 + analysis | 30 min | | |
| 3 Steps ×6 + analysis | 35 min | | |
| 4 Bandwidth separation | 10 min | | |
| 5 Hover verification | 20 min | | buffer: 10 min |

Go/no-go criteria:

- [ ] Tap test: fn ≥ 35 Hz, ζ in 0.02–0.08, ≥ 8 clean peaks with the
      manual's exact `find_peaks` arguments (if the arguments need tuning,
      update BOTH the manual and the synthetic data generator)
- [ ] Step response: log-linear fit visibly straight; τ_up in 30–120 ms;
      τ CI half-width < 30% of τ
- [ ] Down-step slower than up-step (the asymmetry discussion depends on it)
- [ ] Separation ratio ≥ 8× (else revisit rig stiffness before scaling)
- [ ] Hover verification: measured mean within ±8% of the Lab-09 predicted
      value (this validates cross-lab consistency, the capstone claim)
- [ ] ≤ 2 h wall clock

## Phase 4 — Content sync after hardware truth

- [ ] Update the synthetic data generators' constants to match the real
      station's measured ranges (chain gain, tare, current levels, fn, ζ, τ)
      and re-run: generator → solution notebooks → figure sync → re-render
      manuals (the pipeline is scripted; ask Claude to re-run it)
- [ ] Replace the 4 screenshot placeholders with real annotated images
- [ ] Any threshold that needed hand-tuning on real data (`height`,
      `distance`, step-detect level, fit window) gets the manual's
      "designed against noise" numbers updated to the real values
- [ ] TAs list every point of confusion in the manuals → revision pass

## Phase 5 — Decision gate

Proceed to the 15-station buy only if: all Phase 2/3 go/no-go boxes
checked, total per-station cost confirmed ≤ $150, and both TAs agree a
first-time student team finishes each lab in 2 h. Otherwise: fix, re-run
the failing phase, or descope (Lab 09 alone is a complete, self-contained
lab if Lab 10 slips a semester — per the two-semester rollout plan).

## Demo unit (optional tier)

If the class demo is funded: acquire the Crazyflie + Flow deck + a mesh
enclosure, and validate a 60-second netted hover + push-recovery demo as
part of Phase 3. The demo script lives in Lab 10 manual @sec-real-drone.
