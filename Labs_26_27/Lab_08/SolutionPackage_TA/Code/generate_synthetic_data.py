"""
Generate synthetic (made-up) Lab 08 data for the ME 3300 solution package.

Mimics what the students' dwfpy scripts save:
  Cal_RoomAir.csv, Cal_Boiling.csv — 50 Hz x 10 s voltage traces for the
      two-point calibration (paired with LIGT readings in the manual).
  Plunge_01.csv .. Plunge_03.csv   — 1000 Hz x 5 s step-response captures
      (time_s, voltage_V), plunge occurring 1.2-1.8 s into each record.

Signal chain: K-type bead -> Adafruit AD8495 (T = (V - 1.25)/0.005) ->
LM358 voltage follower (adds a small DC offset — absorbed by the two-point
calibration) -> ADS Scope.

Legacy-informed truths: T_room ~ 21-23 C, boiling at Moscow ID elevation
~ 97.4 C, tau ~ 45 ms (bare bead in stirred near-boiling water; legacy data
showed 41-48 ms). Run 2 includes a small "steam bump" ~0.3 s before
immersion (the classic mistake the manual warns about) — small enough that
the diff-based step detector correctly ignores it. Seed default_rng(3300).
"""

from pathlib import Path

import numpy as np

rng = np.random.default_rng(3300)

DATA = Path(__file__).resolve().parent.parent / "Data"
DATA.mkdir(exist_ok=True)

# ----- truths -----------------------------------------------------------
CHAIN_OFFSET = 0.0043        # V — LM358 follower offset (calibrated out)
NOISE = 0.0010               # V, per-sample

T_AIR = 21.4                 # C — LIGT room-air reading
T_BOIL = 97.4                # C — LIGT bath reading (elevation-corrected)


def temp_to_volts(T):
    """True chain: AD8495 + follower offset."""
    return 1.25 + 0.005 * np.asarray(T) + CHAIN_OFFSET


# ----- calibration traces (50 Hz x 10 s) --------------------------------
n_cal = 500
t_cal = np.arange(n_cal) / 50.0
for name, T in [("Cal_RoomAir.csv", T_AIR), ("Cal_Boiling.csv", T_BOIL)]:
    v = temp_to_volts(T) + rng.normal(0, NOISE, n_cal)
    np.savetxt(DATA / name, np.column_stack([t_cal, v]),
               header="Time (s),Channel 1 (V)", delimiter=",")

# ----- plunge runs (1000 Hz x 5 s) ---------------------------------------
FS, DUR = 1000, 5.0
n = int(FS * DUR)
t = np.arange(n) / FS

runs = [  # (T0, tau_s, t_plunge, steam_bump)
    (22.8, 0.044, 1.62, False),
    (21.9, 0.047, 1.31, True),
    (23.1, 0.045, 1.77, False),
]

for i, (T0, tau, t_plunge, bump) in enumerate(runs, start=1):
    T = np.full(n, float(T0))

    if bump:  # small steam-preheat bump just before immersion
        tb = t_plunge - 0.30
        in_bump = (t >= tb) & (t < t_plunge)
        T[in_bump] += 1.5 * np.sin(np.pi * (t[in_bump] - tb) / 0.30) ** 2

    after = t >= t_plunge
    T0_eff = T[np.argmax(after) - 1]
    T[after] = T_BOIL + (T0_eff - T_BOIL) * np.exp(-(t[after] - t_plunge) / tau)

    v = temp_to_volts(T) + rng.normal(0, NOISE, n)
    np.savetxt(DATA / f"Plunge_{i:02d}.csv", np.column_stack([t, v]),
               header="Time (s),Channel 1 (V)", delimiter=",")
    print(f"Plunge_{i:02d}: T0={T0} C, tau={tau*1000:.0f} ms, "
          f"plunge at {t_plunge} s, steam bump={bump}")

print("written to", DATA)
