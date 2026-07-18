"""Generate synthetic Lab 10 (dynamic thrust stand) data files.

TA USE ONLY. Same true system as Lab 09's generator (same station, Prop A
mounted) — keep the two files' constants in sync if you retune anything.

All files are in np.savetxt format (one '#' header line): in this lab every
capture is made by the student's own pydwf record script, not the GUI.

Dynamics (hidden truth):
  Rotor+prop:  J domega/dt = kt*i - kq*omega^2,  i = (duty*Vbus - omega/KVr)/R
               -> linearized time constant ~45-50 ms at the 30-60 % range.
  Rig+cell  :  2nd-order, fn ~ 42 Hz, zeta ~ 0.035 (what the tap test finds).
               The cell reads thrust THROUGH this resonance.
"""

import numpy as np
from pathlib import Path
from scipy.integrate import solve_ivp

rng = np.random.default_rng(3300)
OUT = Path(__file__).resolve().parent.parent / "Data"
OUT.mkdir(exist_ok=True)

# ---------------- true system (MUST match Lab 09 generator) ----------------
KV_RAD = 3800 * 2 * np.pi / 60
KT_MOT = 1 / KV_RAD
R_MOT = 0.16
V_BUS0 = 12.02
R_BUS = 0.045
I_IDLE = 0.08
KT_PROP = 2.20e-7          # Prop A
KQ_PROP = 2.00e-9
J_ROT = 2.2e-6             # rotor + 3016 prop inertia, kg m^2
DEADBAND = 0.06

CHAIN_V_PER_N = 0.10127
TARE_MASS_KG = 0.0781
AMP_OFFSET_V = 0.0117
G = 9.81
ACS_V_PER_A = 0.0997
ACS_OFFSET_V = 2.5124
NOISE_CELL_V = 0.0030
NOISE_CURR_V = 0.0150

WN = 2 * np.pi * 42.0      # rig natural frequency, rad/s
ZETA = 0.035

FS = 1000
DT = 1 / FS


def motor_current(duty, omega, v_bus):
    if duty <= DEADBAND:
        return 0.0
    return max((duty * v_bus - omega / KV_RAD) / R_MOT, 0.0)


def simulate(duty_of_t, t_end, wn=WN, zeta=ZETA):
    """Integrate rotor + rig. Returns t, cell force (N), bus current (A)."""

    def rhs(t, y):
        w, x, xd = y                       # rotor speed, rig defl. state
        duty = duty_of_t(t)
        v_bus = V_BUS0 - R_BUS * (duty * motor_current(duty, w, V_BUS0))
        i = motor_current(duty, w, v_bus)
        thrust = KT_PROP * w * w
        dw = (KT_MOT * i - KQ_PROP * w * w) / J_ROT
        # rig: unity-DC-gain 2nd order driven by thrust (x is in newtons)
        dxd = wn * wn * (thrust - x) - 2 * zeta * wn * xd
        return [dw, xd, dxd]

    t_eval = np.arange(0, t_end, DT)
    w0 = 0.0
    # start from steady state at the initial duty
    d0 = duty_of_t(0)
    if d0 > DEADBAND:
        a, b = KQ_PROP, KT_MOT / (R_MOT * KV_RAD)
        c = -KT_MOT * d0 * V_BUS0 / R_MOT
        w0 = (-b + np.sqrt(b * b - 4 * a * c)) / (2 * a)
    y0 = [w0, KT_PROP * w0 * w0, 0.0]
    sol = solve_ivp(rhs, (0, t_end), y0, t_eval=t_eval,
                    max_step=1e-3, rtol=1e-7, atol=1e-9)
    w = sol.y[0]
    cell_force = sol.y[1]
    duty = np.array([duty_of_t(ti) for ti in sol.t])
    v_bus = V_BUS0 - R_BUS * duty * np.maximum(
        (duty * V_BUS0 - w / KV_RAD) / R_MOT, 0.0)
    i_mot = np.maximum((duty * v_bus - w / KV_RAD) / R_MOT, 0.0)
    i_mot[duty <= DEADBAND] = 0.0
    i_bus = duty * i_mot + I_IDLE
    return sol.t, cell_force, i_bus


def to_cell_volts(force_n, tare_shift=0.0):
    return (CHAIN_V_PER_N * (force_n + TARE_MASS_KG * G)
            + AMP_OFFSET_V + tare_shift)


def to_curr_volts(i_bus):
    return ACS_OFFSET_V + ACS_V_PER_A * i_bus


# ------------------------------------------------- 0. motor-off tare record
# Prop mounted, motor unpowered: the tare both step and hover analyses use.
t = np.arange(0, 2.0, DT)
v = to_cell_volts(0.0) + rng.normal(0, NOISE_CELL_V, t.size)
vi = to_curr_volts(I_IDLE) + rng.normal(0, NOISE_CURR_V, t.size)
np.savetxt(OUT / "MotorOffTare.csv", np.column_stack([t, v, vi]),
           header="time_s,loadcell_V,current_V", delimiter=",", fmt="%.6f")

# ------------------------------------------------------------- 1. tap tests
# Prop OFF (safety), motor unpowered. Students tap the motor mount plate with
# a pen; the cell rings down at the rig's natural frequency.
for run in (1, 2, 3):
    wn_r = WN * (1 + rng.normal(0, 0.004))       # tiny clamp-dependent shift
    zeta_r = ZETA * (1 + rng.normal(0, 0.05))
    wd = wn_r * np.sqrt(1 - zeta_r ** 2)
    t = np.arange(0, 3.0, DT)
    t0 = 0.5 + rng.uniform(0, 0.05)
    amp0 = 0.30 + rng.uniform(0, 0.12)           # volts, tap strength varies
    ring = np.where(
        t < t0, 0.0,
        amp0 * np.exp(-zeta_r * wn_r * (t - t0)) * np.sin(wd * (t - t0)))
    v = to_cell_volts(0.0) + ring + rng.normal(0, NOISE_CELL_V, t.size)
    np.savetxt(OUT / f"TapTest_Run{run}.csv", np.column_stack([t, v]),
               header="time_s,loadcell_V", delimiter=",", fmt="%.6f")
print(f"tap: fn_true ~ {WN/2/np.pi:.1f} Hz, zeta_true ~ {ZETA}")

# --------------------------------------------------------- 2. step responses
# Throttle step 30 % -> 60 % (up) and 60 % -> 30 % (down), step at t = 1.0 s.
STEP_T = 1.0


def make_step(d_lo, d_hi, up=True):
    d0, d1 = (d_lo, d_hi) if up else (d_hi, d_lo)
    return lambda t: d0 if t < STEP_T else d1


for run in (1, 2, 3):
    tare_shift = rng.normal(0, 0.0008)
    for name, up in (("StepUp", True), ("StepDown", False)):
        t, f_cell, i_bus = simulate(make_step(0.30, 0.60, up), 3.5)
        v_c = to_cell_volts(f_cell, tare_shift) \
            + rng.normal(0, NOISE_CELL_V, t.size)
        v_i = to_curr_volts(i_bus) + rng.normal(0, NOISE_CURR_V, t.size)
        np.savetxt(OUT / f"{name}_Run{run}.csv",
                   np.column_stack([t, v_c, v_i]),
                   header="time_s,loadcell_V,current_V",
                   delimiter=",", fmt="%.6f")
        if run == 1:
            # report the true linearized tau at the final operating point
            i_ss = np.mean(f_cell[-300:])
            print(f"{name}: F {f_cell[900]:.3f} -> {i_ss:.3f} N")

# threshold sanity check (skill pitfall): detection must clear 5 sigma
d = np.abs(np.diff(v_i))
print("current step jump vs 5*sqrt(2)*sigma:",
      d.max().round(3), ">", (5 * np.sqrt(2) * NOISE_CURR_V).round(3))

# --------------------------------------------------- 3. hover verification
# Students command their Lab-09-derived hover throttle (rounds to 38 %) and
# record 5 s. Mean thrust should land near the 60 g design target.
t, f_cell, i_bus = simulate(lambda t: 0.38, 5.0)
v_c = to_cell_volts(f_cell) + rng.normal(0, NOISE_CELL_V, t.size)
v_i = to_curr_volts(i_bus) + rng.normal(0, NOISE_CURR_V, t.size)
np.savetxt(OUT / "HoverTest.csv", np.column_stack([t, v_c, v_i]),
           header="time_s,loadcell_V,current_V", delimiter=",", fmt="%.6f")
print(f"hover @38%: {np.mean(f_cell[2000:])/G*1000:.1f} g "
      f"(target 60 g), {np.mean(i_bus[2000:]):.2f} A")
