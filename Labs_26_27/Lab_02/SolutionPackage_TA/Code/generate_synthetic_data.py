"""Generate synthetic Lab 02 data files in WaveForms Logger CSV export format.

TA USE ONLY — these files let TAs test the full analysis pipeline (and the
posted solution notebook) without hardware. Values are made up but match the
example figures in the Lab 02 manual (seed-locked).

Format mimics a WaveForms Logger export: 6 '#' metadata lines, then a header
row, then comma-separated data. The manual's `skiprows=6` matches this
(verified against a real export by CB, Jul 2026).
"""

import numpy as np
from scipy.integrate import solve_ivp

rng = np.random.default_rng(3300)
OUT = ('/sessions/kind-bold-thompson/mnt/ME_3300_Engineering_Measurement_Systems/'
       'Labs_26_27/Lab_02/SolutionPackage_TA/Data/')


def waveforms_header(rate_hz, n_samples):
    return (
        "#Digilent WaveForms Logger\n"
        "#Device Name: Analog Discovery Studio\n"
        "#Serial Number: SN:210415B1A0BE\n"
        "#Date Time: 2026-09-09 14:05:12\n"
        f"#Sample rate: {rate_hz}Hz\n"
        f"#Samples: {n_samples}\n"
        "Time (s),Channel 1 (V)\n"
    )


def write_csv(path, t, v, rate_hz):
    with open(path, 'w') as f:
        f.write(waveforms_header(rate_hz, len(t)))
        for ti, vi in zip(t, v):
            f.write(f"{ti:.6f},{vi:.6f}\n")


# --- True sensor model (matches manual example figures) ---
def volts_of_angle(theta_deg):
    return 1.65 + theta_deg * (1.98 / 180.0) + 0.004 * np.sin(np.radians(theta_deg))


# ---------------------------------------------------------------------------
# 1. Calibration files: 20 Hz, 10 s, held at each angle
# ---------------------------------------------------------------------------
angles_deg = np.array([-90, -70, -50, -30, -10, 0, 10, 30, 50, 70, 90])
fs_cal, T_cal = 20, 10
t_cal = np.arange(0, T_cal, 1 / fs_cal)

# Same per-angle offsets as the manual example plots (same rng draw order)
mean_offsets = rng.normal(0, 0.012, angles_deg.size)

for angle, off in zip(angles_deg, mean_offsets):
    v_mean = volts_of_angle(angle) + off
    v = v_mean + rng.normal(0, 0.006, t_cal.size)   # hand tremor + ADC noise
    sign = 'n' if angle < 0 else 'p'
    write_csv(f"{OUT}Ang_{sign}{abs(angle)}Deg.csv", t_cal, v, fs_cal)

# ---------------------------------------------------------------------------
# 2. Swing file: 100 Hz, 20 s, ~1.6 s held at +88 deg then released
# ---------------------------------------------------------------------------
g, L_exp, zeta_exp = 9.81, 0.288, 0.030
wn = np.sqrt(g / L_exp)

def pend(t, y):
    th, om = y
    return [om, -2 * zeta_exp * wn * om - wn**2 * np.sin(th)]

fs, T = 100, 20
t_all = np.arange(0, T, 1 / fs)
t_hold = 1.6
t_swing = t_all[t_all >= t_hold] - t_hold
sol = solve_ivp(pend, (0, t_swing[-1]), [np.radians(88.0), 0.0],
                t_eval=t_swing, max_step=0.005)
theta = np.concatenate([np.full(np.sum(t_all < t_hold), np.radians(88.0)),
                        sol.y[0]])
v_swing = volts_of_angle(np.degrees(theta)) + rng.normal(0, 0.0015, t_all.size)
write_csv(f"{OUT}FirstName_LastName_Lab02_Swing.csv", t_all, v_swing, fs)

print("Wrote", len(angles_deg), "calibration files + 1 swing file to", OUT)
