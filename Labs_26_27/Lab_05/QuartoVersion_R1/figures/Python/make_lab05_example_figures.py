"""Regenerate Lab 05's example-result figure (editable copy for Chris).

Plotting code extracted from SolutionPackage_TA/Code/Lab05_Solution.ipynb;
reads the seed-locked synthetic sweeps from SolutionPackage_TA/Data/. The
figure is saved here as .png (600 dpi, used by the .qmd), .pdf, and .svg
(for vector editing in Inkscape — text is kept as editable text).

Edit placements/annotations below and re-run:
    python make_lab05_example_figures.py
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


# ----- expected gains from the synthetic "measured" resistors ------------
R1, R2, R_G = 9960.0, 19890.0, 24870.0
G_expected_lm = 1 + R2 / R1
G_expected_ad = 1 + 50500.0 / R_G


def fit_gain(fname):
    """Load a sweep CSV, fit its linear region, return everything needed."""
    data = np.loadtxt(fname, delimiter=",", comments="#")
    v_in, v_out = data[:, 1], data[:, 2]

    linear = np.abs(v_out) < 9.5
    coeffs = np.polyfit(v_in[linear], v_out[linear], 1)
    G_fit, offset = coeffs

    N = np.count_nonzero(linear)
    nu = N - 2
    resid = v_out[linear] - np.polyval(coeffs, v_in[linear])
    s_yx = np.sqrt(np.sum(resid**2)) / np.sqrt(nu)
    S_G = s_yx / np.sqrt(np.sum((v_in[linear] - v_in[linear].mean()) ** 2))
    CI_G = stats.t.ppf(0.975, df=nu) * S_G

    return v_in, v_out, linear, coeffs, G_fit, CI_G, s_yx


lm = fit_gain(DATA / "LM358_Sweep.csv")
ad = fit_gain(DATA / "AD622_Sweep.csv")

# ----- the two-panel deliverable figure ----------------------------------
fig, axes = plt.subplots(2, 1, figsize=(6.5, 6.0))
fig.patch.set_facecolor("white")

panels = [
    (axes[0], *lm, G_expected_lm, "LM358 non-inverting amplifier"),
    (axes[1], *ad, G_expected_ad, "AD622 instrumentation amplifier"),
]

for ax, v_in, v_out, linear, coeffs, G_fit, CI_G, s_yx, G_exp, name in panels:
    ax.scatter(v_in, v_out, s=75, facecolors="none", edgecolors="red",
               label="measured", zorder=3)
    ax.plot(v_in, np.polyval(coeffs, v_in), "b--", linewidth=1,
            label="fit extended (ideal)")
    ax.plot(v_in[linear], np.polyval(coeffs, v_in[linear]), "b-",
            linewidth=2, label="linear-region fit")

    ax.set_xlabel("$V_{in}$ measured (V)")
    ax.set_ylabel("$V_{out}$ measured (V)")
    ax.set_title(f"{name} — expected G = {G_exp:.4f}", fontsize=10)
    ax.grid(which="major", linestyle="--", linewidth=0.5)
    ax.grid(which="minor", linestyle="--", linewidth=0.5, alpha=0.5)
    ax.minorticks_on()
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.legend(loc="upper left", fontsize=9)

    ax.text(0.98, 0.05,
            f"$G_{{fit}}$ = {G_fit:.4f} ± {CI_G:.4f} (95% CI)\n"
            f"$s_{{yx}}$ = {s_yx:.4f} V\n"
            f"saturates at {v_out.max():.2f} V / {v_out.min():.2f} V",
            transform=ax.transAxes, ha="right", va="bottom", fontsize=9)

fig.suptitle(f"FirstName LastName's Operational Amplifier Gain Plot — {today}",
             y=0.995)
fig.tight_layout(rect=(0, 0, 1, 0.98))

save(fig, "FirstName_LastName_Lab05_AmpGain")
plt.close(fig)

print("Lab 05 example figure regenerated (png + pdf + svg) in", HERE)
