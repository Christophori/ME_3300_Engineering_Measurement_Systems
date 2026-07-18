"""
Generate synthetic (made-up) Lab 04 data for the ME 3300 solution package.

Mimics exactly what a student's dwfpy scripts save during the lab:
  1. Static comparison table  (Part-3): W1 DC setpoints measured by handheld
     DMM (typed in via input()) and by scripted ADS acquisition means.
  2. Five aliasing captures   (Part-4): y(t) = 2.5 + 2 sin(2*pi*f*t) sampled
     at fs = 1000 Hz for f = 100, 450, 500, 550, 1125 Hz.
  3. Eye-vs-DAQ capture       (Part-5): 5 Hz square wave (0-5 V) sampled at
     fs = 4.5 Hz for 20 s -> 0.5 Hz alias.
  4. Flicker-fusion staircase (Part-6): visible-flicker responses vs
     frequency for two partners.

All values are made up but legacy-informed (ranges/noise match last year's
NI-MyDAQ .dat files and ADS scope noise ~3 mV). Seed-locked for
reproducibility. Files use np.savetxt with '#'-prefixed headers, exactly as
the manual's code produces them.
"""

from pathlib import Path

import numpy as np

rng = np.random.default_rng(3300)

DATA = Path(__file__).resolve().parent.parent / "Data"
DATA.mkdir(exist_ok=True)

ADS_NOISE_STD = 0.003  # V, per-sample scope noise (matches Lab 02/03)

# ----------------------------------------------------------------------
# 1. Part-3: static comparison  (W1 DC setpoints 0..5 V)
# ----------------------------------------------------------------------
set_v = np.arange(0.0, 5.5, 1.0)

# "True" W1 output: small gain + offset error (AWG spec ~ +/-10 mV class)
true_v = 1.0018 * set_v + 0.0031

# Handheld DMM: 0.5% + 2 counts on a 3.5-digit display (1 mV resolution)
dmm_v = true_v * (1 + rng.normal(0, 0.0015, set_v.size)) + 0.002
dmm_v = np.round(dmm_v, 3)  # display resolution

# ADS scripted mean: scope gain/offset cal error + tiny averaged noise
ads_v = true_v * (1 + 0.0026) - 0.0018 + rng.normal(
    0, ADS_NOISE_STD / np.sqrt(2000), set_v.size
)

np.savetxt(
    DATA / "Static_Comparison.csv",
    np.column_stack([set_v, dmm_v, ads_v]),
    header="set_V,dmm_V,ads_V",
    delimiter=",",
)

# ----------------------------------------------------------------------
# 2. Part-4: aliasing sweep  (fs = 1000 Hz, five signal frequencies)
# ----------------------------------------------------------------------
FS = 1000
DURATION = 1.0
n = int(FS * DURATION)
t = np.arange(n) / FS

for f_sig in [100, 450, 500, 550, 1125]:
    phase = rng.uniform(0, 2 * np.pi)  # AWG/scope start phase is arbitrary
    v = 2.5 + 2.0 * np.sin(2 * np.pi * f_sig * t + phase)
    v += rng.normal(0, ADS_NOISE_STD, n)
    np.savetxt(
        DATA / f"Alias_{f_sig}Hz.csv",
        np.column_stack([t, v]),
        header="Time (s),Channel 1 (V)",
        delimiter=",",
    )

# ----------------------------------------------------------------------
# 3. Part-5: eye-vs-DAQ  (5 Hz square sampled at 4.5 Hz for 20 s)
# ----------------------------------------------------------------------
F_LED = 5.0
FS_SLOW = 4.5
DUR_SLOW = 20.0
n_slow = int(FS_SLOW * DUR_SLOW)  # 90 samples
t_slow = np.arange(n_slow) / FS_SLOW

# 0-5 V square wave (offset 2.5 V, amplitude 2.5 V), tiny phase offset so no
# sample lands exactly on a transition
sq = 2.5 + 2.5 * np.sign(np.sin(2 * np.pi * F_LED * t_slow + 0.35))
sq += rng.normal(0, ADS_NOISE_STD, n_slow)

np.savetxt(
    DATA / "EyeVsDAQ_Capture.csv",
    np.column_stack([t_slow, sq]),
    header="Time (s),Channel 1 (V)",
    delimiter=",",
)

# ----------------------------------------------------------------------
# 4. Part-6: flicker-fusion staircase (one file per partner, as the
#    manual's script saves them)
# ----------------------------------------------------------------------
# Coarse staircase: 20 Hz upward in 5 Hz steps until flicker disappears;
# 1 = flicker still visible. Partner A fuses between 55 and 60 Hz;
# Partner B between 65 and 70 Hz. (Typical CFF range is ~50-90 Hz.)
for name, fusion in [("PartnerA", 58), ("PartnerB", 67)]:
    freqs = np.arange(20, 20 + 5 * ((fusion - 20) // 5 + 2), 5)
    responses = (freqs < fusion).astype(int)
    np.savetxt(
        DATA / f"Flicker_Staircase_{name}.csv",
        np.column_stack([freqs, responses]),
        header="frequency_Hz,flicker_visible(1=yes 0=no)",
        delimiter=",",
        fmt="%d",
    )

print(f"Synthetic data written to {DATA}")
for p in sorted(DATA.glob("*.csv")):
    print(" ", p.name)
