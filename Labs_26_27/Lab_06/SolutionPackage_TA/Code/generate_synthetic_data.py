"""
Generate synthetic (made-up) Lab 06 data for the ME 3300 solution package.

Mimics what the students' dwfpy acquisition script saves during Week 1:
  StrainBridge_Loads.csv — one row per mass with the loaded reading and the
  bracketing unloaded readings (unload-load-unload procedure):
      mass_kg, v_loaded_V, v_unl_before_V, v_unl_after_V

Physics: end-loaded cantilever, half-bridge (two active gauges), AD622 at
G ≈ 500, 5 V excitation.
  epsilon(m) = 6 m g L / (w t^2 E)
  dV_amp(m)  = G * Vi * GF * epsilon / 2

"True" values are deliberately slightly off the nominals (honest recovery):
  E_true = 203 GPa (steel; published ~200), Vi actually 4.987 V, G from
  R_G = 101.66 ohms. Geometry matches last year's beam (L=0.36 m,
  w=1.499 in, t=0.2515 in).

The zero-load output sits at ~1.87 V (bridge imbalance x 500) and DRIFTS
upward ~1 mV per reading — like last year's real data (2.1240 -> 2.1344 V
over a session). The drift is why the unload-load-unload bracketing matters:
the solution's two delta estimates differ by ~the drift, and their average
cancels most of it. Seed-locked with default_rng(3300).
"""

from pathlib import Path

import numpy as np

rng = np.random.default_rng(3300)

DATA = Path(__file__).resolve().parent.parent / "Data"
DATA.mkdir(exist_ok=True)

# ----- true physics (students never see these exactly) -----------------
E_TRUE = 203.0e9                 # Pa
L, w, t = 0.3600, 0.03807, 0.006388   # m (legacy beam)
g = 9.8051                       # m/s^2 (Moscow, ID)
GF = 2.012
R_G = 101.66                     # ohms
G = 1 + 50500.0 / R_G            # ~497.7
VI = 4.987                       # actual excitation (nominal 5 V switch)

OFFSET = 1.8723                  # amplified zero-load output (V)
READ_NOISE = 0.0003              # V, std of a 10 s averaged reading

masses = np.arange(0.4, 2.01, 0.2)     # kg (9 loads)


def eps(m):
    return 6 * m * g * L / (w * t**2 * E_TRUE)


def dv_amp(m):
    return G * VI * GF * eps(m) / 2


# ----- simulate the 19-reading session: U0, L1, U1, L2, ..., U9 --------
drift_steps = np.abs(rng.normal(0.0009, 0.0004, 19))   # slow upward creep
drift = np.concatenate([[0.0], np.cumsum(drift_steps)[:-1]])

readings = []          # (kind, mass, value)
k = 0
readings.append(("U", 0.0, OFFSET + drift[k] + rng.normal(0, READ_NOISE)))
for m in masses:
    k += 1
    readings.append(("L", m, OFFSET + dv_amp(m) + drift[k] + rng.normal(0, READ_NOISE)))
    k += 1
    readings.append(("U", 0.0, OFFSET + drift[k] + rng.normal(0, READ_NOISE)))

v_unloaded = np.array([v for kind, m, v in readings if kind == "U"])   # 10
v_loaded   = np.array([v for kind, m, v in readings if kind == "L"])   # 9

np.savetxt(
    DATA / "StrainBridge_Loads.csv",
    np.column_stack([masses, v_loaded, v_unloaded[:-1], v_unloaded[1:]]),
    header="mass_kg,v_loaded_V,v_unl_before_V,v_unl_after_V",
    delimiter=",",
)

# quick sanity report
dv1 = v_loaded - v_unloaded[:-1]
dv2 = v_loaded - v_unloaded[1:]
dv = (dv1 + dv2) / 2
strain = 2 * dv / (VI * G * GF)
stress = 6 * masses * g * L / (w * t**2)
E_check = np.polyfit(strain, stress, 1)[0]

print(f"total drift over session: {drift[-1]*1000:.1f} mV")
print(f"dV at 0.4 kg: {dv[0]*1000:.1f} mV, at 2.0 kg: {dv[-1]*1000:.1f} mV")
print(f"E recovered with true params: {E_check/1e9:.1f} GPa (true {E_TRUE/1e9:.0f})")
print("written:", DATA / "StrainBridge_Loads.csv")
