"""Generate Lab 06 theory diagrams and labeled screenshot placeholders.

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


def save_fig(fig, name):
    """Save a diagram as both .png (for the manual) and .svg (for editing)."""
    fig.savefig(HERE / f"{name}.png", dpi=300, bbox_inches="tight")
    fig.savefig(HERE / f"{name}.svg", bbox_inches="tight")


def zigzag(ax, p0, p1, label=None, label_off=(0.0, 0.0), n=5, amp=0.10, fs=9):
    """Resistor zigzag along the segment p0 -> p1 (any orientation)."""
    p0, p1 = np.array(p0, float), np.array(p1, float)
    d = p1 - p0
    length = np.hypot(*d)
    u = d / length
    perp = np.array([-u[1], u[0]])
    ts = np.linspace(0, 1, 2 * n + 1)
    pts = p0[None, :] + ts[:, None] * d[None, :]
    pts[1:-1:2] += perp * amp
    pts[2:-1:2] -= perp * amp
    ax.plot(pts[:, 0], pts[:, 1], "k-", lw=1.5)
    if label:
        mid = (p0 + p1) / 2 + np.array(label_off)
        ax.text(mid[0], mid[1], label, ha="center", va="center", fontsize=fs)


def gnd(ax, x, y):
    ax.plot([x, x], [y, y - 0.15], "k-", lw=1.5)
    for i, wd in enumerate([0.18, 0.11, 0.05]):
        ax.plot([x - wd, x + wd], [y - 0.15 - i * 0.07] * 2, "k-", lw=1.5)


# ----------------------------------------------------------------------
# 1. Cantilever beam with two gauges (side view)
# ----------------------------------------------------------------------
fig, ax = plt.subplots(figsize=(6.5, 3.4))
fig.patch.set_facecolor("white")

# wall with hatching
ax.add_patch(plt.Rectangle((0.4, 0.6), 0.35, 2.4, facecolor="0.85", edgecolor="k", hatch="///"))
# beam
ax.add_patch(plt.Rectangle((0.75, 1.65), 5.0, 0.30, facecolor="0.95", edgecolor="k", lw=1.5))

# gauges at x ~ 1.7
for y, name, sense in [(1.95, "top gauge", "tension  ($R + \\Delta R$)"),
                       (1.65, "bottom gauge", "compression  ($R - \\Delta R$)")]:
    ax.add_patch(plt.Rectangle((1.5, y - 0.06 if y == 1.65 else y),
                               0.5, 0.06, facecolor="goldenrod", edgecolor="k", lw=0.8))
ax.annotate("top gauge — tension ($R+\\Delta R$)", xy=(1.75, 2.02), xytext=(1.15, 2.75),
            fontsize=9, arrowprops=dict(arrowstyle="->", lw=0.9))
ax.annotate("bottom gauge — compression ($R-\\Delta R$)", xy=(1.75, 1.58), xytext=(1.5, 0.85),
            fontsize=9, arrowprops=dict(arrowstyle="->", lw=0.9))

# load at free end
ax.annotate("", xy=(5.55, 0.95), xytext=(5.55, 1.62),
            arrowprops=dict(arrowstyle="-|>", lw=2, color="red"))
ax.text(5.68, 1.25, "$P = mg$", color="red", fontsize=11)

# dimension L: gauge center to load point
ax.annotate("", xy=(1.75, 2.45), xytext=(5.55, 2.45),
            arrowprops=dict(arrowstyle="<->", lw=1.1))
ax.text(3.65, 2.55, "$L$ (tape measure)", ha="center", fontsize=10)
ax.plot([1.75, 1.75], [2.0, 2.45], "k:", lw=0.8)
ax.plot([5.55, 5.55], [1.95, 2.45], "k:", lw=0.8)

# thickness t
ax.annotate("", xy=(6.05, 1.65), xytext=(6.05, 1.95),
            arrowprops=dict(arrowstyle="<->", lw=1.1))
ax.text(6.18, 1.80, "$t$ (micrometer)", va="center", fontsize=10)

ax.text(0.45, 0.30, "width $w$ measured with the caliper (into the page)",
        fontsize=9, style="italic")

ax.set_xlim(0, 8.4)
ax.set_ylim(0, 3.1)
ax.axis("off")
save_fig(fig, "Cantilever_Beam_Gauges")
plt.close(fig)

# ----------------------------------------------------------------------
# 2. Half-bridge + AD622 schematic
# ----------------------------------------------------------------------
fig, ax = plt.subplots(figsize=(6.5, 4.6))
fig.patch.set_facecolor("white")

# Bridge diamond: excitation left/right, outputs top/bottom
Lx, Rx, T, B = (0.9, 3.1), (3.7, 3.1), (2.3, 5.0), (2.3, 1.2)

zigzag(ax, Lx, T, "top gauge\n$R+\\Delta R$", label_off=(-0.62, 0.22))
zigzag(ax, Lx, B, "bottom gauge\n$R-\\Delta R$", label_off=(-0.68, -0.22))
zigzag(ax, T, Rx, "$R_3$ = 350 $\\Omega$", label_off=(0.72, 0.22))
zigzag(ax, B, Rx, "$R_4$ = 350 $\\Omega$", label_off=(0.75, -0.22))
for p in (Lx, Rx, T, B):
    ax.plot(*p, "ko", ms=5)

# excitation (left) and ground (right)
ax.plot([0.9, 0.35], [3.1, 3.1], "k-", lw=1.5)
ax.plot(0.35, 3.1, "ks", ms=7)
ax.text(0.30, 3.38, "$V_i$ (5 V switch)", fontsize=9)
ax.plot([3.7, 4.35], [3.1, 3.1], "k-", lw=1.5)
gnd(ax, 4.35, 3.1)

# AD622 box
BX0, BY0, BX1, BY1 = 5.6, 3.2, 7.3, 5.9
ax.add_patch(plt.Rectangle((BX0, BY0), BX1 - BX0, BY1 - BY0, fill=False, lw=1.8))
ax.text((BX0 + BX1) / 2, 4.55, "AD622\n$G \\approx 500$", ha="center", fontsize=10)

# bridge outputs to the in-amp inputs
ax.plot([2.3, 2.3, BX0], [5.0, 5.5, 5.5], "k-", lw=1.5)      # top node -> +IN
ax.text(BX0 + 0.08, 5.5, "3 (+IN)", fontsize=8, va="center")
ax.plot([2.3, 5.0, 5.0, BX0], [1.2, 1.2, 3.7, 3.7], "k-", lw=1.5)   # bottom -> -IN
ax.text(BX0 + 0.08, 3.7, "2 ($-$IN)", fontsize=8, va="center")

# R_G bracket on the right edge (pins 8 and 1)
ax.plot([BX1, 7.75], [5.4, 5.4], "k-", lw=1.2)
ax.plot([BX1, 7.75], [3.8, 3.8], "k-", lw=1.2)
zigzag(ax, (7.75, 5.4), (7.75, 3.8), None)
ax.text(7.95, 4.6, "$R_G$ = 102 $\\Omega$\n(sets $G$, Lab 05)", fontsize=9, va="center")
ax.text(BX1 - 0.15, 5.55, "8", fontsize=8)
ax.text(BX1 - 0.15, 3.55, "1", fontsize=8)

# supplies
ax.plot([6.1, 6.1], [BY1, BY1 + 0.35], "k-", lw=1.2)
ax.text(6.1, BY1 + 0.47, "7: +12 V", ha="center", fontsize=8)
ax.plot([6.1, 6.1], [BY0, BY0 - 0.35], "k-", lw=1.2)
ax.text(6.1, BY0 - 0.55, "4: $-$12 V", ha="center", fontsize=8)

# REF to ground
ax.plot([7.05, 7.05], [BY0, 2.95], "k-", lw=1.2)
gnd(ax, 7.05, 2.95)
ax.text(7.2, 3.05, "5: REF", fontsize=8)

# OUT from the bottom edge, exiting right below everything
ax.plot([6.6, 6.6, 8.6], [BY0, 2.35, 2.35], "k-", lw=1.5)
ax.plot(8.6, 2.35, "ko", ms=6, mfc="white")
ax.text(8.7, 2.35, "6: OUT → Scope 1+\n(1− → GND)", va="center", fontsize=9)

ax.text(0.35, 5.9, "Bridge output = difference of the two mid-node voltages;\n"
        "measure $V_i$ at the bridge with the DMM",
        fontsize=9, style="italic")

ax.set_xlim(0, 10.6)
ax.set_ylim(0.3, 6.6)
ax.axis("off")
save_fig(fig, "Half_Bridge_Schematic")
plt.close(fig)

# ----------------------------------------------------------------------
# 3. Labeled screenshot placeholders for Chris
# ----------------------------------------------------------------------
PLACEHOLDERS = {
    "Beam_Apparatus_Photo.png": (
        "PHOTO NEEDED\n\nCantilever beam apparatus: clamp, beam, both strain\n"
        "gauges (or their lead wires), hanger and weight set.\n\n"
        "Annotate: gauge location, load point, the L dimension,\nlead-wire colors "
        "(top vs bottom gauge)."
    ),
    "Bridge_Circuit_Build_ADS.png": (
        "PHOTO NEEDED\n\nBreadboard build: half-bridge (two gauge lead pairs +\n"
        "two 350-ohm resistors), AD622 with R_G = 102 ohm,\n5 V switch wiring, "
        "+/-12 V rails, Scope 1+ on OUT.\n\n"
        "Annotate: all four bridge arms, R_G, REF-to-GND,\nexcitation and output wires."
    ),
    "Scope_ZeroLoad_Drift.png": (
        "SCREENSHOT NEEDED\n\nWaveForms Scope, zero-load check: amplifier output\n"
        "at ~1-3 V DC; then a gentle fingertip press on the beam tip\n"
        "visibly deflecting the trace.\n\n"
        "Annotate: the DC zero-load level, the press response,\nand (if visible) slow drift."
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
