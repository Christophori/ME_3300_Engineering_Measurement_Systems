"""Generate Lab 08 theory diagrams and labeled screenshot placeholders."""

from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np

plt.rcParams["font.family"] = "serif"
plt.rcParams["font.serif"] = ["Times New Roman", "Times", "DejaVu Serif"]
plt.rcParams["font.size"] = 11

HERE = Path(__file__).resolve().parent

# ----------------------------------------------------------------------
# 1. Signal chain: bead -> AD8495 breakout -> LM358 follower -> Scope
# ----------------------------------------------------------------------
fig, ax = plt.subplots(figsize=(6.5, 3.4))
fig.patch.set_facecolor("white")

# thermocouple bead + leads
ax.plot([0.3, 1.3], [2.1, 2.35], "-", color="goldenrod", lw=2)
ax.plot([0.3, 1.3], [1.9, 2.15], "-", color="firebrick", lw=2)
ax.plot(0.28, 2.0, "o", color="k", ms=10)
ax.text(0.55, 1.45, "K-type bead\n(the sensor —\nonly this gets wet)",
        ha="center", fontsize=9)
ax.text(0.62, 2.62, "chromel /\nalumel leads", ha="center", fontsize=8)

# AD8495 breakout
ax.add_patch(plt.Rectangle((1.3, 1.5), 2.0, 1.3, fill=False, lw=1.8))
ax.text(2.3, 2.42, "Adafruit AD8495", ha="center", fontsize=10)
ax.text(2.3, 2.05, "K-type amp +\ncold-junction comp.", ha="center", fontsize=8)
ax.text(2.3, 1.62, "$V = 1.25 + 0.005\\,T$", ha="center", fontsize=9)
# power stub
ax.plot([1.75, 1.75], [2.8, 3.15], "k-", lw=1.2)
ax.text(1.75, 3.25, "Vin: 5 V switch", ha="center", fontsize=8)
ax.plot([2.95, 2.95], [2.8, 3.15], "k-", lw=1.2)
ax.text(2.95, 3.25, "GND", ha="center", fontsize=8)

# wire to follower
ax.plot([3.3, 4.1], [2.0, 2.0], "k-", lw=1.5)
ax.text(3.7, 2.12, "OUT", ha="center", fontsize=8)

# LM358 follower triangle
tri_x = [4.1, 4.1, 5.3, 4.1]
tri_y = [1.45, 2.55, 2.0, 1.45]
ax.plot(tri_x, tri_y, "k-", lw=1.8)
ax.text(4.22, 2.22, "$+$", fontsize=12)
ax.text(4.22, 1.68, "$-$", fontsize=12)
ax.text(4.55, 2.0, "LM358", fontsize=8, va="center")
# feedback: output to -IN
ax.plot([4.1, 3.9, 3.9], [1.75, 1.75, 1.05], "k-", lw=1.2)
ax.plot([3.9, 5.55, 5.55], [1.05, 1.05, 2.0], "k-", lw=1.2)
# wait — feedback from output node:
# supplies
ax.plot([4.62, 4.62], [2.31, 2.75], "k-", lw=1.0)
ax.text(4.62, 2.85, "+12 V", ha="center", fontsize=8)
ax.plot([4.62, 4.62], [1.69, 1.35], "k-", lw=1.0)
ax.text(4.42, 1.28, "$-$12 V", ha="right", fontsize=8)

# output to scope
ax.plot([5.3, 6.5], [2.0, 2.0], "k-", lw=1.5)
ax.plot(5.55, 2.0, "ko", ms=4)
ax.plot(6.5, 2.0, "ko", ms=6, mfc="white")
ax.text(6.6, 2.0, "Scope 1+\n(1− → GND)", va="center", fontsize=9)
ax.text(4.7, 0.62, "voltage follower: $V_{out} = V_{in}$ — isolates the amplifier from the DAQ",
        ha="center", fontsize=8, style="italic")

ax.set_xlim(0, 8.2)
ax.set_ylim(0.5, 3.6)
ax.axis("off")
fig.savefig(HERE / "TC_Signal_Chain.png", dpi=300, bbox_inches="tight")
plt.close(fig)

# ----------------------------------------------------------------------
# 2. First-order step response anatomy
# ----------------------------------------------------------------------
tau = 1.0
t = np.linspace(-0.5, 5.5, 800)
T0, Tss = 20.0, 100.0
T = np.where(t < 0, T0, Tss + (T0 - Tss) * np.exp(-t / tau))

fig, ax = plt.subplots(figsize=(6.5, 4.0))
fig.patch.set_facecolor("white")
ax.plot(t, T, "b-", lw=2.2)

# levels
ax.axhline(Tss, color="0.4", ls="--", lw=1)
ax.text(5.45, Tss + 1.5, "$T_{ss}$", ha="right", fontsize=11)
ax.axhline(T0, color="0.4", ls="--", lw=1)
ax.text(5.45, T0 + 1.5, "$T_0$", ha="right", fontsize=11)

# 63.2% marker
T63 = T0 + 0.632 * (Tss - T0)
ax.plot([0, 1, 1], [T63, T63, 0], "r:", lw=1.4)
ax.plot(1, T63, "ro", ms=7)
ax.text(1.12, T63 - 4.5, "63.2% of the step\nat $t = \\tau$", fontsize=10, color="red")

# initial-slope tangent hits Tss at tau
ax.plot([0, 1.55], [T0, T0 + (Tss - T0) * 1.55], color="green", ls="-.", lw=1.2)
ax.text(0.30, 88, "initial slope\nreaches $T_{ss}$\nat $t = \\tau$", fontsize=9, color="green")

# 5 tau settled
ax.plot([5, 5], [0, Tss], ":", color="purple", lw=1.2)
ax.text(5.03, 40, "$t = 5\\tau$:\nwithin 1%\n(settled)", fontsize=9, color="purple")

ax.set_xlabel("Time  (in units of $\\tau$)")
ax.set_ylabel("Temperature (°C)")
ax.set_xlim(-0.5, 5.5)
ax.set_ylim(10, 112)
ax.grid(which="major", linestyle="--", linewidth=0.5)
ax.spines["top"].set_visible(False)
ax.spines["right"].set_visible(False)
fig.savefig(HERE / "FirstOrder_Response_Anatomy.png", dpi=300, bbox_inches="tight")
plt.close(fig)

# ----------------------------------------------------------------------
# 3. Labeled screenshot placeholders for Chris
# ----------------------------------------------------------------------
PLACEHOLDERS = {
    "Bath_Setup_Photo.png": (
        "PHOTO NEEDED\n\nHeated bath station: hot plate, beaker with stirrer,\n"
        "LIGT hung from the stand at calibration depth,\n"
        "thermocouple positioned beside (not touching) the beaker.\n\n"
        "Annotate: LIGT depth, stirrer, safe handling zone,\nbead entry point."
    ),
    "TC_Circuit_Build_ADS.png": (
        "PHOTO NEEDED\n\nBreadboard build: AD8495 breakout (Vin to 5 V switch,\n"
        "GND, OUT), LM358 voltage follower (+12/-12, feedback wire),\n"
        "Scope 1+ on the follower output.\n\n"
        "Annotate: breakout pins, follower feedback wire,\nall supply and signal wires."
    ),
    "Scope_Pinch_Check.png": (
        "SCREENSHOT NEEDED\n\nWaveForms Scope during the live check: trace at the\n"
        "room-temperature level (~1.36 V), then rising while the\n"
        "bead is pinched between fingers.\n\n"
        "Annotate: the DC level, the pinch response, and the\nexpected 1.25 + 0.005*T level arithmetic."
    ),
}

for name, text in PLACEHOLDERS.items():
    fig, ax = plt.subplots(figsize=(8, 4.5))
    fig.patch.set_facecolor("0.85")
    ax.set_facecolor("0.85")
    ax.text(0.5, 0.5, text, ha="center", va="center", fontsize=13, wrap=True)
    ax.set_xticks([])
    ax.set_yticks([])
    for s in ax.spines.values():
        s.set_edgecolor("0.4")
        s.set_linestyle("--")
    fig.savefig(HERE / name, dpi=150, bbox_inches="tight", facecolor="0.85")
    plt.close(fig)

print("diagrams + placeholders written to", HERE)
