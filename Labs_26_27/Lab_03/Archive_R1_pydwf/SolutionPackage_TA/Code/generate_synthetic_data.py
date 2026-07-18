"""Lab 03 synthetic data + manual figures (TA use only). Seed-locked (3300).

Physics: Lab 02 damped pendulum ODE. Accelerometer y-axis (pointing from
sensor toward pivot) reads proper acceleration:
    a_y = -thetadot^2 * r - g*cos(theta)
Statics check: hanging down (theta=0) -> -9.81; up (180deg) -> +9.81,
matching the 4-orientation calibration table.

Sensor models (legacy-informed, Labs_25_26/Lab_03 data):
  pot:   V = (theta_deg - a0_pot)/a1_pot,  a1=89.7 deg/V, a0=-148.1 (Lab 02)
  accel: a = a1_acc*V + a0_acc, a1=-47.4 (m/s^2)/V, a0=81.2 (~206 mV/g)
"""
import numpy as np
import matplotlib.pyplot as plt
from scipy import stats
from scipy.integrate import solve_ivp

rng = np.random.default_rng(3300)
plt.rcParams['font.family'] = 'serif'
plt.rcParams['font.serif'] = ['Times New Roman', 'Times', 'DejaVu Serif']
plt.rcParams['font.size'] = 10

BASE = ('/sessions/kind-bold-thompson/mnt/ME_3300_Engineering_Measurement_Systems/'
        'Labs_26_27/Lab_03/')
DATA = BASE + 'SolutionPackage_TA/Data/'
FIGP = BASE + 'QuartoVersion_R1/figures/Python/'
FIG = BASE + 'QuartoVersion_R1/figures/'

g = 9.81
# True sensor constants (slightly perturbed from round numbers)
A1_ACC, A0_ACC = -47.42, 81.31          # a = A1*V + A0
A1_POT, A0_POT = 89.70, -148.10         # theta_deg = A1*V + A0  (Lab 02)
def v_of_accel(a): return (a - A0_ACC) / A1_ACC
def v_of_angle(deg): return (deg - A0_POT) / A1_POT

# ---------------------------------------------------------------------------
# 1. Accelerometer calibration summary CSV (what the pydwf script produces)
# ---------------------------------------------------------------------------
known_accel = np.array([0.0, 9.81, 0.0, -9.81])      # right, up, left, down
mean_voltages = v_of_accel(known_accel) + rng.normal(0, 0.004, 4)
np.savetxt(DATA + 'accel_calibration_data.csv',
           np.column_stack([known_accel, mean_voltages]),
           header='accel_m_per_s2,voltage_V', delimiter=',', fmt='%.6f')

# Fit (as the solution does)
coeffs_acc = np.polyfit(mean_voltages, known_accel, 1)
acc_fit = np.polyval(coeffs_acc, mean_voltages)
N, nu = 4, 2
resid = known_accel - acc_fit
norm_r = np.sqrt(np.sum(resid**2))
s_yx = norm_r / np.sqrt(nu)
t_val = stats.t.ppf(0.975, df=nu)
CI = t_val * s_yx
S_a1 = s_yx / np.sqrt(np.sum((mean_voltages - mean_voltages.mean())**2))
print(f"acc cal: a = {coeffs_acc[0]:.4f} V {coeffs_acc[1]:+.4f}; "
      f"norm={norm_r:.4f}, s_yx={s_yx:.4f}, t={t_val:.3f}, S_a1={S_a1:.4f}")

# ---------------------------------------------------------------------------
# 2. Swing recording: 1000 Hz, 15 s, 2 channels (Scope Record export style)
# ---------------------------------------------------------------------------
L_eff, r, zeta = 0.240, 0.216, 0.030
wn = np.sqrt(g / L_eff)

def pend(t, y):
    th, om = y
    return [om, -2*zeta*wn*om - wn**2*np.sin(th)]

fs, T, t_hold = 1000, 15.0, 1.2
t_all = np.arange(0, T, 1/fs)
mask = t_all >= t_hold
t_sw = t_all[mask] - t_hold
sol = solve_ivp(pend, (0, t_sw[-1]), [np.radians(88.0), 0.0],
                t_eval=t_sw, max_step=0.002)
theta = np.concatenate([np.full((~mask).sum(), np.radians(88.0)), sol.y[0]])
thdot = np.concatenate([np.zeros((~mask).sum()), sol.y[1]])

a_y = -thdot**2 * r - g*np.cos(theta)                  # true sensor accel
v_pot = v_of_angle(np.degrees(theta)) + rng.normal(0, 0.0015, t_all.size)
v_acc = v_of_accel(a_y) + rng.normal(0, 0.008, t_all.size)

hdr = ("#Digilent WaveForms Oscilloscope Record\n"
       "#Device Name: Analog Discovery Studio\n"
       "#Serial Number: SN:210415B1A0BE\n"
       "#Date Time: 2026-09-16 14:22:41\n"
       f"#Sample rate: {fs}Hz\n"
       f"#Samples: {t_all.size}\n"
       "Time (s),Channel 1 (V),Channel 2 (V)\n")
with open(DATA + 'FirstName_LastName_Lab03_Swing.csv', 'w') as f:
    f.write(hdr)
    for a, b, c in zip(t_all, v_pot, v_acc):
        f.write(f"{a:.6f},{b:.6f},{c:.6f}\n")
print("swing written:", t_all.size, "samples")

# ---------------------------------------------------------------------------
# 3. Example figure: accelerometer calibration plot
# ---------------------------------------------------------------------------
v_rng = np.linspace(mean_voltages.min()-0.03, mean_voltages.max()+0.03, 200)
fig, ax = plt.subplots(figsize=(6.5, 4.0))
fig.patch.set_facecolor('white')
ax.scatter(mean_voltages, known_accel, s=75, color='red', zorder=5,
           label='Calibration data')
ax.plot(v_rng, np.polyval(coeffs_acc, v_rng), 'b-', linewidth=2,
        label='Linear fit')
ax.plot(v_rng, np.polyval(coeffs_acc, v_rng)+CI, 'k--', linewidth=1,
        label='95% CI')
ax.plot(v_rng, np.polyval(coeffs_acc, v_rng)-CI, 'k--', linewidth=1)
txt = (f'a = {coeffs_acc[0]:.4f}V {coeffs_acc[1]:+.4f}\n'
       f'Norm of residuals = {norm_r:.4f} m/s$^2$\n'
       f'$s_{{yx}}$ = {s_yx:.4f} m/s$^2$\n'
       f'$S_{{a_1}}$ = {S_a1:.4f} (m/s$^2$)/V')
ax.text(0.35, 0.95, txt, transform=ax.transAxes, fontsize=10,
        verticalalignment='top',
        bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))
ax.set_xlabel('Accelerometer Voltage (V)')
ax.set_ylabel('Acceleration (m/s$^2$)')
ax.set_title("FirstName LastName's Accelerometer Calibration Plot — 2026-09-16")
ax.legend(loc='lower left')
ax.grid(True, which='both', linestyle='--', linewidth=0.5)
ax.minorticks_on()
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)
plt.tight_layout()
for ext in ('png', 'pdf'):
    fig.savefig(f'{FIGP}FirstName_LastName_Lab03_AccelCalibration.{ext}',
                dpi=600 if ext == 'pdf' else 300, bbox_inches='tight')

# ---------------------------------------------------------------------------
# 4. Example figure: normal acceleration comparison (solution pipeline)
# ---------------------------------------------------------------------------
angle_deg = np.polyval([A1_POT, A0_POT], v_pot)     # student pot calibration
accel_ms2 = np.polyval(coeffs_acc, v_acc)           # student acc calibration

hold_mean = angle_deg[:500].mean()
idx0 = np.argmax(np.abs(angle_deg - hold_mean) > 2.0)
t = t_all[idx0:] - t_all[idx0]
th = np.radians(angle_deg[idx0:])
a_meas = accel_ms2[idx0:]

dt = 1/fs
thd = np.gradient(th, dt)
a_calc = -(thd**2) * r
a_meas_n = a_meas + g*np.cos(th)                    # remove gravity component
print(f"release idx {idx0} t={t_all[idx0]:.3f}s; "
      f"peak a_calc={a_calc.min():.2f}, peak a_meas_n={a_meas_n.min():.2f}")

fig2, ax2 = plt.subplots(figsize=(6.5, 4.0))
fig2.patch.set_facecolor('white')
ax2.plot(t, a_calc, color='blue', linewidth=1.0, alpha=0.8,
         label=r'Calculated from $-\dot{\theta}^2 r$')
ax2.plot(t, a_meas_n, color='red', linewidth=1.5,
         label='Measured (accelerometer)')
ax2.set_xlabel('Time (s)')
ax2.set_ylabel('Normal Acceleration (m/s$^2$)')
ax2.set_title("FirstName LastName's Normal Acceleration Plot — 2026-09-16")
ax2.set_xlim(0, 12)
ax2.legend(loc='lower right')
ax2.grid(True, which='both', linestyle='--', linewidth=0.5)
ax2.minorticks_on()
ax2.spines['top'].set_visible(False)
ax2.spines['right'].set_visible(False)
plt.tight_layout()
for ext in ('png', 'pdf'):
    fig2.savefig(f'{FIGP}FirstName_LastName_Lab03_NormalAccel.{ext}',
                 dpi=600 if ext == 'pdf' else 300, bbox_inches='tight')

# ---------------------------------------------------------------------------
# 5. Orientation-schematic figure (replaces old manual's table sketches)
# ---------------------------------------------------------------------------
fig3, axes = plt.subplots(1, 4, figsize=(6.5, 2.4))
orients = [('Right', 90, 0.0), ('Up', 180, 9.81), ('Left', -90, 0.0),
           ('Down', 0, -9.81)]
for ax3, (name, ang, val) in zip(axes, orients):
    a = np.radians(ang)
    x, y = np.sin(a), -np.cos(a)          # pendulum direction from pivot
    ax3.plot([0, x], [0, y], 'k-', linewidth=3)
    ax3.plot(0, 0, 'ko', markersize=8, fillstyle='none')
    ax3.plot(x, y, 's', color='tab:green', markersize=12)
    # y-axis arrow: from sensor toward pivot
    ax3.annotate('', xy=(0.45*x, 0.45*y), xytext=(x, y),
                 arrowprops=dict(arrowstyle='->', color='red', lw=2))
    ax3.text(0.62*x + 0.18, 0.62*y + 0.1, '+y', color='red', fontsize=11)
    ax3.annotate('', xy=(1.28, -1.28), xytext=(1.28, -0.78),
                 arrowprops=dict(arrowstyle='->', color='gray', lw=1.5))
    ax3.text(1.34, -1.05, 'g', color='gray', fontsize=10, style='italic')
    ax3.set_title(f'{name}\n$a_y$ = {val:+.2f} m/s$^2$'.replace('+0.00', '0.00'),
                  fontsize=10)
    ax3.set_xlim(-1.5, 1.6); ax3.set_ylim(-1.5, 1.3)
    ax3.set_aspect('equal'); ax3.axis('off')
plt.tight_layout()
fig3.savefig(FIG + 'Accel_Calibration_Orientations.png', dpi=300,
             bbox_inches='tight')

# ---------------------------------------------------------------------------
# 6. FBD figure: gravity component along accelerometer y-axis
# ---------------------------------------------------------------------------
fig4, ax4 = plt.subplots(figsize=(4.2, 4.2))
th0 = np.radians(35)
x, y = np.sin(th0), -np.cos(th0)
ax4.plot([0, x], [0, y], 'k-', linewidth=3)
ax4.plot(0, 0, 'ko', markersize=9, fillstyle='none')
ax4.plot([0, 0], [0, -1.25], 'k--', linewidth=1)
ax4.plot(x, y, 's', color='tab:green', markersize=14)
ax4.annotate('', xy=(0.4*x, 0.4*y), xytext=(x, y),
             arrowprops=dict(arrowstyle='->', color='red', lw=2.5))
ax4.text(0.66*x + 0.1, 0.66*y + 0.12, '+y', color='red', fontsize=13)
ax4.annotate('', xy=(x, y - 0.55), xytext=(x, y),
             arrowprops=dict(arrowstyle='->', color='gray', lw=2.5))
ax4.text(x + 0.05, y - 0.42, 'mg', color='gray', fontsize=12, style='italic')
ax4.annotate('', xy=(x - 0.45*np.sin(th0), y + 0.45*np.cos(th0)), xytext=(x, y),
             arrowprops=dict(arrowstyle='->', color='tab:purple', lw=2,
                             linestyle='--'))
ax4.text(x - 0.75*np.sin(th0), y + 0.5*np.cos(th0) + 0.04,
         r'$-g\cos\theta$', color='tab:purple', fontsize=12)
from matplotlib.patches import Arc
ax4.add_patch(Arc((0, 0), 0.9, 0.9, theta1=270, theta2=270 + 35,
                  color='black', lw=1.2))
ax4.text(0.13, -0.55, r'$\theta$', fontsize=13)
ax4.set_xlim(-0.55, 1.45); ax4.set_ylim(-1.45, 0.35)
ax4.set_aspect('equal'); ax4.axis('off')
plt.tight_layout()
fig4.savefig(FIG + 'Accel_Gravity_FBD.png', dpi=300, bbox_inches='tight')
print('figures done')
