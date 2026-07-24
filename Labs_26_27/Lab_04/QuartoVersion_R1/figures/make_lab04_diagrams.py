"""Generate Lab 04 theory diagrams and labeled screenshot placeholders.

Edit and re-run to regenerate. Each diagram is saved as .png (used by the
.qmd) AND .svg (for vector editing in Inkscape etc.). If you edit an SVG by
hand, export it back over the matching .png so the manual picks it up.
Placeholders are PNG-only (they get replaced by real screenshots).
"""

from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np

plt.rcParams["font.family"] = "serif"
plt.rcParams["font.serif"] = ["Times New Roman", "Times", "DejaVu Serif"]
plt.rcParams["font.size"] = 11
plt.rcParams["svg.fonttype"] = "none"   # keep SVG text editable as text

HERE = Path(__file__).resolve().parent


def save(fig, name):
    """Save a diagram as both .png (for the manual) and .svg (for editing)."""
    fig.savefig(HERE / f"{name}.png", dpi=300, bbox_inches="tight")
    fig.savefig(HERE / f"{name}.svg", bbox_inches="tight")

# ----------------------------------------------------------------------
# 1. Anatomy of an AC signal (replaces legacy demoSignal figure)
# ----------------------------------------------------------------------
t = np.linspace(0, 2, 1000)
v = 2.5 + 2.0 * np.sin(2 * np.pi * 1.0 * t)

fig, ax = plt.subplots(figsize=(6.5, 3.6))
fig.patch.set_facecolor("white")
ax.plot(t, v, "b-", lw=2)
ax.axhline(2.5, color="k", ls="--", lw=1)
ax.axhline(0, color="gray", lw=0.8)

# DC offset arrow
ax.annotate("", xy=(0.1, 2.5), xytext=(0.1, 0), arrowprops=dict(arrowstyle="<->", lw=1.2))
ax.text(0.13, 1.25, "DC offset\n(2.5 V)", va="center")
# Vpp arrow
ax.annotate("", xy=(1.35, 4.5), xytext=(1.35, 0.5), arrowprops=dict(arrowstyle="<->", lw=1.2, color="red"))
ax.text(1.38, 2.9, "$V_{pp}$ (4 V)", color="red", va="center")
# Amplitude arrow
ax.annotate("", xy=(0.75, 4.5), xytext=(0.75, 2.5), arrowprops=dict(arrowstyle="<->", lw=1.2, color="green"))
ax.text(0.55, 3.6, "amplitude\n(2 V)", color="green", ha="right", va="center")
# Period arrow
ax.annotate("", xy=(0.25, 4.75), xytext=(1.25, 4.75), arrowprops=dict(arrowstyle="<->", lw=1.2))
ax.text(0.75, 4.85, "period $T = 1/f$", ha="center")

ax.set_xlabel("Time (s)")
ax.set_ylabel("Voltage (V)")
ax.set_ylim(-0.4, 5.4)
ax.set_xlim(0, 2)
ax.grid(which="major", linestyle="--", linewidth=0.5)
ax.spines["top"].set_visible(False)
ax.spines["right"].set_visible(False)
save(fig, "AC_Signal_Anatomy")
plt.close(fig)

# ----------------------------------------------------------------------
# 2. Aliasing illustration: 9 Hz sine sampled at 10 Hz -> 1 Hz alias
# ----------------------------------------------------------------------
f_sig, fs = 9.0, 10.0
t_fine = np.linspace(0, 1, 2000)
t_samp = np.arange(0, 1.0001, 1 / fs)

fig, ax = plt.subplots(figsize=(6.5, 3.6))
fig.patch.set_facecolor("white")
ax.plot(t_fine, np.sin(2 * np.pi * f_sig * t_fine), color="0.75", lw=1,
        label=f"true signal ({f_sig:.0f} Hz)")
ax.plot(t_fine, np.sin(2 * np.pi * (f_sig - fs) * t_fine), "b--", lw=1.8,
        label="apparent signal (1 Hz alias)")
ax.plot(t_samp, np.sin(2 * np.pi * f_sig * t_samp), "ro", ms=8,
        label=f"samples ($f_s$ = {fs:.0f} Hz)")

ax.set_xlabel("Time (s)")
ax.set_ylabel("Signal")
ax.set_xlim(0, 1)
ax.set_ylim(-1.5, 1.9)
ax.legend(loc="upper right", ncol=1, framealpha=0.95)
ax.grid(which="major", linestyle="--", linewidth=0.5)
ax.spines["top"].set_visible(False)
ax.spines["right"].set_visible(False)
save(fig, "Sampling_Alias_Illustration")
plt.close(fig)

# ----------------------------------------------------------------------
# 3. Folding diagram: apparent vs true frequency at fs = 1000 Hz
# ----------------------------------------------------------------------
fs = 1000.0
f_true = np.linspace(0, 2500, 2501)
f_app = np.abs(f_true - np.round(f_true / fs) * fs)

sweep = np.array([100, 450, 500, 550, 1125])
sweep_app = np.abs(sweep - np.round(sweep / fs) * fs)

fig, ax = plt.subplots(figsize=(6.5, 3.8))
fig.patch.set_facecolor("white")
ax.plot(f_true, f_app, "b-", lw=1.8, label="apparent frequency")
ax.plot(f_true[f_true <= 500], f_true[f_true <= 500], color="0.6", ls=":",
        lw=1.5, label="no aliasing (apparent = true)")
ax.plot(sweep, sweep_app, "ro", ms=8, label="this lab's sweep frequencies")
for f, fa in zip(sweep, sweep_app):
    ax.annotate(f"{f:.0f}", (f, fa), textcoords="offset points",
                xytext=(0, 9), ha="center", fontsize=9)
ax.axvline(500, color="k", ls="--", lw=1)
ax.text(510, 620, "$f_N$ = 500 Hz", rotation=0)

ax.set_xlabel("True signal frequency (Hz)")
ax.set_ylabel("Apparent frequency (Hz)")
ax.set_xlim(0, 2500)
ax.set_ylim(0, 700)
ax.legend(loc="upper right", framealpha=0.95, fontsize=9)
ax.grid(which="major", linestyle="--", linewidth=0.5)
ax.spines["top"].set_visible(False)
ax.spines["right"].set_visible(False)
save(fig, "Folding_Diagram")
plt.close(fig)

# ----------------------------------------------------------------------
# 4. LED circuit schematic (W1 branch + DIO 0 branch + Ch1 tap)
# ----------------------------------------------------------------------
def resistor(ax, x0, y0, x1, y1, label):
    """Draw a zigzag resistor between two points (horizontal only)."""
    n = 6
    xs = np.linspace(x0, x1, 2 * n + 1)
    ys = np.full_like(xs, y0)
    ys[1:-1:2] = y0 + 0.14
    ys[2:-1:2] = y0 - 0.14
    ax.plot(xs, ys, "k-", lw=1.5)
    ax.text((x0 + x1) / 2, y0 + 0.3, label, ha="center", fontsize=10)


def led(ax, x, y, label):
    """Draw an LED (triangle + bar + arrows) pointing right at (x, y)."""
    ax.plot([x, x + 0.35, x, x], [y + 0.2, y, y - 0.2, y + 0.2], "k-", lw=1.5)
    ax.plot([x + 0.35, x + 0.35], [y - 0.2, y + 0.2], "k-", lw=2)
    for dy in (0.28, 0.44):
        ax.annotate("", xy=(x + 0.45, y + dy + 0.18), xytext=(x + 0.25, y + dy),
                    arrowprops=dict(arrowstyle="->", lw=1))
    ax.text(x + 0.17, y - 0.55, label, ha="center", fontsize=10)


fig, ax = plt.subplots(figsize=(6.5, 3.2))
fig.patch.set_facecolor("white")

# --- W1 branch (top) ---
y1 = 2.0
ax.plot([0.4, 1.2], [y1, y1], "k-", lw=1.5)
ax.plot(0.4, y1, "ks", ms=8)
ax.text(0.35, y1 - 0.42, "W1 (Wavegen out)", fontsize=10)
resistor(ax, 1.2, y1, 2.6, y1, r"330 $\Omega$")
ax.plot([2.6, 3.4], [y1, y1], "k-", lw=1.5)
led(ax, 3.4, y1, "LED 1")
ax.plot([3.75, 4.6], [y1, y1], "k-", lw=1.5)

# Ch1 tap at the W1 node
ax.plot([0.8, 0.8], [y1, y1 + 0.75], "k-", lw=1.2)
ax.plot(0.8, y1 + 0.75, "ko", ms=6, mfc="white")
ax.text(0.95, y1 + 0.75, "to Scope 1+  (1− to GND)", fontsize=10, va="center")

# --- DIO 0 branch (bottom) ---
y2 = 0.7
ax.plot([0.4, 1.2], [y2, y2], "k-", lw=1.5)
ax.plot(0.4, y2, "ks", ms=8)
ax.text(0.35, y2 - 0.42, "DIO 0 (3.3 V logic)", fontsize=10)
resistor(ax, 1.2, y2, 2.6, y2, r"330 $\Omega$")
ax.plot([2.6, 3.4], [y2, y2], "k-", lw=1.5)
led(ax, 3.4, y2, "LED 2")
ax.plot([3.75, 4.6], [y2, y2], "k-", lw=1.5)

# --- shared ground rail ---
ax.plot([4.6, 4.6], [y2, y1], "k-", lw=1.5)
ax.plot([4.6, 5.0], [(y1 + y2) / 2, (y1 + y2) / 2], "k-", lw=1.5)
for i, w in enumerate([0.3, 0.2, 0.1]):
    ax.plot([5.0 + i * 0.07, 5.0 + i * 0.07], [(y1 + y2) / 2 - w, (y1 + y2) / 2 + w],
            "k-", lw=1.5)
ax.text(5.05, (y1 + y2) / 2 - 0.55, "GND", fontsize=10, ha="center")

ax.text(2.0, 2.9, "Anode (long leg) toward the resistor; cathode (short leg) to GND",
        fontsize=9, style="italic")

ax.set_xlim(0, 5.6)
ax.set_ylim(0, 3.2)
ax.axis("off")
save(fig, "LED_Circuit_Schematic")
plt.close(fig)

# ----------------------------------------------------------------------
# 5. Labeled screenshot placeholders for Chris
# ----------------------------------------------------------------------
PLACEHOLDERS = {
    "Wavegen_Sine_Setup.png": (
        "SCREENSHOT NEEDED\n\nWaveForms Wavegen: W1 configured as\n"
        "Sine, 100 Hz, 2 V amplitude, 2.5 V offset, Running.\n\n"
        "Annotate: waveform type, Frequency, Amplitude,\nOffset fields, and the Run button."
    ),
    "Scope_Wavegen_Loopback.png": (
        "SCREENSHOT NEEDED\n\nScope showing the W1 loopback sine\n"
        "(100 Hz, 0.5-4.5 V) with X-cursors measuring one period.\n\n"
        "Annotate: Ch1 trace, cursor deltaX readout (~10 ms),\nand the Wavegen still running."
    ),
    "LED_Circuit_Build_ADS.png": (
        "PHOTO NEEDED\n\nBreadboard build: W1 -> 330 ohm -> LED1 -> GND,\n"
        "DIO0 -> 330 ohm -> LED2 -> GND, Scope 1+ tap at W1 node,\n1- to GND.\n\n"
        "Annotate: both LEDs (polarity), both resistors,\nW1/DIO0/GND/1+/1- wires."
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
