# ME 3300 — Labs 06 & 07: Strain Gauge Measurement
## Wheatstone Bridge, Instrumentation Amplifier, and Young's Modulus

**Author:** Dr. Christopher Bitikofer  
**Course:** ME 3300 — Mechanical Measurements  

> **This is a two-week lab.**  
> **Week 1 (Lab 06):** Parts 1–4 — circuit construction, calibration, and data collection.  
> **Week 2 (Lab 07):** Parts 5–6 — post-processing, Young's modulus, and uncertainty analysis.

---

## Learning Objectives

By the end of this lab, you should be able to:

- Explain how a metallic strain gauge converts mechanical strain to a resistance change
- Build and test a Wheatstone half-bridge circuit
- Amplify the bridge output using an AD622 instrumentation amplifier
- Use `pydwf` to acquire calibrated strain data as a function of applied load
- Perform linear regression to determine the Young's modulus of the beam material
- Apply uncertainty propagation to report Young's modulus with a confidence interval
- Compare your experimental result to published material values

---

## Check Your Understanding

- What is a Wheatstone bridge, and why is it used instead of measuring resistance directly?
- What is gauge factor, and how does it relate resistance change to strain?
- What is the formula for stress in a cantilevered beam under end loading?
- What is Young's modulus, and what are typical values for steel and aluminum?
- What is uncertainty propagation, and how does it differ from just reporting scatter in data?

---

## Required Equipment

- Cantilevered beam with two bonded strain gauges (Vishay CEA-06-240UZ-120 or equivalent)
- AD622AN instrumentation amplifier (DIP-8)
- Precision matched resistors (350 Ω × 2)
- Analog Discovery Studio (ADS)
- Breadboard, ±12 V power supply, jumper wires
- Digital multimeter (DMM)
- Calibrated weight set (50 g to 500 g)
- Vernier calipers and tape measure

---

## Background: Strain Gauges and the Wheatstone Bridge

### Strain Gauges

A metallic strain gauge consists of a thin foil grid bonded to a flexible backing. When the surface it is bonded to deforms, the foil stretches or compresses, changing its electrical resistance. The relationship between resistance change and mechanical strain is:

$$\frac{\Delta R}{R} = GF \cdot \varepsilon$$

where $GF$ is the **gauge factor** (typically 2.0–2.1 for metallic gauges), $\varepsilon$ is the surface strain (dimensionless, m/m), and $R$ is the nominal resistance (350 Ω for the gauges in this lab).

The resistance changes from strain are extremely small — on the order of milliohms for typical engineering strains. Direct resistance measurement is impractical at this scale. A **Wheatstone bridge** converts this small resistance change into a measurable voltage.

### Wheatstone Half-Bridge

The cantilevered beam in this lab has **two strain gauges** bonded to opposite faces of the beam at the same axial location. When a load is applied, one gauge goes into tension and the other into compression, producing equal but opposite resistance changes: $R_1 = R + \Delta R$ and $R_2 = R - \Delta R$.

These two gauges form the **active arms** of the bridge. Two precision matched resistors ($R_3 = R_4 = 350 \, \Omega$) complete the bridge circuit.

The bridge output voltage is:

$$V_{bridge} = V_{supply} \cdot \frac{\Delta R}{2R} = V_{supply} \cdot \frac{GF \cdot \varepsilon}{2}$$

For small strains, this is linearly proportional to strain — which is why we can perform a linear calibration.

### Beam Mechanics

For an end-loaded cantilever beam, the surface strain at the gauge location is:

$$\varepsilon = \frac{\sigma}{E} = \frac{M \cdot c}{E \cdot I}$$

where:
- $M = F \cdot a$ is the bending moment at the gauge location (N·m), $a$ is the distance from the load to the gauge
- $c = t/2$ is the distance from the neutral axis to the surface, $t$ is beam thickness (m)
- $I = bt^3/12$ is the second moment of area, $b$ is beam width, $t$ is beam thickness (m)
- $E$ is Young's modulus (Pa) — this is what you are measuring

Rearranging to solve for Young's modulus:

$$E = \frac{M \cdot c}{I \cdot \varepsilon} = \frac{12 F a c}{b t^3 \varepsilon}$$

---

## WEEK 1 (Lab 06)

## Part 1 — Measure Beam Geometry

Using calipers and a tape measure, record the following in your lab notebook (at least 3 measurements of each, averaged):

| Dimension | Symbol | Value (m) | Uncertainty |
|:--|:-:|:-:|:-:|
| Beam width | $b$ | | |
| Beam thickness | $t$ | | |
| Distance: load point to gauge | $a$ | | |
| Distance: gauge to clamp (free length) | $L$ | | |

> **Q:** Why take multiple measurements and average them rather than a single measurement? Record the standard deviation of each dimension — you will need these for uncertainty analysis in Week 2.

---

## Part 2 — Build the Wheatstone Half-Bridge Circuit

### 2.1 Identify the Strain Gauges

The beam has two gauges, one on the top face and one on the bottom face at the same location. Their lead wires are color-coded:

- **Top gauge:** red and white leads
- **Bottom gauge:** black and white leads

Measure the resistance of each gauge with your DMM (it should read approximately 350 Ω). Do not press hard on the gauge lead wires — the bonding is delicate.

### 2.2 Circuit Construction

Build the half-bridge circuit as follows:

```
                    Vsupply (3.3 V)
                         │
            ┌────────────┴────────────┐
            │                         │
          R_gauge_top              R_matched_1
         (R + ΔR)                  (350 Ω)
            │                         │
            ├───── V_out+ ────────────┤
            │                         │
          R_gauge_bot              R_matched_2
         (R − ΔR)                  (350 Ω)
            │                         │
            └────────────┬────────────┘
                        GND
```

- Bridge supply: 3.3 V from ADS (V+ pin) — do not use the ±12 V supply for the bridge
- V_out+ (junction between top gauge and R_matched_1) → **AD622 pin 3 (+IN)**
- V_out− (junction between bottom gauge and R_matched_2) → **AD622 pin 2 (−IN)**
- Amplifier supply: ±12 V from ADS (pins 7 and 4)
- AD622 REF (pin 5) → GND
- AD622 OUT (pin 6) → **CH1+** on ADS

### 2.3 Set Amplifier Gain

Choose a gain of **G = 100** for the AD622:

$$R_G = \frac{50{,}400}{G - 1} = \frac{50{,}400}{99} = 509.1 \, \Omega$$

Use the closest available resistor. Measure the actual value and compute the true gain:

```python
R_G_measured = 511.0   # ohms — UPDATE with your DMM measurement
G_amp = 1 + 50400.0 / R_G_measured
print(f"Amplifier gain: {G_amp:.3f}")
```

### 2.4 Null the Bridge

With no load applied, the bridge output should be zero (or very close to it). The amplified output will likely not be exactly zero due to small mismatches between the gauges and reference resistors.

1. Enable the 3.3 V and ±12 V supplies.
2. Open WaveForms Scope and observe CH1. Record the **zero-load output voltage** $V_0$.

You will subtract $V_0$ from all subsequent measurements as a zero offset correction. This is standard practice for bridge-based measurements.

> **Q:** Theoretically, what should the bridge output voltage be when no load is applied? Why does it not equal exactly zero in practice?

---

## Part 3 — Automated Data Acquisition

Write a Python acquisition script using `pydwf`. This script will prompt you to apply a weight at each step, then record and save the amplifier output.

```python
from pydwf import DwfLibrary, DwfState
from pydwf.utilities import openDwfDevice
import numpy as np
import pandas as pd
import time

plt_imported = False
try:
    import matplotlib.pyplot as plt
    plt_imported = True
except ImportError:
    pass

# --- Measurement parameters ---
fs       = 500     # Hz — 500 samples/s is more than enough for static loading
duration = 5.0     # seconds per weight step
n        = int(fs * duration)

# Applied masses in grams — UPDATE to match your weight set
masses_g = np.array([0, 50, 100, 150, 200, 250, 300, 350, 400, 450, 500])
g_accel  = 9.81    # m/s²
forces_N = masses_g * 1e-3 * g_accel

def acquire_single(device, fs, n):
    """Acquire n samples from CH1 at fs Hz and return mean voltage."""
    ai = device.analogIn
    ai.channelEnableSet(0, True)
    ai.channelRangeSet(0, 5.0)
    ai.frequencySet(fs)
    ai.bufferSizeSet(n)
    ai.configure(False, True)
    while True:
        if ai.status(True) == DwfState.Done:
            break
        time.sleep(0.01)
    data = np.array(ai.statusData(0, n))
    return data.mean(), data.std(ddof=1)

mean_voltages = []
std_voltages  = []

dwf = DwfLibrary()
with openDwfDevice(dwf) as device:
    ps = device.analogIO
    ps.channelNodeSet(0, 0, 1); ps.channelNodeSet(0, 1, 12.0)
    ps.channelNodeSet(1, 0, 1); ps.channelNodeSet(1, 1, -12.0)
    ps.enableSet(True)
    time.sleep(0.5)

    for mass, force in zip(masses_g, forces_N):
        input(f"\nApply {mass} g ({force:.3f} N). Hold steady, then press Enter...")
        v_mean, v_std = acquire_single(device, fs, n)
        mean_voltages.append(v_mean)
        std_voltages.append(v_std)
        print(f"  Measured: {v_mean:.5f} V  (std = {v_std:.5f} V)")

    ps.enableSet(False)

mean_voltages = np.array(mean_voltages)
std_voltages  = np.array(std_voltages)

# Apply zero offset correction
V0              = mean_voltages[0]   # zero-load reading
voltages_zeroed = mean_voltages - V0

# Save data
output = np.column_stack([masses_g, forces_N, mean_voltages, voltages_zeroed, std_voltages])
np.savetxt('../Data/FirstName_LastName_Lab06_StrainData.csv', output,
           header='mass_g,force_N,v_mean_V,v_zeroed_V,v_std_V',
           delimiter=',')
print("\nData saved.")
```

---

## Part 4 — Quick Check Plot (Week 1)

Before leaving lab in Week 1, produce a quick verification plot to confirm your data looks sensible:

```python
import matplotlib.pyplot as plt
plt.rcParams['font.family'] = 'serif'
plt.rcParams['font.serif'] = ['Times New Roman']
plt.rcParams['font.size'] = 10

fig, ax = plt.subplots(figsize=(6.5, 3.5))
fig.patch.set_facecolor('white')

ax.scatter(forces_N[1:], voltages_zeroed[1:], s=60, color='blue', zorder=5)
ax.set_xlabel('Applied Force (N)')
ax.set_ylabel('Amplified Bridge Voltage (V)')
ax.set_title('FirstName LastName — Raw Calibration Data — Date')
ax.grid(True, linestyle='--', linewidth=0.5)
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)

plt.tight_layout()
fig.savefig('../Figures/FirstName_LastName_Lab06_RawData.pdf', dpi=600, bbox_inches='tight')
plt.show()
```

> **Q:** Is the relationship between force and voltage linear? Does any point look like an outlier?  
> **Q:** If any point deviates significantly from a linear trend, what might have caused this?

---

## WEEK 2 (Lab 07)

## Part 5 — Post-Processing: Calibration and Young's Modulus

### 5.1 Convert Voltage to Strain

The chain of conversions is:

$$V_{amp} \xrightarrow{\div G_{amp}} V_{bridge} \xrightarrow{\text{calibration}} \varepsilon$$

The theoretical bridge calibration gives:

$$V_{bridge} = V_{supply} \cdot \frac{GF \cdot \varepsilon}{2}$$

$$\varepsilon = \frac{2 \, V_{bridge}}{V_{supply} \cdot GF}$$

```python
import numpy as np
import matplotlib.pyplot as plt
from scipy import stats
import pandas as pd

plt.rcParams['font.family'] = 'serif'
plt.rcParams['font.serif'] = ['Times New Roman']
plt.rcParams['font.size'] = 10

# Load data
data         = np.loadtxt('../Data/FirstName_LastName_Lab06_StrainData.csv',
                          delimiter=',', skiprows=1)
forces_N      = data[:, 1]
v_zeroed      = data[:, 3]
v_std         = data[:, 4]

# Circuit parameters
G_amp     = 101.7      # UPDATE with your measured gain
V_supply  = 3.3        # V
GF        = 2.08       # gauge factor (from datasheet — check Canvas for your gauge)

# Convert: voltage → bridge voltage → strain
v_bridge  = v_zeroed / G_amp
strain    = 2 * v_bridge / (V_supply * GF)

# Beam geometry — UPDATE with your measurements from Week 1
b = 0.0254     # beam width (m)
t = 0.00318    # beam thickness (m)
a = 0.150      # distance from load point to gauge (m)

c = t / 2
I = b * t**3 / 12

# Theoretical strain from beam mechanics
stress_theory  = forces_N * a * c / I      # Pa
strain_theory  = stress_theory / 200e9     # assuming steel E = 200 GPa (initial comparison)
```

### 5.2 Fit for Young's Modulus

The measured stress $\sigma = F \cdot a \cdot c / I$ should be linearly proportional to strain $\varepsilon = \sigma / E$. Fitting stress vs. strain gives the slope $E$:

```python
# Stress from applied loads
stress_meas = forces_N * a * c / I   # Pa (N/m²)

# Remove zero-force point for fitting
mask         = forces_N > 0
stress_fit   = stress_meas[mask]
strain_fit   = strain[mask]

# Linear fit: stress = E * strain  (force through origin for ideal behavior)
# Use polyfit with degree 1 (E is the slope, y-intercept should be ~0)
coeffs     = np.polyfit(strain_fit, stress_fit, 1)
E_measured = coeffs[0]         # Young's modulus in Pa
intercept  = coeffs[1]

# Confidence interval on the slope
strain_fit_vals = np.polyval(coeffs, strain_fit)
N     = len(strain_fit)
nu    = N - 2
resid = stress_fit - strain_fit_vals
s_yx  = np.sqrt(np.sum(resid**2) / nu)
t_val = stats.t.ppf(0.975, df=nu)    # two-sided 95%
S_E   = s_yx / np.sqrt(np.sum((strain_fit - strain_fit.mean())**2))
CI_E  = t_val * S_E

print(f"\nYoung's Modulus: E = {E_measured/1e9:.2f} ± {CI_E/1e9:.2f} GPa  (95% CI)")
print(f"For comparison: Steel ≈ 200 GPa, Aluminum ≈ 69 GPa, Brass ≈ 97 GPa")
```

### 5.3 Plot Stress vs. Strain

```python
strain_range = np.linspace(0, strain_fit.max() * 1.1, 200)

fig2, ax2 = plt.subplots(figsize=(6.5, 4.0))
fig2.patch.set_facecolor('white')

ax2.scatter(strain_fit * 1e6, stress_fit / 1e6,
            s=60, color='red', zorder=5, label='Measured data')
ax2.plot(strain_range * 1e6, np.polyval(coeffs, strain_range) / 1e6,
         color='blue', linewidth=2, label=f'Fit: E = {E_measured/1e9:.1f} GPa')

# Confidence band
CI_stress = t_val * s_yx
ax2.plot(strain_range * 1e6, (np.polyval(coeffs, strain_range) + CI_stress) / 1e6,
         'k--', linewidth=1, label='95% CI')
ax2.plot(strain_range * 1e6, (np.polyval(coeffs, strain_range) - CI_stress) / 1e6,
         'k--', linewidth=1)

E_text = (f'E = {E_measured/1e9:.2f} ± {CI_E/1e9:.2f} GPa\n'
          f'$s_{{yx}}$ = {s_yx/1e6:.3f} MPa')
ax2.text(0.05, 0.95, E_text, transform=ax2.transAxes, fontsize=10,
         verticalalignment='top', bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))

ax2.set_xlabel('Strain (με = 10⁻⁶ m/m)')
ax2.set_ylabel('Stress (MPa)')
ax2.set_title("FirstName LastName's Stress vs. Strain — Date")
ax2.legend()
ax2.grid(True, which='both', linestyle='--', linewidth=0.5)
ax2.spines['top'].set_visible(False)
ax2.spines['right'].set_visible(False)

plt.tight_layout()
fig2.savefig('../Figures/FirstName_LastName_Lab07_StressStrain.pdf', dpi=600, bbox_inches='tight')
```

---

## Part 6 — Uncertainty Analysis

### 6.1 Uncertainty Propagation for Young's Modulus

Young's modulus depends on several measured quantities: $E = f(F, a, b, t, \varepsilon_{measured})$. Each measurement has uncertainty, and we can propagate those uncertainties to find the overall uncertainty in $E$.

For the simplified expression $E = \sigma / \varepsilon = (F \cdot a \cdot c) / (I \cdot \varepsilon)$, the relative uncertainty is:

$$\frac{u_E}{E} = \sqrt{\left(\frac{u_F}{F}\right)^2 + \left(\frac{u_a}{a}\right)^2 + \left(\frac{u_t}{t}\right)^2 \cdot 9 + \left(\frac{u_b}{b}\right)^2 + \left(\frac{u_\varepsilon}{\varepsilon}\right)^2}$$

> **Note:** The factor of 9 on the thickness term comes from the fact that $t$ appears as $t^3$ in the moment of inertia and once in $c = t/2$, so the combined exponent on $t$ is 4, giving a coefficient of $(4)^2/... $ — derive this from the partial derivatives for the full expression in your lab notebook.

```python
# Measured uncertainties (standard deviations from multiple measurements)
u_F = 0.005      # N  (balance resolution)
u_a = 0.001      # m  (tape measure uncertainty)
u_b = 0.00005    # m  (caliper resolution / 2)
u_t = 0.00005    # m  (caliper resolution / 2)

# Use strain at mid-range for the uncertainty estimate
F_mid   = forces_N[len(forces_N)//2]
eps_mid = strain[len(strain)//2]

# Partial derivatives (relative sensitivities)
dE_dF   = E_measured / F_mid
dE_da   = E_measured / a
dE_db   = E_measured / b       # b appears once (in I = bt³/12)
dE_dt   = 4 * E_measured / t   # t appears as t³ in I and once in c → exponent 4
dE_deps = E_measured / eps_mid

# Combined uncertainty (RSS)
u_E_prop = np.sqrt((dE_dF * u_F)**2 +
                   (dE_da * u_a)**2 +
                   (dE_db * u_b)**2 +
                   (dE_dt * u_t)**2 +
                   (dE_deps * s_yx)**2)

print(f"\nUncertainty analysis:")
print(f"  Propagated uncertainty: u_E = ±{u_E_prop/1e9:.3f} GPa")
print(f"  Fit CI (statistical):   u_E = ±{CI_E/1e9:.3f} GPa")
print(f"\nFinal result: E = {E_measured/1e9:.2f} ± {u_E_prop/1e9:.2f} GPa  (propagated, 95%)")
```

> **Q:** Which source of uncertainty contributes most to the total? Does this match your expectation?  
> **Q:** How does the propagated uncertainty compare to the statistical confidence interval from the curve fit? What does it mean if they are very different?  
> **Q:** Your measured $E$ probably does not exactly match the published value. List three possible sources of systematic error that could explain the discrepancy.

---

## Part 7 — Return Lab Space to Prior Condition

1. Disable all ADS power supplies before disconnecting any wires.
2. Remove all wires from the breadboard carefully. Do not pull on the strain gauge lead wires.
3. Return all weights to the weight set box in order.
4. Save all data to OneDrive. Confirm both partners have access.
5. Log off the computer.

---

## Post-Lab Assignment

Submit all items to the Lab 07 Canvas page by **Monday at 10:00 PM**.

### Files to Submit

- Python script: `FirstName_LastName_Lab07.py`
- Raw voltage vs. force plot from Week 1 (`.pdf`)
- Stress vs. strain plot from Week 2 (`.pdf`)

### Stress vs. Strain Plot Requirements

- Data: red circles, `s=60`
- Fit line: solid blue, 2 pt
- 95% CI: dashed black, 1 pt
- Annotated with $E$, $\pm$ uncertainty, and $s_{yx}$
- X-axis in microstrain (με), Y-axis in MPa
- Figure size: 6.5 in × 4.0 in

### Post-Lab Questions

1. Report your measured Young's modulus with propagated uncertainty: $E = \_\_\_ \pm \_\_\_$ GPa.
2. What material do you think the beam is made from, based on your result and the published values?
3. Which measured dimension contributes most to the uncertainty in $E$? How could you reduce this contribution?
4. The gauge factor $GF$ was taken from the datasheet. How would an error of ±5% in $GF$ affect your result for $E$?
5. Why is a half-bridge (two active gauges) better than a quarter-bridge (one active gauge) for this measurement?
