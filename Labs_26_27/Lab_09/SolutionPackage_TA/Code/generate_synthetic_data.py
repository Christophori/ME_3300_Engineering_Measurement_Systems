"""Generate synthetic Lab 09 (static thrust stand) data files.

TA USE ONLY — these files let TAs test the full analysis pipeline (and the
posted solution notebook) without hardware. Values are made up but match the
example figures in the Lab 09 manual (seed-locked, rng(3300)).

Unlike Labs 02/03, no WaveForms GUI export appears in this lab: every data
file is written by the STUDENT'S OWN pydwf sweep script via np.savetxt, so
the format here is np.savetxt format — one '#' header line, comma-separated
data. The manual's `np.loadtxt(..., comments='#')` matches this.

True system (hidden from students; the posted "datasheet" values students
compare against are deliberately slightly different where honesty demands):
  Motor  : 1106-class BLDC, KV = 3800 rpm/V, R = 0.16 ohm, I0-style
           electronics idle draw folded into bus current.
  Prop A : 3016 two-blade  (kT = 2.2e-7 N s^2, kq = 2.0e-9 N m s^2)
  Prop B : 3030 three-blade (kT = 2.9e-7 N s^2, kq = 3.0e-9 N m s^2)
  Bus    : 12.0 V brick (sags slightly with load).
  ESC    : behaves as an ideal buck converter -> I_bus = duty * I_motor.
  Load cell chain: 1 kg bar cell, 1.0 mV/V @ 5 V excitation, AD620 gain
           ~198.7  -> 0.101 V/N; tare (motor+mount weight) + amp offset.
  Current sensor: ACS712-20A, 0.100 V/A, 2.5 V midscale (true offset 2.512).
"""

import numpy as np
from pathlib import Path

rng = np.random.default_rng(3300)
OUT = Path(__file__).resolve().parent.parent / "Data"
OUT.mkdir(exist_ok=True)

# ------------------------------------------------------------------ true system
KV_RAD = 3800 * 2 * np.pi / 60        # rad/s per volt back-EMF constant
KT_MOT = 1 / KV_RAD                   # N m / A  (SI: kt = 1/kv)
R_MOT = 0.16                          # ohm
V_BUS0 = 12.02                        # unloaded brick voltage
R_BUS = 0.045                         # brick + wiring source impedance, ohm
I_IDLE = 0.08                         # ESC electronics draw, A

PROPS = {
    "PropA": dict(kT=2.20e-7, kq=2.00e-9),   # 3016 two-blade
    "PropB": dict(kT=2.90e-7, kq=3.00e-9),   # 3030 three-blade
}

# load-cell signal chain (true values)
CHAIN_V_PER_N = 0.10127               # V per newton at the scope
TARE_MASS_KG = 0.0781                 # motor + mount + platform on the cell
AMP_OFFSET_V = 0.0117                 # AD620 output offset after zero-pot
G = 9.81

# ACS712-20A (true values; datasheet nominal is 0.100 V/A, 2.500 V)
ACS_V_PER_A = 0.0997
ACS_OFFSET_V = 2.5124

# scope-referred noise (per-sample sigma)
NOISE_CELL_V = 0.0030
NOISE_CURR_V = 0.0150

DEADBAND = 0.06                       # ESC won't spin below 6 % throttle


def omega_ss(duty, kq, v_bus):
    """Steady-state rotor speed from motor torque = prop torque (quadratic)."""
    if duty <= DEADBAND:
        return 0.0
    v_eff = duty * v_bus
    a = kq
    b = KT_MOT / (R_MOT * KV_RAD)
    c = -KT_MOT * v_eff / R_MOT
    return (-b + np.sqrt(b * b - 4 * a * c)) / (2 * a)


def steady_point(duty, prop, kT_scale=1.0):
    """Return (thrust_N, i_bus_A) at a throttle duty for one prop."""
    kT = PROPS[prop]["kT"] * kT_scale
    kq = PROPS[prop]["kq"]
    # small fixed-point iteration for bus sag
    v_bus = V_BUS0
    for _ in range(4):
        w = omega_ss(duty, kq, v_bus)
        i_mot = max((duty * v_bus - w / KV_RAD) / R_MOT, 0.0)
        i_bus = duty * i_mot + I_IDLE
        v_bus = V_BUS0 - R_BUS * i_bus
    thrust = kT * w * w
    return thrust, i_bus


def cell_volts(force_n):
    """Force on the cell (thrust + tare weight) -> amplified scope volts."""
    return CHAIN_V_PER_N * (force_n + TARE_MASS_KG * G) + AMP_OFFSET_V


def curr_volts(i_bus):
    return ACS_OFFSET_V + ACS_V_PER_A * i_bus


# ------------------------------------------------- 1. dead-weight calibration
# Student procedure: prop OFF, place masses on the platform, script records
# 2 s at 1 kHz per mass and stores the mean. Mean-of-2000 noise is tiny; the
# dominant per-point scatter is creep/placement (~0.4 mV), modeled here.
masses_g = np.array([0, 50, 100, 200, 500])
cal_v = np.array([
    cell_volts(m / 1000 * G) for m in masses_g
]) + rng.normal(0, 0.0004, size=masses_g.size)

np.savetxt(OUT / "loadcell_calibration_data.csv",
           np.column_stack([masses_g, cal_v]),
           header="mass_g,voltage_V", delimiter=",", fmt="%.6f")
print("calibration:", np.round(cal_v, 4))

# ---------------------------------------------------------- 2. thrust sweeps
# Student sweep script: throttle 10..70 % in 5 % steps, 3 s dwell, records
# the mean load-cell V and mean current V over the final 2 s of each dwell.
throttle_pct = np.arange(10, 71, 5)
N_DWELL = 2000                        # samples averaged per setpoint

for prop in PROPS:
    for run in (1, 2, 3):
        # run-to-run repeatability: thermal drift of kT, tare re-zero shift
        kT_scale = 1.0 + rng.normal(0, 0.010)
        tare_shift = rng.normal(0, 0.0008)
        rows = []
        for pct in throttle_pct:
            thrust, i_bus = steady_point(pct / 100, prop, kT_scale)
            v_cell = (cell_volts(thrust) + tare_shift
                      + rng.normal(0, NOISE_CELL_V / np.sqrt(N_DWELL))
                      + rng.normal(0, 0.0006))      # settling residual
            v_curr = (curr_volts(i_bus)
                      + rng.normal(0, NOISE_CURR_V / np.sqrt(N_DWELL))
                      + rng.normal(0, 0.0012))
            rows.append((pct, v_cell, v_curr))
        rows = np.array(rows)
        np.savetxt(OUT / f"ThrustSweep_{prop}_Run{run}.csv", rows,
                   header="throttle_pct,loadcell_V,current_V",
                   delimiter=",", fmt="%.6f")
        if run == 1:
            g_max = (rows[-1, 1] - cell_volts(0)) / CHAIN_V_PER_N / G * 1000
            print(f"{prop} run1 70%: ~{g_max:.0f} g,"
                  f" {(rows[-1, 2] - ACS_OFFSET_V) / ACS_V_PER_A:.2f} A")

# ------------------------------------------- 3. zero-throttle tare recording
# Students record 5 s at 0 % throttle before each sweep to get the tare.
t = np.arange(0, 5.0, 1 / 1000)
v_tare = cell_volts(0) + rng.normal(0, NOISE_CELL_V, t.size)
i_tare = curr_volts(I_IDLE) + rng.normal(0, NOISE_CURR_V, t.size)
np.savetxt(OUT / "TareRecording.csv",
           np.column_stack([t, v_tare, i_tare]),
           header="time_s,loadcell_V,current_V", delimiter=",", fmt="%.6f")
print("tare mean V:", v_tare.mean().round(4),
      "| expected:", round(cell_volts(0), 4))
