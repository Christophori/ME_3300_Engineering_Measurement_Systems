# ME 3300 Thrust-Stand Rig — Design Brief (Instructor/Shop)

One rig per station, 15 + 1 shop spare. Used by Experiment 09 (static
thrust/current curves) and Experiment 10 (tap test, step response, hover
verification) with zero configuration change between labs.

## Concept

Vertical-axis thrust stand: a 1 kg bar load cell cantilevered from a rigid
post; the motor sits on a platform bolted to the cell's free end, **thrust
axis vertical, exhaust up**. Thrust presses the cell in the same direction
gravity does, so dead-weight calibration masses load the chain *exactly*
like thrust — that identity is the pedagogical core of Lab 09 Part-3, and
it is the reason for the orientation. Exhaust-up also throws the jet into
free air instead of at the bench.

```
            ~~~ jet up ~~~
              ║  prop (guard ring around it)
            [motor]
         [mass platform]          <- masses stack here, prop off
        ═[load cell bar]═╗
                         ║ post
                     [base plate]──clamp──> bench
```

## Functional requirements

1. Survive 3 N continuous thrust + 5 N abuse load; cell rated 9.8 N.
2. Rigid enough that the loaded natural frequency lands **≥ 35 Hz**
   (see below — this is the one number that makes Lab 10 work).
3. Prop tip clearance to any structure ≥ 1 prop radius; motor plane
   ≥ 2 prop diameters above the bench (clean inflow).
4. Flat platform above the motor mount accepting stacked slotted masses
   (500 g max) centered on the thrust axis, prop removed.
5. Guard: ring or cage around the prop disk, removable only with tools.
6. 12 V power path: supply → panel barrel jack → **kill switch** (panel
   mounted, reachable without crossing the prop plane) → inline 10 A fuse
   → ACS712 → ESC. Signal wiring (ESC servo lead) routed away from the
   power run.
7. Cable strain relief at the moving (cell) side: wire loops, not taut
   runs — a taut cable is a parallel spring and corrupts calibration.
8. Base clamps to the lab tables with the same clamp pattern as the strain
   gauge lab fixtures (reuse).

## Critical design factors

**1. Natural frequency is a spec, not an accident.** Lab 10's step
response (motor τ ≈ 50 ms → bandwidth ≈ 3 Hz) is trustworthy only because
the rig's ringing frequency sits an order of magnitude above it, and the
tap-test exercise needs a clean, countable ringdown in the 35–60 Hz range.
With m ≈ 80 g (motor + mount + platform) on a 1 kg bar cell
(k ≈ 2×10⁴ N/m), theory gives fn ≈ 80 Hz; mount compliance in practice
halves it. **Keep added platform mass under ~50 g** and the mount joints
tight. If a prototype taps out under 30 Hz, stiffen the post/joints or
shave platform mass — do not shrug at it.

**2. Everything in the load path is part of the sensor.** Bolted joints
only (no adhesive-only joints in the force path), lock washers or
threadlocker everywhere — a joint that shifts mid-sweep is a tare shift
mid-experiment, which students will see as "drift". This is a
data-quality requirement wearing a mechanical costume.

**3. The tare must be reproducible, not zero.** The motor+mount weight
preloading the cell is fine (the analysis tare-corrects); what matters is
that it does not *change*. No loose accessories on the platform.

**4. Off-axis load tolerance.** Bar cells read moment as force: keep the
motor's thrust axis over the cell's marked load point within ~2 mm.
Locate the motor mount with dowels or a pocket, not slots.

**5. Guard the prop, not the airflow.** Ring guard at the prop tip plane
with open top/bottom; a fine mesh above the prop costs measurable thrust
and skews the momentum-theory fit. 3D-printed PETG ring + 3 struts works.

**6. Kill switch placement.** Reachable by either partner without
reaching over or around the prop disk. Red. Labeled. It is the taught
first response, so make it the *easy* response.

**7. Vibration isolation is NOT wanted.** No rubber feet between cell and
post — soft mounts lower fn and add mystery damping. Hard-mount
everything; the bench clamp handles the rest.

## Electrical setup (per station, one-time)

- **AD620 gain:** target ≈ 200 (Rg ≈ 249 Ω; the modules' trimpot works
  but drifts — replace with a fixed resistor after setting). Full-scale
  check: 500 g mass → ≈ 0.5 V above tare at the scope.
- **AD620 supply:** ADS ±5 V rails. Output rides near 0.1–0.6 V — well
  inside the scope's ±5 V range with headroom for steps.
- **ACS712 supply:** 5 V from the ADS V+ rail; output midscale ≈ 2.5 V.
- **ESC:** any BLHeli_S with default 1000–2000 µs endpoints; verify the
  deadband (< ~8%) once per unit. Disable ESC "low-voltage cutoff" beeps
  if the brand supports it (we run a supply, not a battery).
- **Direction:** motor must blow air UP (thrust down into the cell). Swap
  any two motor phase wires to reverse; mark the correct wiring with heat
  shrink color code after verifying.

## Acceptance tests (run per rig before the lab week)

| Test | Pass criterion |
|------|----------------|
| Dead-weight linearity (0–500 g, prop off) | Linear fit residuals < 5 mN RMS |
| Noise floor, motor off, 1 kHz | σ < 4 mV at the scope |
| Tap test | fn ≥ 35 Hz, ζ in 0.02–0.08, ≥ 8 countable peaks |
| Full sweep to 70 %, Prop B | Bus current < 8 A, no joint shift (tare within 2 mV before/after) |
| Kill switch | Cuts a 50 % throttle run instantly; ESC re-arms cleanly after |
| Guard | Stops a pencil pushed at the spinning prop plane (yes, actually try) |

## Build sequence suggestion

Prototype one rig fully (including acceptance tests and one complete run
of both labs' procedures) before cutting material for 15. The prototype
run is also when the manual's screenshot placeholders
(`Rig_Station_Photo`, `Wiring_Photo_ADS`, `Pydwf_Sweep_Output`,
`TapTest_Photo`) get their real images.

Two-semester rollout note: Lab 10 adds **no hardware** beyond Lab 09's
build — semester 2 cost is TA time and the acceptance re-check, so front-
load all fabrication into the Lab 09 build.
