"""Regenerate Lab 08's example-result figures (editable copy for Chris).

Plotting code extracted from SolutionPackage_TA/Code/Lab08_Solution.ipynb;
reads the seed-locked synthetic data from SolutionPackage_TA/Data/. Each
figure is saved here as .png (600 dpi, used by the .qmd), .pdf, and .svg
(for vector editing in Inkscape — text is kept as editable text).

Edit placements/annotations below and re-run:
    python make_lab08_example_figures.py
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


# ----- the two-point calibration (from the synthetic cal captures) -------
T_air, T_boil = 21.4, 97.4    # LIGT readings

v_air = np.loadtxt(DATA / "Cal_RoomAir.csv", delimiter=",", comments="#")[:, 1].mean()
v_boil = np.loadtxt(DATA / "Cal_Boiling.csv", delimiter=",", comments="#")[:, 1].mean()
a1 = (T_boil - T_air) / (v_boil - v_air)
a0 = T_air - a1 * v_air


def analyze_run(fname):
    """Load a plunge capture; return shifted (t, T), T0, Tss, tau63."""
    d = np.loadtxt(fname, delimiter=",", comments="#")
    T_full = a1 * d[:, 1] + a0
    t_full = d[:, 0]

    T0 = T_full[:1000].mean()

    rise10 = T_full[10:] - T_full[:-10]
    idx = np.argmax(rise10 > 5.0)
    idx += np.argmax(T_full[idx:idx + 10] > T0 + 1.0)

    t = t_full[idx:] - t_full[idx]
    T = T_full[idx:]

    Tss = T[-1000:].mean()
    T63 = T0 + 0.632 * (Tss - T0)
    tau63 = t[np.argmax(T >= T63)]

    return t, T, T0, Tss, tau63


runs = [analyze_run(DATA / f"Plunge_{i:02d}.csv") for i in [1, 2, 3]]
taus = np.array([r[4] for r in runs])

# ======================================================================
# 1. Three-run step-response figure
# ======================================================================
fig, ax = plt.subplots(figsize=(6.5, 4.0))
fig.patch.set_facecolor("white")

colors = ["red", "blue", "green"]
for i, ((t, T, T0, Tss, tau63), color) in enumerate(zip(runs, colors), start=1):
    show = (t > -0.1) & (t < 0.4)
    ax.scatter(t[show], T[show], s=10, color=color, alpha=0.6,
               label=f"run {i} ($\\tau_{{63}}$ = {tau63*1000:.0f} ms)", zorder=3)

t_model = np.linspace(0, 0.4, 300)
T_model = Tss + (T0 - Tss) * np.exp(-t_model / taus.mean())
ax.plot(t_model, T_model, "k-", linewidth=1.5,
        label=f"model, mean $\\tau$ = {taus.mean()*1000:.0f} ms")

ax.set_xlabel("Time from plunge (s)")
ax.set_ylabel("Temperature (°C)")
ax.set_title(f"FirstName LastName's Temperature Plot — {today}")
ax.grid(which="major", linestyle="--", linewidth=0.5)
ax.grid(which="minor", linestyle="--", linewidth=0.5, alpha=0.5)
ax.minorticks_on()
ax.spines["top"].set_visible(False)
ax.spines["right"].set_visible(False)
ax.legend(loc="lower right")

save(fig, "FirstName_LastName_Lab08_StepResponse")
plt.close(fig)

# ======================================================================
# 2. Error-fraction figure (best run)
# ======================================================================
t, T, T0, Tss_data, tau63 = runs[0]
Tss = T_boil                                  # LIGT value — the reference

Gamma = (Tss - T) / (Tss - T0)
valid = (Gamma > 0.02) & (Gamma < 0.95)
t_v = t[valid]
ln_Gamma = np.log(Gamma[valid])

coeffs = np.polyfit(t_v, ln_Gamma, 1)
slope = coeffs[0]
tau_ef = -1.0 / slope

N = np.count_nonzero(valid)
nu = N - 2
resid = ln_Gamma - np.polyval(coeffs, t_v)
s_yx = np.sqrt(np.sum(resid**2)) / np.sqrt(nu)
S_m = s_yx / np.sqrt(np.sum((t_v - t_v.mean()) ** 2))
CI_m = stats.t.ppf(0.975, df=nu) * S_m
CI_tau = tau_ef * CI_m / abs(slope)

fig, ax = plt.subplots(figsize=(6.5, 4.0))
fig.patch.set_facecolor("white")

ax.scatter(t_v, ln_Gamma, s=10, color="red", alpha=0.6, label="data", zorder=3)
ax.plot(t_v, np.polyval(coeffs, t_v), "b-", linewidth=2, label="linear fit")

ax.set_xlabel("Time from plunge (s)")
ax.set_ylabel(r"$\ln \Gamma = \ln[(T_{ss} - T)/(T_{ss} - T_0)]$")
ax.set_title(f"FirstName LastName's Error Fraction Plot — {today}")
ax.grid(which="major", linestyle="--", linewidth=0.5)
ax.grid(which="minor", linestyle="--", linewidth=0.5, alpha=0.5)
ax.minorticks_on()
ax.spines["top"].set_visible(False)
ax.spines["right"].set_visible(False)
ax.legend(loc="upper right")

ax.text(0.02, 0.05,
        f"slope = {slope:.3f} ± {CI_m:.3f} 1/s\n"
        f"$\\tau$ = {tau_ef*1000:.1f} ± {CI_tau*1000:.1f} ms\n"
        f"$s_{{yx}}$ = {s_yx:.4f}",
        transform=ax.transAxes, ha="left", va="bottom")

save(fig, "FirstName_LastName_Lab08_ErrorFraction")
plt.close(fig)

print("Lab 08 example figures regenerated (png + pdf + svg) in", HERE)
