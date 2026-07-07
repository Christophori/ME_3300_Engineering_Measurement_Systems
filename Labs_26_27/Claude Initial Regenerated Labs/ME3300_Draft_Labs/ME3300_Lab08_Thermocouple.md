# ME 3300 — Lab 08: Thermocouple and First-Order Dynamic Response
## Time Constant Measurement by Two Methods

**Author:** Dr. Christopher Bitikofer  
**Course:** ME 3300 — Mechanical Measurements  

---

## Learning Objectives

By the end of this lab, you should be able to:

- Explain the Seebeck effect and how a thermocouple generates a voltage
- Build a thermocouple signal conditioning circuit using the AD595AQ amplifier chip
- Use `pydwf` to continuously log temperature data over time
- Determine the thermocouple time constant using the error fraction method
- Determine the time constant using the 63.2% response method
- Compare the two methods and explain any discrepancy
- Interpret the time constant in the context of a first-order dynamic system

---

## Check Your Understanding

- What physical phenomenon causes a thermocouple to produce a voltage?
- What is "cold junction compensation," and why is it needed?
- What is a first-order system, and what differential equation describes its step response?
- What does the time constant $\tau$ represent physically for a temperature sensor?
- Why does the time constant depend on the medium (air vs. water)?
- What is the error fraction method for measuring $\tau$, and how does it differ from the 63.2% method?

---

## Required Equipment

- Analog Discovery Studio (ADS) with USB cable
- AD595AQ thermocouple amplifier chip (DIP-14)
- LM358AN op-amp (DIP-8) — for voltage follower buffer
- K-type thermocouple (bead or bare wire junction)
- Powered breadboard and ±12 V from ADS
- Breadboard, jumper wires, resistor kit
- Hot plate with beaker of water
- Liquid-in-glass reference thermometer
- Digital multimeter (DMM)
- Safety: beaker clamp/stand, heat-resistant gloves

---

## Background: First-Order Dynamic Response

Many measurement systems can be modeled as **first-order systems**. When exposed to a step change in the measured quantity (e.g., a sudden change in temperature), the output follows an exponential approach to the new steady state:

$$T(t) = T_\infty + (T_0 - T_\infty) \, e^{-t/\tau}$$

where $T_0$ is the initial temperature, $T_\infty$ is the final steady-state temperature, and $\tau$ is the **time constant** — the characteristic time for the system to respond.

The time constant has a direct physical interpretation: after one time constant, the sensor has traveled **63.2%** of the way from its initial to its final value. After $5\tau$, the sensor is within 1% of the final value and is considered fully settled.

For a thermocouple, the time constant depends on the heat capacity of the junction and the heat transfer coefficient between the junction and the medium:

$$\tau = \frac{m c_p}{h A}$$

where $m$ is the mass of the junction, $c_p$ is the specific heat, $h$ is the convective heat transfer coefficient, and $A$ is the surface area. A smaller, thinner thermocouple has a smaller time constant (responds faster).

### Two Methods for Measuring $\tau$

**Method 1 — 63.2% method:** Read the time at which the temperature has reached 63.2% of the full step change. This is direct and simple but sensitive to noise near the transition.

**Method 2 — Error fraction method:** Define the normalized error:

$$\Gamma(t) = \frac{T_\infty - T(t)}{T_\infty - T_0} = e^{-t/\tau}$$

Taking the natural log:

$$\ln(\Gamma) = -\frac{t}{\tau}$$

A plot of $\ln(\Gamma)$ vs. $t$ should be linear with slope $-1/\tau$. This method uses all data points, making it more robust to noise, and allows you to check whether the system truly behaves as first-order (a straight line confirms it).

---

## Part 1 — Circuit Setup

### 1.1 Overview

The AD595AQ combines a K-type thermocouple interface with built-in cold junction compensation. Its output is **10 mV/°C**, so at 100°C it outputs 1.000 V. This output is then buffered through a voltage follower (LM358) before being read by the ADS to prevent loading effects.

### 1.2 Build the Thermocouple Amplifier Circuit

**Enable ±12 V supplies** from the ADS before building (or do so in Python — see Lab 05).

**AD595AQ DIP-14 connections (use only the relevant pins):**

| AD595AQ Pin | Connection |
|:-:|:--|
| 4 (V−) | −12 V |
| 11 (V+) | +12 V |
| 1 (−TC) | Thermocouple wire (negative, typically red for K-type) |
| 14 (+TC) | Thermocouple wire (positive, typically yellow for K-type) |
| 9 (Vout) | → LM358 voltage follower input |
| 10 (Feedback) | Connect directly to pin 9 (Vout) for normal operation |

**Voltage follower (LM358 Op-Amp A, pins 1–3):**

| LM358 Pin | Connection |
|:-:|:--|
| 8 (V+) | +12 V |
| 4 (V−) | −12 V |
| 3 (+IN) | AD595AQ Vout (pin 9) |
| 2 (−IN) | LM358 output (pin 1) — direct feedback |
| 1 (OUT) | → CH1+ on ADS (final output to DAQ) |

> **What does the voltage follower do?** It presents a very high impedance to the AD595AQ output (so it does not load the chip) while driving the ADS analog input with a low-impedance copy of the same voltage. This is important because the ADS analog input has finite impedance that could otherwise affect the AD595AQ reading.

### 1.3 Verify the Circuit

1. At room temperature ($\approx 20°C$), the AD595AQ output should be approximately $20°C \times 10 \text{ mV/°C} = 0.200 \text{ V}$.
2. Measure the voltage follower output with your DMM. It should match the AD595AQ output closely.
3. Hold the thermocouple bead between your fingers for 30 seconds. The voltage should rise noticeably. This confirms the circuit is working.

> **Q:** At your measured room temperature, what voltage did you measure at the circuit output? Does it match the expected value from 10 mV/°C? Record the room temperature from the reference thermometer.

---

## Part 2 — Continuous Temperature Logging with pydwf

Write an acquisition script that reads the thermocouple output continuously and logs time + voltage to a CSV file. You will use this for both experiments in this lab.

```python
from pydwf import DwfLibrary, DwfState
from pydwf.utilities import openDwfDevice
import numpy as np
import pandas as pd
import time

def voltage_to_celsius(voltage_V):
    """Convert AD595AQ output voltage to temperature in Celsius."""
    return voltage_V / 0.010    # 10 mV/°C

def log_temperature(device, fs=10, duration=120.0, filename='temp_log.csv'):
    """
    Continuously acquire thermocouple data and save to CSV.

    Parameters
    ----------
    device   : open pydwf device
    fs       : sample rate in Hz (10 Hz is plenty for thermocouple response)
    duration : total logging time in seconds
    filename : output CSV path
    """
    ai = device.analogIn
    n  = int(fs * duration)

    ai.channelEnableSet(0, True)
    ai.channelRangeSet(0, 5.0)
    ai.frequencySet(fs)
    ai.bufferSizeSet(n)

    print(f"Logging for {duration:.0f} seconds at {fs} Hz...")
    print("Perform your step change when ready.")

    ai.configure(False, True)

    while True:
        if ai.status(True) == DwfState.Done:
            break
        time.sleep(1.0)
        # Simple progress indicator
        print(".", end="", flush=True)

    print("\nAcquisition complete.")
    voltage = np.array(ai.statusData(0, n))
    t       = np.arange(n) / fs
    temp_C  = voltage_to_celsius(voltage)

    output = np.column_stack([t, voltage, temp_C])
    np.savetxt(filename, output,
               header='time_s,voltage_V,temp_C',
               delimiter=',')
    print(f"Data saved to {filename}")
    return t, voltage, temp_C
```

---

## Part 3 — Experiment: Step Response in Water

### 3.1 Safety Notes

- The hot plate and beaker contain hot water. Use the clamp stand and heat-resistant gloves.
- Keep electrical connections away from the water.
- Do not immerse the thermocouple wires — only the bead tip should enter the water.

### 3.2 Setup

1. Fill a beaker with approximately 400 mL of water.
2. Heat it to **70–80°C** using the hot plate. Monitor temperature with the liquid-in-glass thermometer.
3. While the water heats, prepare a second container of **room-temperature water** (~20°C).
4. Record both temperatures with the reference thermometer:
   - $T_0$ = room temperature water (°C)
   - $T_\infty$ = hot water temperature (°C)

### 3.3 Collect Data

**Experiment A — Cold to Hot (step up):**

1. Start the logging script:
   ```python
   dwf = DwfLibrary()
   with openDwfDevice(dwf) as device:
       ps = device.analogIO
       ps.channelNodeSet(0, 0, 1); ps.channelNodeSet(0, 1, 12.0)
       ps.channelNodeSet(1, 0, 1); ps.channelNodeSet(1, 1, -12.0)
       ps.enableSet(True)

       t, v, temp = log_temperature(
           device, fs=10, duration=60.0,
           filename='../Data/FirstName_LastName_Lab08_ColdToHot.csv')

       ps.enableSet(False)
   ```
2. Hold the thermocouple in the **room-temperature water** for 20 seconds to establish $T_0$.
3. At $t \approx 20$ s, quickly move the thermocouple bead into the **hot water**.
4. Hold it steady (do not stir) until the temperature stabilizes (~30–40 more seconds).

**Experiment B — Hot to Cold (step down):** Repeat the experiment in reverse: start in hot water, then transfer to cold water. Save as `FirstName_LastName_Lab08_HotToCold.csv`.

---

## Part 4 — Analysis: Determine the Time Constant

Load and analyze your data. The following code processes **Experiment A** — apply the same analysis to Experiment B.

### 4.1 Load and Trim Data

```python
import numpy as np
import matplotlib.pyplot as plt
from scipy import stats, optimize

plt.rcParams['font.family'] = 'serif'
plt.rcParams['font.serif'] = ['Times New Roman']
plt.rcParams['font.size'] = 10

data  = np.loadtxt('../Data/FirstName_LastName_Lab08_ColdToHot.csv',
                   delimiter=',', skiprows=1)
t_all  = data[:, 0]
T_all  = data[:, 2]

# Identify the step: find where temperature starts rising sharply
# A simple approach: find the first point where T rises more than 0.5°C in 0.5 s
dT    = np.diff(T_all)
idx_step = np.argmax(dT > 0.5) + 1   # first large jump

# Set t=0 at the moment of the step
t  = t_all[idx_step:] - t_all[idx_step]
T  = T_all[idx_step:]

# Define T_0 and T_inf from the data
T_0   = T_all[:idx_step].mean()           # mean before the step
T_inf = T_all[-20:].mean()                # mean at end (approximately settled)

print(f"T_0   = {T_0:.2f} °C")
print(f"T_inf = {T_inf:.2f} °C")
print(f"Step size: ΔT = {T_inf - T_0:.2f} °C")
```

### 4.2 Method 1 — 63.2% Method

```python
T_63 = T_0 + 0.632 * (T_inf - T_0)   # temperature at 63.2% of step

# Find the time when T first crosses T_63
idx_63 = np.argmax(T >= T_63)
tau_63 = t[idx_63]

print(f"\nMethod 1 (63.2%): τ = {tau_63:.3f} s")
```

### 4.3 Method 2 — Error Fraction (Log-Linear Fit)

```python
# Normalized error fraction
Gamma = (T_inf - T) / (T_inf - T_0)

# Only use the portion where Gamma is between 0.02 and 0.98 to avoid log(0) and noise
valid = (Gamma > 0.02) & (Gamma < 0.98)
t_valid     = t[valid]
ln_Gamma    = np.log(Gamma[valid])

# Linear fit: ln(Γ) = −t/τ  → slope = −1/τ
coeffs   = np.polyfit(t_valid, ln_Gamma, 1)
tau_err  = -1.0 / coeffs[0]
r_sq     = np.corrcoef(t_valid, ln_Gamma)[0, 1]**2

print(f"Method 2 (error fraction): τ = {tau_err:.3f} s")
print(f"  R² of log-linear fit: {r_sq:.4f}")
```

### 4.4 Plot the Results

```python
fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(6.5, 7.0), constrained_layout=True)
fig.patch.set_facecolor('white')

# Top panel: temperature vs time with τ annotations
t_model = np.linspace(0, t[-1], 500)
T_model = T_inf + (T_0 - T_inf) * np.exp(-t_model / tau_err)

ax1.plot(t, T, color='red', linewidth=1.5, label='Measured')
ax1.plot(t_model, T_model, color='blue', linewidth=2, linestyle='--',
         label=f'Model (τ = {tau_err:.2f} s)')
ax1.axhline(T_63, color='green', linewidth=1.0, linestyle=':',
            label=f'63.2% level = {T_63:.1f} °C')
ax1.axvline(tau_63, color='purple', linewidth=1.0, linestyle=':',
            label=f'τ (63.2%) = {tau_63:.2f} s')
ax1.axhline(T_inf, color='gray', linewidth=0.8, linestyle='--', label=f'T∞ = {T_inf:.1f} °C')

ax1.set_xlabel('Time (s)')
ax1.set_ylabel('Temperature (°C)')
ax1.set_title('FirstName LastName — Thermocouple Step Response — Date')
ax1.legend(fontsize=9)
ax1.grid(True, linestyle='--', linewidth=0.5)
ax1.spines['top'].set_visible(False)
ax1.spines['right'].set_visible(False)

# Bottom panel: log-linear error fraction
t_fit_line = np.linspace(t_valid[0], t_valid[-1], 200)
ax2.scatter(t_valid, ln_Gamma, s=10, color='red', alpha=0.5, label='Data', zorder=3)
ax2.plot(t_fit_line, np.polyval(coeffs, t_fit_line), color='blue', linewidth=2,
         label=f'Linear fit (τ = {tau_err:.2f} s, R² = {r_sq:.4f})')

fit_text = f'slope = {coeffs[0]:.4f} s⁻¹\nτ = {tau_err:.3f} s'
ax2.text(0.65, 0.95, fit_text, transform=ax2.transAxes, fontsize=10,
         verticalalignment='top', bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))

ax2.set_xlabel('Time (s)')
ax2.set_ylabel('ln(Γ) = ln[(T∞ − T) / (T∞ − T₀)]')
ax2.set_title('Error Fraction Method (log-linear)')
ax2.legend(fontsize=9)
ax2.grid(True, linestyle='--', linewidth=0.5)
ax2.spines['top'].set_visible(False)
ax2.spines['right'].set_visible(False)

fig.savefig('../Figures/FirstName_LastName_Lab08_TimeConstant.pdf', dpi=600, bbox_inches='tight')
```

> **Q:** How well does the log-linear plot follow a straight line? What does deviation from linearity indicate about the system?  
> **Q:** Do the two methods give the same time constant? If not, which do you trust more and why?  
> **Q:** How does the time constant in hot water compare to what you would expect in still air? What physical property drives this difference?

---

## Part 5 — Return Lab Space to Prior Condition

1. Turn off the hot plate. Allow the water to cool before disposal.
2. Disable the ADS power supplies before removing wires.
3. Remove all wires and components carefully (the AD595AQ is fragile — do not bend the pins).
4. Save data to OneDrive. Confirm both partners have access.
5. Log off the computer.

---

## Post-Lab Assignment

Submit the following to the Lab 08 Canvas page by **Monday at 10:00 PM**.

### Files to Submit

- Python script: `FirstName_LastName_Lab08.py`
- Time constant figure for Experiment A — two-panel plot (`.pdf`)
- Time constant figure for Experiment B — two-panel plot (`.pdf`)

### Plot Requirements

Both figures: two-panel layout (temperature vs. time + log-linear error fraction). Figure size: 6.5 in × 7.0 in. All Lab 01 formatting standards apply. The top panel must show the model overlay, 63.2% level, and $\tau$ annotation.

### Post-Lab Questions

1. Report $\tau$ for both methods on both experiments (cold-to-hot and hot-to-cold). Do the four values agree?
2. For the error fraction method: report the $R^2$ of the log-linear fit. Does the sensor behave as a true first-order system?
3. If you were designing a control system that reads from this thermocouple, how many seconds would you need to wait after a temperature change before trusting the reading to be within 1% of the true value?
4. How would the time constant change if you used a much larger thermocouple bead? Use the formula $\tau = mc_p/(hA)$ to explain your answer qualitatively.
5. In Lab 04, you connected aliasing to the choice of sample rate. Apply the same thinking here: given your measured $\tau$, what is the minimum sample rate you would need to accurately capture the thermocouple transient response? (Hint: what frequency content does an exponential with time constant $\tau$ contain?)
