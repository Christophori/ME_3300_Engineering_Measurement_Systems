"""Regenerate Lab 04's example-result figures (editable copy for Chris).

Plotting code extracted from SolutionPackage_TA/Code/Lab04_Solution.ipynb;
reads the seed-locked synthetic data from SolutionPackage_TA/Data/. Each
figure is saved here as .png (600 dpi, used by the .qmd), .pdf, and .svg
(for vector editing in Inkscape — text is kept as editable text).

Edit placements/annotations below and re-run:
    python make_lab04_example_figures.py
The solution notebook remains the source of truth for the TA package; if
you change values (not just cosmetics), update the notebook to match.
"""

from datetime import date
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np

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


# ======================================================================
# 1. Static comparison error plot
# ======================================================================
data = np.loadtxt(DATA / "Static_Comparison.csv", delimiter=",", comments="#")
v_set, v_dmm, v_ads = data[:, 0], data[:, 1], data[:, 2]
err_dmm = (v_dmm - v_set) * 1000
err_ads = (v_ads - v_set) * 1000

fig, ax = plt.subplots(figsize=(6.5, 4.0))
fig.patch.set_facecolor("white")

ax.scatter(v_set, err_dmm, s=75, facecolors="none", edgecolors="red",
           label="Handheld DMM")
ax.scatter(v_set, err_ads, s=75, marker="s", facecolors="none",
           edgecolors="blue", label="ADS (scripted mean)")
ax.axhline(0, color="black", linewidth=0.5)

ax.set_xlabel("W1 set voltage (V)")
ax.set_ylabel("Measured $-$ set (mV)")
ax.set_title(f"FirstName LastName's Static Voltage Comparison Plot — {today}")
ax.grid(which="major", linestyle="--", linewidth=0.5)
ax.grid(which="minor", linestyle="--", linewidth=0.5, alpha=0.5)
ax.minorticks_on()
ax.spines["top"].set_visible(False)
ax.spines["right"].set_visible(False)
ax.legend(loc="upper left")

ax.text(0.98, 0.05,
        f"max |error|: DMM {np.max(np.abs(err_dmm)):.1f} mV, "
        f"ADS {np.max(np.abs(err_ads)):.1f} mV",
        transform=ax.transAxes, ha="right", va="bottom")

save(fig, "FirstName_LastName_Lab04_StaticError")
plt.close(fig)

# ======================================================================
# 2. Five-panel aliasing sweep
# ======================================================================
fs = 1000
f_signals = [100, 450, 500, 550, 1125]
observed = ["100 Hz",
            "450 Hz (barely resolved)",
            "500 Hz, wrong amplitude",
            "450 Hz — aliased!",
            "125 Hz — aliased!"]
x_max_ms = [40, 40, 40, 40, 40]

fig, axes = plt.subplots(5, 1, figsize=(6.5, 10.0))
fig.patch.set_facecolor("white")

for ax, f_sig, obs, x_max in zip(axes, f_signals, observed, x_max_ms):
    d = np.loadtxt(DATA / f"Alias_{f_sig}Hz.csv", delimiter=",", comments="#")
    t, v = d[:, 0], d[:, 1]
    f_app = abs(f_sig - round(f_sig / fs) * fs)

    ax.plot(t * 1000, v, "o-", color="red", markersize=3, linewidth=0.8)
    ax.set_xlim(0, x_max)
    ax.set_ylim(0, 5)
    ax.set_xlabel("Time (ms)")
    ax.set_ylabel("Voltage (V)")
    ax.set_title(f"$f_{{signal}}$ = {f_sig} Hz, $f_s$ = {fs} Hz  |  "
                 f"predicted apparent: {f_app:.0f} Hz  |  observed: {obs}",
                 fontsize=10)
    ax.grid(which="major", linestyle="--", linewidth=0.5)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)

fig.suptitle(f"FirstName LastName's Aliasing Sweep Plot — {today}", y=0.995)
fig.tight_layout(rect=(0, 0, 1, 0.99))

save(fig, "FirstName_LastName_Lab04_Aliasing")
plt.close(fig)

# ======================================================================
# 3. Eye-vs-DAQ plot
# ======================================================================
d = np.loadtxt(DATA / "EyeVsDAQ_Capture.csv", delimiter=",", comments="#")
t_slow, v_slow = d[:, 0], d[:, 1]

f_led, fs_slow = 5.0, 4.5
f_app = abs(f_led - round(f_led / fs_slow) * fs_slow)

fig, ax = plt.subplots(figsize=(6.5, 4.0))
fig.patch.set_facecolor("white")

ax.plot(t_slow, v_slow, "o-", color="red", markersize=4, linewidth=0.8)

ax.set_xlabel("Time (s)")
ax.set_ylabel("Voltage (V)")
ax.set_ylim(-0.5, 5.5)
ax.set_title(f"FirstName LastName's Eye vs. DAQ Plot — {today}")
ax.grid(which="major", linestyle="--", linewidth=0.5)
ax.grid(which="minor", linestyle="--", linewidth=0.5, alpha=0.5)
ax.minorticks_on()
ax.spines["top"].set_visible(False)
ax.spines["right"].set_visible(False)

ax.text(0.98, 0.5,
        f"LED blink: {f_led:.1f} Hz\nsample rate: {fs_slow:.1f} Hz\n"
        f"apparent: {f_app:.1f} Hz",
        transform=ax.transAxes, ha="right", va="center")

save(fig, "FirstName_LastName_Lab04_EyeVsDAQ")
plt.close(fig)

print("Lab 04 example figures regenerated (png + pdf + svg) in", HERE)
