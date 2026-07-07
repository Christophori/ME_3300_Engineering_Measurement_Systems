# ME 3300 — Lab 02: Introduction to Hardware and Data Acquisition
## WaveForms GUI, Pendulum Calibration, and Experimental Modeling

**Author:** Dr. Christopher Bitikofer  
**Course:** ME 3300 — Mechanical Measurements  

---

## Learning Objectives

By the end of this lab, you should be able to:

- Connect a sensor to the Analog Discovery Studio (ADS) using a breadboard
- Use the WaveForms oscilloscope GUI to observe and interpret a live voltage signal
- Use the WaveForms Logger to record time-series data and export it as a CSV
- Calibrate an angular potentiometer and produce a calibration equation with confidence intervals
- Record and plot a pendulum free-swing using your calibrated sensor
- Compare experimental pendulum data to a simulated model using `scipy.integrate.solve_ivp`

---

## Check Your Understanding

- What is a voltage divider, and what determines the output voltage of a potentiometer?
- How do you set voltage scale (V/div) and time scale (s/div) on the WaveForms oscilloscope?
- What does the WaveForms Logger instrument do, and how do you export its data?
- How do you apply a calibration equation to convert raw voltage readings to physical units in Python?
- What is `scipy.integrate.solve_ivp`, and what inputs does it require?
- Why does the simple pendulum model diverge from experimental data over time?

---

## Required Equipment

- Analog Discovery Studio (ADS) with USB cable
- Pendulum apparatus with angular potentiometer (10 kΩ)
- Breadboard and jumper wire kit
- Digital multimeter (DMM)
- Protractor or smartphone level app

---

## Software Required

- WaveForms (Digilent) — installed on lab computers
- VS Code with your `me3300` conda environment active
- Python packages: `numpy`, `scipy`, `matplotlib`, `pandas`

> **WaveForms Reference:** Full documentation for the WaveForms software is available at  
> [https://digilent.com/reference/software/waveforms/waveforms-3/start](https://digilent.com/reference/software/waveforms/waveforms-3/start).  
> You do not need to read it all — specific sections are referenced throughout this lab.

---

## Lab Introduction

This lab has two major goals. The first is to get comfortable with the WaveForms software and the Analog Discovery Studio hardware — your primary instrumentation platform for the rest of the semester. The second is to complete your first full measurement workflow: connect a sensor, calibrate it, collect experimental data, and compare the result to a theoretical model.

You will do **no new Python programming in the first half of this lab**. Instead, you will use the WaveForms GUI to observe, record, and understand the signals from your sensor before automating anything. In Lab 03, you will replace the GUI steps with Python code — and at that point the code will not feel like magic, because you will have already seen exactly what it produces.

---

## Background: The Pendulum Apparatus

The lab pendulum consists of a rigid arm pinned to an angular potentiometer base, with a mass at the swinging end. The potentiometer acts as a voltage divider: as the arm rotates, the wiper position changes, and the output voltage changes proportionally to the angle.

The output voltage of the potentiometer is:

$$V_{out} = \frac{\theta}{\theta_{max}} \cdot V_{supply}$$

In practice, the relationship between angle and voltage is very nearly linear over the operating range, so a linear calibration equation of the form

$$\theta = a_1 V + a_0$$

is appropriate and will be determined experimentally.

### Simple Pendulum Model

The equation of motion for a damped simple pendulum is:

$$\ddot{\theta} + 2\zeta\omega_n\dot{\theta} + \omega_n^2 \sin(\theta) = 0$$

where the natural frequency is $\omega_n = \sqrt{g/L}$, $L$ is the pendulum length, and $\zeta$ is the damping ratio. This second-order ODE will be simulated using `scipy.integrate.solve_ivp` and overlaid on your experimental data.

---

## Part 1 — Introduction to the Analog Discovery Studio and WaveForms

### 1.1 Connect the ADS

1. Connect the ADS to the lab computer via USB. The power LED should illuminate.
2. Open **WaveForms** on the lab computer.
3. WaveForms should detect your device automatically. If prompted, select **Analog Discovery Studio**.
4. The WaveForms **Welcome** screen shows all available instruments as tiles. Take a moment to identify:
   - **Scope** (oscilloscope) — reads analog voltage vs. time
   - **Wavegen** (waveform generator / AWG) — outputs a programmable signal
   - **Logger** — records data continuously to a file
   - **Supplies** — controls the ±12 V and 3.3 V/5 V power outputs

> **Q:** Match each WaveForms instrument tile to its hardware counterpart on the ADS. Note your answers in your lab notebook. You will reference this in Lab 03 when you use `pydwf` to access these same instruments in Python.

### 1.2 Enable the Power Supply

The potentiometer requires a reference voltage. You will use the ADS 3.3 V supply.

1. Open **Supplies** in WaveForms.
2. Enable the **3.3 V** fixed supply. Leave the ±12 V supplies off for now.
3. Verify the output with your DMM: measure between the **V+** pin (3.3 V) and **GND** on the ADS header.

> **Q:** What voltage does your DMM read? Is it exactly 3.3 V? Record the value and note what this tells you about the accuracy of the supply.

---

## Part 2 — Wiring the Potentiometer Circuit

### 2.1 Circuit Description

The potentiometer has three terminals:

| Terminal | Connection |
|:--|:--|
| V+ (end terminal) | 3.3 V from ADS |
| GND (end terminal) | GND on ADS |
| Wiper (center terminal) | Analog Input CH1+ (1+) on ADS |

The ADS analog inputs are differential. Connect the wiper to **1+** and connect **GND** to **1−** (or to any GND pin on the ADS).

### 2.2 Build the Circuit

1. Place the potentiometer wires on the breadboard.
2. Use jumper wires to connect:
   - Potentiometer V+ → 3.3 V rail on breadboard → **V+** pin on ADS
   - Potentiometer GND → GND rail on breadboard → **GND** pin on ADS
   - Potentiometer wiper → **1+** (Analog In Channel 1 positive) on ADS
   - GND rail → **1−** (Analog In Channel 1 negative) on ADS

3. Double-check each connection with your DMM before proceeding.

> **Q:** Draw the schematic of this circuit in your lab notebook. Label all voltages and signal names.  
> **Q:** Slowly rotate the pendulum by hand while measuring the wiper voltage with your DMM. Does the voltage change smoothly from near 0 V to near 3.3 V? If not, ask your TA — the potentiometer may need alignment.

---

## Part 3 — Observing the Signal with the WaveForms Oscilloscope

### 3.1 Configure the Scope

1. Open **Scope** in WaveForms.
2. Ensure **Channel 1** is enabled (button should be highlighted).
3. Set the following:
   - **Voltage scale (V/div):** 0.5 V/div
   - **Time scale (s/div):** 0.2 s/div
   - **Offset:** 0 V
4. Press **Run** (the play button).

You should see the voltage trace updating in real time.

### 3.2 Explore the Signal

5. Slowly rotate the pendulum through its full range (approximately −90° to +90°).
   - Observe the voltage trace on the scope.
   - Confirm that the voltage changes smoothly and covers most of the 0–3.3 V range.

6. Give the pendulum a gentle push and let it swing freely.
   - Observe the oscillating voltage trace.
   - Use **Stop** to freeze the display and examine the waveform shape.

> **Q:** Does the signal look like a sine wave? Is the amplitude constant or does it decay? Sketch the waveform in your lab notebook and label the approximate period.  
> **Q:** On the frozen scope display, use the cursor tool (Cursor menu) to measure the approximate period of one oscillation. Record this value.

### 3.3 Measure Average Voltage at Known Angles

Hold the pendulum stationary at 0° (straight down). Use the scope's **Measurements** panel to display the **Mean** voltage.

> **Q:** What is the mean voltage at 0°? What would you expect it to be based on the circuit geometry?

---

## Part 4 — Calibration Using WaveForms Logger

### 4.1 Set Up the Logger

1. Open **Logger** in WaveForms.
2. Add a channel: click **+** and select **Scope Channel 1 (Voltage)**.
3. Set the **Sample Rate** to **20 Hz** and **Duration** to **10 seconds**.
4. Set the export format to **CSV**.

### 4.2 Collect Calibration Data

You will hold the pendulum at 10 or more known angles and record the mean voltage at each angle. Use the supplied protractor or a smartphone level app to set each angle accurately.

Collect data at a **minimum** of these angles (add more for better accuracy):

−90°, −70°, −50°, −30°, −10°, 0°, 10°, 30°, 50°, 70°, 90°

**For each angle:**

1. Set the pendulum to the target angle and hold it steady.
2. Start a new Logger recording. Name the file using the convention `Ang_p45Deg.csv` (positive) or `Ang_n45Deg.csv` (negative) — replace 45 with the actual angle.
3. After 10 seconds, stop the recording. WaveForms will prompt you to save the CSV.
4. Save the file to `ME3300/Lab_02/Data/`.
5. Record the target angle and the approximate mean voltage in your lab notebook using the table format below.

| Angle (°) | Mean Voltage (V) |
|:-:|:-:|
| −90 | |
| −70 | |
| ... | |
| 90 | |

> **Q:** Before fitting, look at your table. Is the relationship between angle and voltage linear? Does it make sense given the circuit?

### 4.3 Build the Calibration Equation in Python

Open VS Code and create `FirstName_LastName_Lab02.py` in `ME3300/Lab_02/Code/`.

**1. Load and average each calibration file**

```python
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
from scipy import stats
import glob

plt.rcParams['font.family'] = 'serif'
plt.rcParams['font.serif'] = ['Times New Roman']
plt.rcParams['font.size'] = 10

# Known angles (degrees) — update to match your actual calibration angles
angles_deg = np.array([-90, -70, -50, -30, -10, 0, 10, 30, 50, 70, 90])

# Load each file and compute mean voltage
data_dir = '../Data/'
mean_voltages = np.zeros(len(angles_deg))

for i, angle in enumerate(angles_deg):
    sign = 'n' if angle < 0 else 'p'
    filename = f'{data_dir}Ang_{sign}{abs(angle)}Deg.csv'
    df = pd.read_csv(filename, skiprows=1)        # WaveForms CSV has a 1-line header
    mean_voltages[i] = df.iloc[:, 1].mean()       # voltage is in column 2
```

> **Note:** WaveForms Logger CSVs have a one-line metadata header before the data. The `skiprows=1` argument handles this. Inspect one of your files in VS Code to confirm the column layout before running this code.

**2. Fit the calibration equation**

```python
# Fit: angle = a1 * voltage + a0
coeffs      = np.polyfit(mean_voltages, angles_deg, 1)
angles_fit  = np.polyval(coeffs, mean_voltages)

# Confidence interval
N     = len(angles_deg)
nu    = N - 2
resid = angles_deg - angles_fit
s_yx  = np.sqrt(np.sum(resid**2) / nu)
t_val = stats.t.ppf(0.95, df=nu)
CI    = t_val * s_yx

S_a1 = s_yx / np.sqrt(np.sum((mean_voltages - np.mean(mean_voltages))**2))

print(f"Calibration: θ = {coeffs[0]:.4f} × V + {coeffs[1]:.4f}")
print(f"s_yx = {s_yx:.4f} °,  S_a1 = {S_a1:.4f} °/V")

# Save calibration coefficients for use in future labs
np.savetxt('../Data/calibration_coeffs.csv',
           np.array([coeffs[0], coeffs[1]]),
           header='slope_deg_per_V, intercept_deg',
           delimiter=',')
```

**3. Plot the calibration curve**

```python
v_range = np.linspace(mean_voltages.min(), mean_voltages.max(), 200)

fig, ax = plt.subplots(figsize=(6.5, 4.0))
fig.patch.set_facecolor('white')

ax.scatter(mean_voltages, angles_deg, s=81, color='red', zorder=5, label='Calibration data')
ax.plot(v_range, np.polyval(coeffs, v_range), color='blue', linewidth=2, label='Linear fit')
ax.plot(v_range, np.polyval(coeffs, v_range) + CI, 'k--', linewidth=1, label='95% CI')
ax.plot(v_range, np.polyval(coeffs, v_range) - CI, 'k--', linewidth=1)

cal_text = (f'θ = {coeffs[0]:.4f}V + {coeffs[1]:.4f}\n'
            f'$s_{{yx}}$ = {s_yx:.4f} °\n'
            f'$S_{{a_1}}$ = {S_a1:.4f} °/V')
ax.text(0.05, 0.95, cal_text, transform=ax.transAxes, fontsize=10,
        verticalalignment='top', bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))

ax.set_xlabel('Voltage (V)')
ax.set_ylabel('Angle (degrees)')
ax.set_title("FirstName LastName's Calibration Plot — Date")
ax.legend(loc='lower right')
ax.grid(True, which='both', linestyle='--', linewidth=0.5)
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)

plt.tight_layout()
fig.savefig('../Figures/FirstName_LastName_Lab02_Calibration.pdf', dpi=600, bbox_inches='tight')
```

> Save the calibration coefficients file — you will load it again in Lab 03 rather than redoing the calibration.

---

## Part 5 — Record a Pendulum Free Swing

### 5.1 Configure Logger for Swing Recording

1. Open **Logger** in WaveForms.
2. Set **Sample Rate** to **100 Hz** and **Duration** to **20 seconds**.
3. Name your output file `FirstName_LastName_Lab02_Swing.csv`.

### 5.2 Collect the Data

1. Hold the pendulum at approximately +90° (horizontal).
2. Start the Logger recording.
3. Release the pendulum smoothly (do not push it).
4. Allow the pendulum to swing freely until it comes to rest or the recording ends.
5. Save the CSV to `ME3300/Lab_02/Data/`.

### 5.3 Load, Calibrate, and Plot the Swing Data

```python
# Load swing data
swing = pd.read_csv('../Data/FirstName_LastName_Lab02_Swing.csv', skiprows=1)
time_raw  = swing.iloc[:, 0].values   # time column (seconds)
volt_raw  = swing.iloc[:, 1].values   # voltage column

# Apply calibration
angle_deg = np.polyval(coeffs, volt_raw)
angle_rad = np.radians(angle_deg)

# Trim so t=0 is the release point
# Find the first sample where the pendulum begins to move
# (voltage starts changing from the held position)
# A simple approach: find where abs(diff) first exceeds a threshold
diff   = np.abs(np.diff(volt_raw))
idx0   = np.argmax(diff > 0.01) + 1      # first significant change
time   = time_raw[idx0:] - time_raw[idx0]
angle  = angle_deg[idx0:]

# Plot
fig2, ax2 = plt.subplots(figsize=(6.5, 4.0))
fig2.patch.set_facecolor('white')

ax2.plot(time, angle, color='red', linewidth=2, label='Experimental data')
ax2.set_xlabel('Time (s)')
ax2.set_ylabel('Angle (degrees)')
ax2.set_title("FirstName LastName's Pendulum Swing — Date")
ax2.legend()
ax2.grid(True, which='both', linestyle='--', linewidth=0.5)
ax2.spines['top'].set_visible(False)
ax2.spines['right'].set_visible(False)

plt.tight_layout()
```

> **Q:** From your plot, estimate the oscillation period $T_d$ and the damped natural frequency $\omega_d = 2\pi / T_d$. Record these values in your lab notebook.

---

## Part 6 — Overlay a Pendulum Simulation

### 6.1 Background: Solving the ODE in Python

Python's `scipy.integrate.solve_ivp` is the equivalent of MATLAB's `ode45`. It solves systems of first-order ODEs numerically. The second-order pendulum equation is rewritten as two first-order equations:

$$\frac{d\theta}{dt} = \omega \qquad \frac{d\omega}{dt} = -2\zeta\omega_n\omega - \omega_n^2\sin(\theta)$$

### 6.2 Simulate and Overlay

```python
from scipy.integrate import solve_ivp

# --- Pendulum parameters ---
# Measure the pendulum arm length with a ruler
L     = 0.35        # meters — UPDATE with your measured value
g     = 9.81        # m/s²
omega_n = np.sqrt(g / L)

# Initial guesses — adjust iteratively to match your data
zeta  = 0.05        # damping ratio (start here, tune as needed)
theta0_deg = 90.0   # initial angle in degrees

theta0 = np.radians(theta0_deg)
omega0 = 0.0        # released from rest

def pendulum_ode(t, y):
    theta, omega = y
    dtheta_dt = omega
    domega_dt = -2 * zeta * omega_n * omega - omega_n**2 * np.sin(theta)
    return [dtheta_dt, domega_dt]

# Solve over the same time range as your experimental data
t_span = (time[0], time[-1])
t_eval = np.linspace(time[0], time[-1], 2000)

sol = solve_ivp(pendulum_ode, t_span, [theta0, omega0],
                t_eval=t_eval, method='RK45', max_step=0.005)

theta_model_deg = np.degrees(sol.y[0])

# Overlay on the swing plot
ax2.plot(sol.t, theta_model_deg, color='blue', linewidth=2,
         linestyle='--', label='Pendulum model')
ax2.legend()

fig2.savefig('../Figures/FirstName_LastName_Lab02_Swing.pdf', dpi=600, bbox_inches='tight')
```

> **Q:** Does the model period match the experimental period? Adjust `L` if needed — measure the pendulum arm length carefully.  
> **Q:** Does the model amplitude decay at the same rate as your experimental data? If not, adjust `zeta`. What value of `zeta` gives the best visual match?  
> **Q:** Even after tuning, does the model perfectly match the data? What assumptions in the simple pendulum model would cause discrepancies?

---

## Part 7 — Return Lab Space to Prior Condition

1. Remove all jumper wires from the breadboard and return them to the wire kit in an organized manner.
2. Disconnect the pendulum wires.
3. Save all data files to OneDrive. Confirm access on a second device before leaving.
4. Ensure both lab partners have copies of all data files and scripts.
5. Log off the computer.

---

## Post-Lab Assignment

Submit the following to the Lab 02 Canvas page by **Monday at 10:00 PM**.

### Files to Submit

- Your Python script: `FirstName_LastName_Lab02.py`
- Calibration plot (`.pdf`) — must match formatting requirements from Lab 01
- Pendulum swing plot with model overlay (`.pdf`)

### Calibration Plot Requirements

- Raw calibration data: red circle markers, `s=81`
- Linear fit line: solid blue, 2 pt linewidth
- 95% CI lines: dashed black, 1 pt linewidth
- Annotated with calibration equation, $s_{yx}$, and $S_{a_1}$ (use the `text` command)
- Figure size: 6.5 in × 4.0 in
- All Lab 01 formatting standards apply

### Swing Plot Requirements

- Experimental data: solid red line, 2 pt linewidth
- Model: dashed blue line, 2 pt linewidth
- Annotated with measured $T_d$ and $\omega_d$ (use the `text` command)
- Figure size: 6.5 in × 4.0 in

### Post-Lab Questions

1. Report your calibration equation with units.
2. What is the norm of the residuals for your calibration fit? What does it tell you about fit quality?
3. What pendulum length `L` gave the best model agreement? How close is it to your physical measurement?
4. What damping ratio `zeta` gave the best visual match to your data?
5. List two physical reasons why the simple pendulum model diverges from your experimental data over time.
