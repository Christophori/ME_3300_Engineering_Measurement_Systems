"""
Generate synthetic (made-up) Lab 05 data for the ME 3300 solution package.

Mimics what the students' dwfpy sweep script saves:
  LM358_Sweep.csv  — W1 setpoint, measured V_in (Ch1 mean), measured V_out
                     (Ch2 mean) for a -5..+5 V DC sweep, 41 points.
  AD622_Sweep.csv  — same format for the instrumentation amplifier.

Both amplifiers target G = 3 with "measured" resistors:
  LM358: R1 = 9.96 kΩ, R2 = 19.89 kΩ  -> G = 1 + R2/R1   = 2.9970
  AD622: R_G = 24.87 kΩ               -> G = 1 + 50.5k/RG = 3.0306

Saturation is deliberately inside the sweep (±12 V rails):
  LM358 clips asymmetrically (~ +10.5 V / -11.4 V — its output swings closer
  to V- than to V+, per the datasheet), AD622 symmetric ~ ±10.8 V.

Values are made up; noise levels match the ADS scope (~2-3 mV per sample,
much smaller after averaging 500 samples — small residual noise retained so
fits have realistic statistics). Seed-locked with default_rng(3300).
"""

from pathlib import Path

import numpy as np

rng = np.random.default_rng(3300)

DATA = Path(__file__).resolve().parent.parent / "Data"
DATA.mkdir(exist_ok=True)

set_points = np.linspace(-5.0, 5.0, 41)


def sweep(gain, out_offset, clip_lo, clip_hi, fname):
    # W1 has a small gain/offset error; Ch1 measures it with tiny averaged noise
    v_true = 0.9992 * set_points + 0.0015
    v_in = v_true + rng.normal(0, 0.0008, set_points.size)

    v_out = gain * v_true + out_offset
    v_out = np.clip(v_out, clip_lo, clip_hi)  # rail saturation
    v_out += rng.normal(0, 0.0020, set_points.size)

    np.savetxt(
        DATA / fname,
        np.column_stack([set_points, v_in, v_out]),
        header="set_V,vin_V,vout_V",
        delimiter=",",
    )


# LM358 non-inverting: G = 1 + 19890/9960
sweep(1 + 19890.0 / 9960.0, -0.0032, -11.4, 10.5, "LM358_Sweep.csv")

# AD622 instrumentation amp: G = 1 + 50500/24870
sweep(1 + 50500.0 / 24870.0, 0.0018, -10.8, 10.8, "AD622_Sweep.csv")

print("Synthetic data written to", DATA)
for p in sorted(DATA.glob("*.csv")):
    print(" ", p.name)
