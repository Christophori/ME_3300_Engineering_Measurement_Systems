"""Regenerate Lab 06's example-result figures (editable copy for Chris).

Plotting code extracted from SolutionPackage_TA/Code/Lab06_Solution.ipynb;
reads the seed-locked synthetic data from SolutionPackage_TA/Data/. Each
figure is saved here as .png (600 dpi, used by the .qmd), .pdf, and .svg
(for vector editing in Inkscape — text is kept as editable text).

Edit placements/annotations below and re-run:
    python make_lab06_example_figures.py
The solution notebook remains the source of truth for the TA package; if
you change values (not just cosmetics), update the notebook to match.
"""

from datetime import date
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
from scipy import stats

plt.rcParams["font.family"] = "serif"
plt.rcParams["font.serif"] = ["Times New Roman", "Times", "DejaVu Serif"]
plt.rcParams["font.size"] = 10
plt.rcParams["svg.fonttype"] = "none"   # keep SVG text editable as text

HERE = Path(__file__).resolve().parent
DATA = HERE.parent.parent.parent / "SolutionPackage_TA" / "Data"
today = date.today().strftime("%b %d, %Y")


def save(fig, name):
    fig.savefig(HERE / f"{name}.png", dpi=600, bbox_inches="tight")
    fig.savefig(HERE / f"{name}.pdf", dpi=600, bbox_inches="tight")
    fig.savefig(HERE / f"{name}.svg", bbox_inches="tight")


# ----- measured parameters (synthetic "measurements") --------------------
L, w, t = 0.3595, 0.03805, 0.00640
g = 9.8051
GF = 2.012
R_G = 101.7
G = 1 + 50500.0 / R_G
V_i = 4.987

# ----- Week 1 analysis: deltas, stress, strain, E fit --------------------
data = np.loadtxt(DATA / "StrainBridge_Loads.csv", delimiter=",", comments="#")
masses = data[:, 0]
v_load, v_before, v_after = data[:, 1], data[:, 2], data[:, 3]

dv1 = v_load - v_before
dv2 = v_load - v_after
dV = (dv1 + dv2) / 2

strain = 2 * dV / (V_i * G * GF)
stress = 6 * masses * g * L / (w * t**2)

coeffs = np.polyfit(strain, stress, 1)
E_fit = coeffs[0]
N = len(strain)
nu = N - 2
resid = stress - np.polyval(coeffs, strain)
s_yx = np.sqrt(np.sum(resid**2)) / np.sqrt(nu)
S_E = s_yx / np.sqrt(np.sum((strain - strain.mean()) ** 2))
CI_E = stats.t.ppf(0.975, df=nu) * S_E

# ======================================================================
# 1. Stress–strain figure
# ======================================================================
strain_line = np.linspace(0, strain.max() * 1.05, 100)

fig, ax = plt.subplots(figsize=(6.5, 4.0))
fig.patch.set_facecolor("white")

ax.scatter(strain * 1e6, stress / 1e6, s=75, facecolors="none",
           edgecolors="red", zorder=3, label="measured")
ax.plot(strain_line * 1e6, np.polyval(coeffs, strain_line) / 1e6,
        "b-", linewidth=2, label="linear fit")
ax.plot(strain_line * 1e6,
        (np.polyval(coeffs, strain_line) + stats.t.ppf(0.975, nu) * s_yx) / 1e6,
        "k--", linewidth=1, label="95% CI")
ax.plot(strain_line * 1e6,
        (np.polyval(coeffs, strain_line) - stats.t.ppf(0.975, nu) * s_yx) / 1e6,
        "k--", linewidth=1)

ax.set_xlabel(r"Strain $\varepsilon$ ($\mu\varepsilon$)")
ax.set_ylabel(r"Stress $\sigma$ (MPa)")
ax.set_title(f"FirstName LastName's Stress vs. Strain Plot — {today}")
ax.grid(which="major", linestyle="--", linewidth=0.5)
ax.grid(which="minor", linestyle="--", linewidth=0.5, alpha=0.5)
ax.minorticks_on()
ax.spines["top"].set_visible(False)
ax.spines["right"].set_visible(False)
ax.legend(loc="upper left")

ax.text(0.98, 0.05,
        f"E = {E_fit/1e9:.2f} ± {CI_E/1e9:.2f} GPa (95% CI)\n"
        f"$s_{{yx}}$ = {s_yx/1e6:.4f} MPa",
        transform=ax.transAxes, ha="right", va="bottom")

save(fig, "FirstName_LastName_Lab06_StressStrain")
plt.close(fig)

# ======================================================================
# 2. Uncertainty-budget bar chart (m = 1.0 kg)
# ======================================================================
u_dV = np.abs(dv1 - dv2).mean() / 2


def budget(m_eval, dV_eval):
    variables = [
        ("m",   m_eval,  0.01 * m_eval, +1),
        ("g",   g,       1e-5 * g,      +1),
        ("L",   L,       0.0005,        +1),
        ("V_i", V_i,     0.0005,        +1),
        ("G",   G,       0.005 * G,     +1),
        ("GF",  GF,      0.01 * GF,     +1),
        ("w",   w,       0.00001,       -1),
        ("t",   t,       0.000005,      -2),
        ("dV",  dV_eval, u_dV,          -1),
    ]
    names = [v[0] for v in variables]
    rel = np.array([p * u / x for _, x, u, p in variables])
    contribs = np.abs(rel) * E_fit
    total = np.sqrt(np.sum(contribs**2))
    return names, contribs, total


i = np.argmin(np.abs(masses - 1.0))
names, contribs, total = budget(masses[i], dV[i])

fig, ax = plt.subplots(figsize=(6.5, 4.0))
fig.patch.set_facecolor("white")

ax.bar(names, contribs / 1e9, color="steelblue", edgecolor="black",
       linewidth=0.5, zorder=3)
ax.axhline(CI_E / 1e9, color="red", linestyle="--", linewidth=1.5,
           label=f"curve-fit 95% CI (±{CI_E/1e9:.2f} GPa)")

ax.set_xlabel(r"Variable in $E = 3mgLV_iG(GF)\,/\,(wt^2\,\Delta V)$")
ax.set_ylabel("Contribution to $u_E$ (GPa)")
ax.set_ylim(0, contribs.max() / 1e9 * 1.3)
ax.set_title(f"FirstName LastName's Uncertainty Budget Plot (m = 1.0 kg) — {today}")
ax.grid(which="major", axis="y", linestyle="--", linewidth=0.5)
ax.spines["top"].set_visible(False)
ax.spines["right"].set_visible(False)
ax.legend()

ax.text(0.98, 0.95, f"total $u_E$ = ±{total/1e9:.2f} GPa ({total/E_fit*100:.1f} %)",
        transform=ax.transAxes, ha="right", va="top")

save(fig, "FirstName_LastName_Lab06_UncertaintyBudget")
plt.close(fig)

print("Lab 06 example figures regenerated (png + pdf + svg) in", HERE)
