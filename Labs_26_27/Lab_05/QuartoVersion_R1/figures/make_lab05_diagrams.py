"""Generate Lab 05 schematics, pinout diagrams, and screenshot placeholders.

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


def hres(ax, x0, x1, y, label, label_dy=0.28):
    """Horizontal zigzag resistor."""
    n = 6
    xs = np.linspace(x0, x1, 2 * n + 1)
    ys = np.full_like(xs, float(y))
    ys[1:-1:2] = y + 0.13
    ys[2:-1:2] = y - 0.13
    ax.plot(xs, ys, "k-", lw=1.5)
    ax.text((x0 + x1) / 2, y + label_dy, label, ha="center", fontsize=10)


def vres(ax, x, y0, y1, label):
    """Vertical zigzag resistor."""
    n = 6
    ys = np.linspace(y0, y1, 2 * n + 1)
    xs = np.full_like(ys, float(x))
    xs[1:-1:2] = x + 0.13
    xs[2:-1:2] = x - 0.13
    ax.plot(xs, ys, "k-", lw=1.5)
    ax.text(x + 0.22, (y0 + y1) / 2, label, va="center", fontsize=10)


def gnd(ax, x, y):
    ax.plot([x, x], [y, y - 0.18], "k-", lw=1.5)
    for i, w in enumerate([0.22, 0.14, 0.06]):
        ax.plot([x - w, x + w], [y - 0.18 - i * 0.08] * 2, "k-", lw=1.5)


def dot(ax, x, y):
    ax.plot(x, y, "ko", ms=5)


# ----------------------------------------------------------------------
# 1. Non-inverting amplifier schematic (LM358)
# ----------------------------------------------------------------------
fig, ax = plt.subplots(figsize=(6.5, 4.2))
fig.patch.set_facecolor("white")

# Op-amp triangle: vertices (input side x=3.0, output x=4.6)
tri_x = [3.0, 3.0, 4.6, 3.0]
tri_y = [0.8, 2.8, 1.8, 0.8]
ax.plot(tri_x, tri_y, "k-", lw=1.8)
ax.text(3.15, 2.32, "$-$", fontsize=14)
ax.text(3.12, 1.16, "$+$", fontsize=14)
ax.text(3.62, 1.78, "LM358\n(A side)", ha="center", va="center", fontsize=9)

# +IN: W1 input (bottom-left, pin 3)
ax.plot([1.0, 3.0], [1.1, 1.1], "k-", lw=1.5)
ax.plot(1.0, 1.1, "ks", ms=8)
ax.text(0.6, 0.78, "W1 (also to Scope 1+)", fontsize=9)
ax.text(2.65, 1.22, "pin 3", fontsize=8)

# -IN node (top-left, pin 2) with feedback node
ax.plot([2.4, 3.0], [2.4, 2.4], "k-", lw=1.5)
dot(ax, 2.4, 2.4)
ax.text(2.78, 2.52, "pin 2", fontsize=8)

# R1 from node down to GND
ax.plot([2.4, 2.4], [2.4, 2.3], "k-", lw=1.5)
vres(ax, 2.4, 2.3, 1.7, "")
ax.text(2.15, 2.0, "$R_1$ = 10 k$\\Omega$", ha="right", va="center", fontsize=10)
ax.plot([2.4, 2.4], [1.7, 1.6], "k-", lw=1.5)
gnd(ax, 2.4, 1.6)

# R2 feedback from node up and over to output
ax.plot([2.4, 2.4], [2.4, 3.5], "k-", lw=1.5)
ax.plot([2.4, 2.8], [3.5, 3.5], "k-", lw=1.5)
hres(ax, 2.8, 4.4, 3.5, "$R_2$ = 20 k$\\Omega$")
ax.plot([4.4, 5.0], [3.5, 3.5], "k-", lw=1.5)
ax.plot([5.0, 5.0], [3.5, 1.8], "k-", lw=1.5)

# Output (pin 1)
ax.plot([4.6, 6.2], [1.8, 1.8], "k-", lw=1.5)
dot(ax, 5.0, 1.8)
ax.plot(6.2, 1.8, "ko", ms=6, mfc="white")
ax.text(6.32, 1.8, "$V_{out}$ to Scope 2+", va="center", fontsize=10)
ax.text(4.68, 1.95, "pin 1", fontsize=8)

# Supply pins
ax.plot([3.35, 3.35], [2.58, 3.0], "k-", lw=1.2)
ax.text(3.35, 3.1, "pin 8: +12 V (V+)", ha="center", fontsize=9)
ax.plot([3.35, 3.35], [1.02, 0.55], "k-", lw=1.2)
ax.text(3.35, 0.30, "pin 4: $-$12 V  (NOT ground!)", ha="center", fontsize=9, color="red")

ax.text(5.4, 0.5, "Scope 1$-$ and 2$-$ to GND", fontsize=9, style="italic")

ax.set_xlim(0.4, 8.2)
ax.set_ylim(0, 4.1)
ax.axis("off")
save(fig, "NonInverting_Schematic")
plt.close(fig)

# ----------------------------------------------------------------------
# 2. AD622 instrumentation amplifier wiring diagram
# ----------------------------------------------------------------------
fig, ax = plt.subplots(figsize=(6.5, 4.2))
fig.patch.set_facecolor("white")

# Chip body
ax.add_patch(plt.Rectangle((3.0, 0.8), 1.8, 2.6, fill=False, lw=1.8))
ax.add_patch(plt.Circle((3.9, 3.4), 0.12, fill=False, lw=1.2))
ax.text(3.9, 2.1, "AD622", ha="center", fontsize=11)

pins_left = [("1  RG$-$", 3.05), ("2  $-$IN", 2.45), ("3  +IN", 1.85), ("4  V$-$", 1.25)]
pins_right = [("RG+  8", 3.05), ("V+  7", 2.45), ("OUT  6", 1.85), ("REF  5", 1.25)]
for label, y in pins_left:
    ax.plot([2.6, 3.0], [y, y], "k-", lw=1.5)
    ax.text(3.08, y, label, va="center", fontsize=9, ha="left")
for label, y in pins_right:
    ax.plot([4.8, 5.2], [y, y], "k-", lw=1.5)
    ax.text(4.72, y, label, va="center", fontsize=9, ha="right")

# R_G bridging pins 1 and 8 over the top
ax.plot([2.6, 2.3, 2.3], [3.05, 3.05, 3.75], "k-", lw=1.5)
hres(ax, 2.7, 4.3, 3.75, "$R_G \\approx$ 24.9 k$\\Omega$")
ax.plot([2.3, 2.7], [3.75, 3.75], "k-", lw=1.5)
ax.plot([4.3, 5.5, 5.5, 5.2], [3.75, 3.75, 3.05, 3.05], "k-", lw=1.5)

# Left-side connections
ax.plot([2.6, 1.4], [2.45, 2.45], "k-", lw=1.5)
gnd(ax, 1.4, 2.45)
ax.text(1.15, 2.75, "$-$IN to GND\n(Part-6: move to W1)", fontsize=8, ha="left")

ax.plot([2.6, 0.9], [1.85, 1.85], "k-", lw=1.5)
ax.plot(0.9, 1.85, "ks", ms=8)
ax.text(0.85, 1.55, "W1 (also to Scope 1+)", fontsize=9)

ax.plot([2.6, 1.4, 1.4], [1.25, 1.25, 0.6], "k-", lw=1.5)
ax.text(1.35, 0.42, "$-$12 V", ha="center", fontsize=9)

# Right-side connections
ax.plot([5.2, 6.0, 6.0], [2.45, 2.45, 3.0], "k-", lw=1.5)
ax.text(6.0, 3.1, "+12 V", ha="center", fontsize=9)

ax.plot([5.2, 6.6], [1.85, 1.85], "k-", lw=1.5)
ax.plot(6.6, 1.85, "ko", ms=6, mfc="white")
ax.text(6.72, 1.85, "$V_{out}$ to Scope 2+", va="center", fontsize=9)

ax.plot([5.2, 6.0], [1.25, 1.25], "k-", lw=1.5)
gnd(ax, 6.0, 1.25)
ax.text(6.28, 1.1, "REF to GND\n(don't leave floating!)", fontsize=8, color="red")

ax.set_xlim(0.4, 8.6)
ax.set_ylim(0, 4.3)
ax.axis("off")
save(fig, "InAmp_Schematic")
plt.close(fig)

# ----------------------------------------------------------------------
# 3. DIP-8 pinout diagrams (top view)
# ----------------------------------------------------------------------
def dip8(name, title, left_pins, right_pins):
    fig, ax = plt.subplots(figsize=(3.6, 3.2))
    fig.patch.set_facecolor("white")
    ax.add_patch(plt.Rectangle((1.0, 0.5), 1.6, 3.0, fill=False, lw=1.8))
    # notch marks pin-1 end
    th = np.linspace(np.pi, 2 * np.pi, 40)
    ax.plot(1.8 + 0.18 * np.cos(th), 3.5 - 0.18 * np.sin(th) * -1, "k-", lw=1.5)
    ax.text(1.8, 3.75, title + " (top view)", ha="center", fontsize=11)
    ys = [3.1, 2.4, 1.7, 1.0]
    for i, (lp, rp) in enumerate(zip(left_pins, right_pins)):
        ax.plot([0.6, 1.0], [ys[i]] * 2, "k-", lw=2.5)
        ax.plot([2.6, 3.0], [ys[i]] * 2, "k-", lw=2.5)
        ax.text(0.5, ys[i], f"{lp}  {i+1}", ha="right", va="center", fontsize=10)
        ax.text(3.1, ys[i], f"{8-i}  {rp}", ha="left", va="center", fontsize=10)
    ax.set_xlim(-1.4, 5.0)
    ax.set_ylim(0.2, 4.0)
    ax.axis("off")
    save(fig, name)
    plt.close(fig)


dip8("LM358_Pinout", "LM358",
     ["OUT A", "$-$IN A", "+IN A", "V$-$"],
     ["V+", "OUT B", "$-$IN B", "+IN B"])
dip8("AD622_Pinout", "AD622",
     ["RG$-$", "$-$IN", "+IN", "V$-$"],
     ["RG+", "V+", "OUT", "REF"])

# ----------------------------------------------------------------------
# 4. Labeled screenshot placeholders for Chris
# ----------------------------------------------------------------------
PLACEHOLDERS = {
    "Supplies_12V_Setup.png": (
        "SCREENSHOT NEEDED\n\nWaveForms Supplies: V+ set to +12 V, V- set to -12 V,\n"
        "both enabled, Master Enable on.\n\n"
        "Annotate: both voltage fields, both enable switches,\nMaster Enable."
    ),
    "LM358_Circuit_Build_ADS.png": (
        "PHOTO NEEDED\n\nBreadboard build of the LM358 non-inverting amp:\n"
        "chip across center channel, R1 to GND, R2 feedback,\n"
        "W1 to +IN, +12/-12 rails, Scope 1+ on input, 2+ on output.\n\n"
        "Annotate: pin 1 end (notch), R1, R2, all supply and signal wires."
    ),
    "AD622_Circuit_Build_ADS.png": (
        "PHOTO NEEDED\n\nBreadboard build of the AD622 in-amp:\n"
        "R_G across pins 1-8, -IN to GND, W1 to +IN, REF to GND,\n"
        "+12/-12 rails, Scope 2+ on OUT.\n\n"
        "Annotate: R_G, REF-to-GND wire, notch orientation."
    ),
    "Scope_Saturation_Check.png": (
        "SCREENSHOT NEEDED\n\nScope (GUI check, Part-2): Ch1 = W1 input triangle/DC,\n"
        "Ch2 = LM358 output CLIPPING near +10.5 V.\n\n"
        "Annotate: the flat clipped top, the +12 V rail level\nfor comparison."
    ),
    "CommonMode_Scope.png": (
        "SCREENSHOT NEEDED\n\nScope during the Part-6 common-mode demo:\n"
        "Ch1 = 1 V sine driving BOTH inputs, Ch2 = mV-level output.\n"
        "(Consider Add Channel > math or just note the Ch2 scale.)\n\n"
        "Annotate: Ch2 volts/div showing how small the output is."
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
