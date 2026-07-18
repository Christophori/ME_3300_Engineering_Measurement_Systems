"""Editable source for the Lab 03 manual diagrams (matplotlib).

Regenerates, into this folder:
  - Accel_Gravity_FBD.png/.svg            (manual Fig: gravity component FBD)
  - Accel_Calibration_Orientations.png/.svg (manual Fig: 4 calibration poses)

Run from this folder:  uv run python make_lab03_diagrams.py
Tweak the constants below (angles, arrow lengths, colors, fonts), re-run,
then re-render lab03.qmd. SVG copies are written for editing in
Inkscape/Illustrator/PowerPoint if you'd rather adjust visually.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Arc

plt.rcParams['font.family'] = 'serif'
plt.rcParams['font.serif'] = ['Times New Roman', 'Times', 'DejaVu Serif']
plt.rcParams['font.size'] = 10

# ---- shared style knobs -----------------------------------------------------
ARM_COLOR, ARM_LW = 'black', 3
SENSOR_COLOR, SENSOR_SIZE = 'tab:green', 12   # green square = accelerometer
YAXIS_COLOR = 'red'
GRAV_COLOR = 'gray'
COMP_COLOR = 'tab:purple'                     # gravity-component arrow (FBD)

# =============================================================================
# 1. Four-orientation calibration schematic
# =============================================================================
fig, axes = plt.subplots(1, 4, figsize=(6.5, 2.4))
# (name, pendulum angle from straight-down [deg], known a_y [m/s^2])
orients = [('Right', 90, 0.0), ('Up', 180, 9.81), ('Left', -90, 0.0),
           ('Down', 0, -9.81)]

for ax, (name, ang, val) in zip(axes, orients):
    a = np.radians(ang)
    x, y = np.sin(a), -np.cos(a)              # arm tip, unit length from pivot
    ax.plot([0, x], [0, y], color=ARM_COLOR, linewidth=ARM_LW)
    ax.plot(0, 0, 'o', color=ARM_COLOR, markersize=8, fillstyle='none')
    ax.plot(x, y, 's', color=SENSOR_COLOR, markersize=SENSOR_SIZE)
    # +y arrow: from the sensor toward the pivot
    ax.annotate('', xy=(0.45*x, 0.45*y), xytext=(x, y),
                arrowprops=dict(arrowstyle='->', color=YAXIS_COLOR, lw=2))
    ax.text(0.62*x + 0.18, 0.62*y + 0.1, '+y', color=YAXIS_COLOR, fontsize=11)
    # small gravity reference arrow, lower right of each panel
    ax.annotate('', xy=(1.28, -1.28), xytext=(1.28, -0.78),
                arrowprops=dict(arrowstyle='->', color=GRAV_COLOR, lw=1.5))
    ax.text(1.34, -1.05, 'g', color=GRAV_COLOR, fontsize=10, style='italic')
    ax.set_title(f'{name}\n$a_y$ = {val:+.2f} m/s$^2$'.replace('+0.00', '0.00'),
                 fontsize=10)
    ax.set_xlim(-1.5, 1.6)
    ax.set_ylim(-1.5, 1.3)
    ax.set_aspect('equal')
    ax.axis('off')

plt.tight_layout()
fig.savefig('Accel_Calibration_Orientations.png', dpi=300, bbox_inches='tight')
fig.savefig('Accel_Calibration_Orientations.svg', bbox_inches='tight')
print('wrote Accel_Calibration_Orientations .png/.svg')

# =============================================================================
# 2. Gravity-component free-body diagram
# =============================================================================
THETA_DEG = 35                                # display angle of the pendulum

fig2, ax2 = plt.subplots(figsize=(4.2, 4.2))
th0 = np.radians(THETA_DEG)
x, y = np.sin(th0), -np.cos(th0)
ax2.plot([0, x], [0, y], color=ARM_COLOR, linewidth=ARM_LW)          # arm
ax2.plot(0, 0, 'o', color=ARM_COLOR, markersize=9, fillstyle='none') # pivot
ax2.plot([0, 0], [0, -1.25], 'k--', linewidth=1)                     # vertical ref
ax2.plot(x, y, 's', color=SENSOR_COLOR, markersize=14)               # sensor

# +y axis: sensor -> pivot
ax2.annotate('', xy=(0.4*x, 0.4*y), xytext=(x, y),
             arrowprops=dict(arrowstyle='->', color=YAXIS_COLOR, lw=2.5))
ax2.text(0.66*x + 0.1, 0.66*y + 0.12, '+y', color=YAXIS_COLOR, fontsize=13)

# weight vector mg, straight down from the sensor
ax2.annotate('', xy=(x, y - 0.55), xytext=(x, y),
             arrowprops=dict(arrowstyle='->', color=GRAV_COLOR, lw=2.5))
ax2.text(x + 0.05, y - 0.42, 'mg', color=GRAV_COLOR, fontsize=12,
         style='italic')

# component of gravity along +y: -g cos(theta)
ax2.annotate('', xy=(x - 0.45*np.sin(th0), y + 0.45*np.cos(th0)), xytext=(x, y),
             arrowprops=dict(arrowstyle='->', color=COMP_COLOR, lw=2,
                             linestyle='--'))
ax2.text(x - 0.75*np.sin(th0), y + 0.5*np.cos(th0) + 0.04,
         r'$-g\cos\theta$', color=COMP_COLOR, fontsize=12)

# theta arc from vertical
ax2.add_patch(Arc((0, 0), 0.9, 0.9, theta1=270, theta2=270 + THETA_DEG,
                  color='black', lw=1.2))
ax2.text(0.13, -0.55, r'$\theta$', fontsize=13)

ax2.set_xlim(-0.55, 1.45)
ax2.set_ylim(-1.45, 0.35)
ax2.set_aspect('equal')
ax2.axis('off')
plt.tight_layout()
fig2.savefig('Accel_Gravity_FBD.png', dpi=300, bbox_inches='tight')
fig2.savefig('Accel_Gravity_FBD.svg', bbox_inches='tight')
print('wrote Accel_Gravity_FBD .png/.svg')
