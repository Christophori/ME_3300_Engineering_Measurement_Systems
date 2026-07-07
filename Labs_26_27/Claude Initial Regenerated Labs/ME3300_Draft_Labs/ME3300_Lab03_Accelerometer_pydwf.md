# ME 3300 — Lab 03: Accelerometer Data Acquisition with pydwf
## Multichannel DAQ, Sensor Calibration, and Normal Acceleration

**Author:** Dr. Christopher Bitikofer  
**Course:** ME 3300 — Mechanical Measurements  

---

## Learning Objectives

By the end of this lab, you should be able to:

- Open and configure the Analog Discovery Studio using `pydwf` in Python
- Acquire multichannel analog data programmatically using `pydwf`
- Calibrate a MEMS accelerometer using a gravity-based four-point calibration
- Apply calibration equations to convert raw voltage to physical units in a live acquisition script
- Compare measured normal acceleration to normal acceleration calculated from angular velocity
- Identify sources of discrepancy between two independent measurement methods

---

## Check Your Understanding

- What Python object in `pydwf` corresponds to the WaveForms **Scope** instrument? The **Wavegen**?
- What does `device.analogIn.frequencySet(fs)` control?
- Why does a higher sample rate reduce noise in a numerically computed derivative?
- What is a MEMS accelerometer, and what does it actually measure?
- Why do we use gravity as a calibration reference for the accelerometer?
- In the pendulum frame, which component of acceleration (normal or tangential) does the y-axis of the accelerometer measure?

---

## Required Equipment

- Analog Discovery Studio (ADS) with USB cable
- Pendulum apparatus with angular potentiometer **and** end-mounted MEMS accelerometer (MMA7361LC or equivalent)
- Breadboard and jumper wire kit
- Digital multimeter (DMM)
- Tape measure or ruler

---

## Software Required

- VS Code with `me3300` conda environment
- Python packages: `numpy`, `scipy`, `matplotlib`, `pandas`, `pydwf`

Install `pydwf` if you have not already:

```bash
conda activate me3300
pip install pydwf
```

> **pydwf Documentation:** [https://pydwf.readthedocs.io](https://pydwf.readthedocs.io)  
> Complete runnable starter scripts for this lab are provided on Canvas. Type the code in this manual yourself first, then compare to the starter scripts if you get stuck.

---

## Lab Introduction

In Lab 02, you used the WaveForms **GUI** to observe signals, record data, and export CSVs. Today you will replace that GUI workflow with Python code using `pydwf` — the Python interface to the WaveForms SDK.

The key insight is that every instrument panel you used in WaveForms corresponds directly to a device object in `pydwf`:

| WaveForms GUI Panel | pydwf object |
|:--|:--|
| Scope (oscilloscope) | `device.analogIn` |
| Wavegen (AWG) | `device.analogOut` |
| Logger | `device.analogIn` (buffered, continuous) |
| Static I/O | `device.digitalIO` |
| Supplies | `device.analogIO` |

When you write `device.analogIn.frequencySet(1000)`, you are doing exactly what you did in the Logger when you set the sample rate to 1000 Hz. The code is not magic — it is the same instrument, accessed programmatically.

---

## Background: Normal Acceleration

During rotation about a fixed axis, the **normal acceleration** (directed toward the pivot) of a point at radius $r$ is:

$$a_n = -\dot{\theta}^2 \, r$$

where $\dot{\theta}$ is the angular velocity in rad/s and $r$ is the distance from the pivot to the accelerometer.

In this experiment, you will measure $a_n$ directly with the accelerometer, and also calculate it independently from the derivative of the potentiometer angle signal. Comparing these two signals is a useful cross-check — they should agree, and the differences reveal information about noise, sensor alignment, and model assumptions.

---

## Part 1 — Introduction to pydwf

### 1.1 Basic Device Connection

The standard pattern for all `pydwf` programs in this course is:

```python
from pydwf import DwfLibrary, DwfState
from pydwf.utilities import openDwfDevice
import numpy as np
import time

dwf = DwfLibrary()

with openDwfDevice(dwf) as device:
    # All acquisition code goes inside this block.
    # The device is automatically closed when the block exits.
    print("Device connected:", device)
```

Run this as a standalone test. If it prints the device name, your ADS is connected and pydwf is working. If it throws an error, confirm WaveForms is not already running (it holds an exclusive lock on the device) and ask your TA.

> **Important:** Close WaveForms before running any pydwf script. The ADS can only be controlled by one application at a time.

### 1.2 Single-Channel Voltage Read

Before wiring the pendulum, verify your pydwf setup with a simple single-channel read. Connect a known signal (e.g., the ADS 3.3 V supply) to **CH1+** and run:

```python
from pydwf import DwfLibrary, DwfState
from pydwf.utilities import openDwfDevice
import numpy as np
import time

dwf = DwfLibrary()

with openDwfDevice(dwf) as device:
    ai = device.analogIn

    fs       = 1000        # sample rate in Hz
    duration = 2.0         # seconds
    n        = int(fs * duration)

    ai.channelEnableSet(0, True)   # enable CH1 (0-indexed)
    ai.channelRangeSet(0, 5.0)     # ±5 V range
    ai.frequencySet(fs)
    ai.bufferSizeSet(n)

    ai.configure(False, True)      # start single acquisition

    while True:
        status = ai.status(True)
        if status == DwfState.Done:
            break
        time.sleep(0.01)

    data = np.array(ai.statusData(0, n))
    t    = np.arange(n) / fs

    print(f"Mean voltage: {data.mean():.4f} V")
    print(f"Std deviation: {data.std(ddof=1):.4f} V")
```

> **Q:** Does the mean voltage match what you measured with your DMM? What is the standard deviation of the measured voltage? What does this tell you about the noise level of the ADS analog input?

---

## Part 2 — Wire the Pendulum Circuits

### 2.1 Potentiometer (from Lab 02)

Re-wire the potentiometer circuit from Lab 02:

| Potentiometer terminal | ADS connection |
|:--|:--|
| V+ end terminal | 3.3 V supply |
| GND end terminal | GND |
| Wiper | CH1+ (Analog In) |
| — | CH1− connected to GND |

### 2.2 Accelerometer Circuit

The MEMS accelerometer is pre-mounted at the end of the pendulum arm. Its 3-wire cable (power, ground, signal) connects to the breadboard.

| Accelerometer wire | Breadboard connection |
|:--|:--|
| Vcc (red) | 3.3 V rail (same as potentiometer supply) |
| GND (black) | GND rail |
| Y-axis signal (white/yellow) | CH2+ (Analog In channel 2) |

Connect **CH2−** to the GND rail.

> **Note:** The accelerometer has X, Y, and Z outputs. Only the **Y-axis** is used in this experiment. This axis points toward the pivot when the pendulum swings, making it the axis that senses normal acceleration. You do not need to connect the X or Z outputs.

3. Use your DMM to verify the accelerometer supply voltage (should be 3.3 V) and that the Y-axis output changes when you tilt the sensor.

> **Q:** When you hold the pendulum pointing straight down (0°), what voltage does the Y-axis output? When you hold it pointing straight up (180°)? Does this make physical sense?

---

## Part 3 — Accelerometer Calibration

### 3.1 Calibration Strategy

When the pendulum is held stationary, the only acceleration the sensor experiences is gravity. You can use four known orientations to extract the linear calibration equation that maps output voltage to acceleration in m/s².

At each orientation, the Y-axis of the accelerometer sees a known component of gravitational acceleration:

| Pendulum orientation | Y-axis acceleration |
|:--|:-:|
| Pointing right (horizontal, right) | 0 m/s² |
| Pointing up (vertical, up) | +9.81 m/s² |
| Pointing left (horizontal, left) | 0 m/s² |
| Pointing down (vertical, down) | −9.81 m/s² |

### 3.2 Acquire Calibration Data with pydwf

Write a Python script to collect 10 seconds of accelerometer data at each of the four positions. Use the single-channel acquisition pattern from Part 1, reading **CH2** (the accelerometer).

```python
# --- Accelerometer calibration acquisition ---
positions     = ['right', 'up', 'left', 'down']
known_accel   = [0.0, 9.81, 0.0, -9.81]   # m/s²
mean_voltages = []

fs       = 20      # 20 Hz is plenty for a static hold
duration = 10.0    # seconds
n        = int(fs * duration)

dwf = DwfLibrary()

with openDwfDevice(dwf) as device:
    ai = device.analogIn

    ai.channelEnableSet(1, True)   # CH2 (0-indexed as 1)
    ai.channelRangeSet(1, 5.0)
    ai.frequencySet(fs)
    ai.bufferSizeSet(n)

    for pos, accel in zip(positions, known_accel):
        input(f"\nHold pendulum {pos} (expected: {accel:.2f} m/s²). Press Enter to record...")

        ai.configure(False, True)
        while True:
            status = ai.status(True)
            if status == DwfState.Done:
                break
            time.sleep(0.05)

        data = np.array(ai.statusData(1, n))
        v_mean = data.mean()
        mean_voltages.append(v_mean)
        print(f"  Mean voltage at '{pos}': {v_mean:.4f} V")

mean_voltages = np.array(mean_voltages)

# Save calibration data
cal_data = np.column_stack([known_accel, mean_voltages])
np.savetxt('../Data/accel_calibration_data.csv', cal_data,
           header='accel_m_per_s2,voltage_V', delimiter=',')
```

### 3.3 Fit the Calibration Equation

```python
import matplotlib.pyplot as plt
from scipy import stats

plt.rcParams['font.family'] = 'serif'
plt.rcParams['font.serif'] = ['Times New Roman']
plt.rcParams['font.size'] = 10

# Linear fit: acceleration = a1 * voltage + a0
coeffs_accel = np.polyfit(mean_voltages, known_accel, 1)
accel_fit    = np.polyval(coeffs_accel, mean_voltages)

N     = len(known_accel)
nu    = N - 2
resid = np.array(known_accel) - accel_fit
s_yx  = np.sqrt(np.sum(resid**2) / nu)
t_val = stats.t.ppf(0.95, df=nu)
CI    = t_val * s_yx
S_a1  = s_yx / np.sqrt(np.sum((mean_voltages - mean_voltages.mean())**2))

print(f"\nAccelerometer calibration:")
print(f"  a = {coeffs_accel[0]:.4f} × V + {coeffs_accel[1]:.4f}")
print(f"  s_yx = {s_yx:.4f} m/s², S_a1 = {S_a1:.4f} (m/s²)/V")

# Save calibration coefficients
np.savetxt('../Data/accel_calibration_coeffs.csv',
           np.array([coeffs_accel[0], coeffs_accel[1]]),
           header='slope_(m_per_s2)_per_V, intercept_m_per_s2',
           delimiter=',')

# Plot calibration
v_range = np.linspace(mean_voltages.min() - 0.1, mean_voltages.max() + 0.1, 200)

fig, ax = plt.subplots(figsize=(6.5, 4.0))
fig.patch.set_facecolor('white')

ax.scatter(mean_voltages, known_accel, s=90, color='red', zorder=5, label='Calibration data')
ax.plot(v_range, np.polyval(coeffs_accel, v_range), color='blue', linewidth=2, label='Linear fit')
ax.plot(v_range, np.polyval(coeffs_accel, v_range) + CI, 'k--', linewidth=1, label='95% CI')
ax.plot(v_range, np.polyval(coeffs_accel, v_range) - CI, 'k--', linewidth=1)

cal_text = (f'a = {coeffs_accel[0]:.4f}V + {coeffs_accel[1]:.4f}\n'
            f'$s_{{yx}}$ = {s_yx:.4f} m/s²')
ax.text(0.05, 0.95, cal_text, transform=ax.transAxes, fontsize=10,
        verticalalignment='top', bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))

ax.set_xlabel('Accelerometer Voltage (V)')
ax.set_ylabel('Acceleration (m/s²)')
ax.set_title("FirstName LastName's Accelerometer Calibration — Date")
ax.legend()
ax.grid(True, which='both', linestyle='--', linewidth=0.5)
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)

plt.tight_layout()
fig.savefig('../Figures/FirstName_LastName_Lab03_Calibration.pdf', dpi=600, bbox_inches='tight')
```

> **Q:** Does your calibration look linear? Is there any noticeable curvature in the data? What would cause nonlinearity in an accelerometer output?

---

## Part 4 — Multichannel Acquisition

Now you will acquire both the potentiometer and accelerometer simultaneously at 1000 Hz.

### 4.1 Load Previous Calibration

Load the potentiometer calibration from Lab 02 rather than re-running it:

```python
# Load potentiometer calibration from Lab 02
pot_coeffs = np.loadtxt('../Data/calibration_coeffs.csv', delimiter=',', comments='#')
# pot_coeffs = [slope_deg_per_V, intercept_deg]

# Load accelerometer calibration from Part 3
acc_coeffs = np.loadtxt('../Data/accel_calibration_coeffs.csv', delimiter=',', comments='#')
# acc_coeffs = [slope_(m/s²)/V, intercept_m/s²]
```

> **Q:** Why is it better to load a saved calibration file rather than repeat the calibration each session? When would you need to redo a calibration?

### 4.2 Multichannel Acquisition Function

```python
def acquire_two_channels(device, fs=1000, duration=20.0):
    """
    Simultaneously acquire CH1 (potentiometer) and CH2 (accelerometer).

    Parameters
    ----------
    device   : open pydwf device object
    fs       : sample rate in Hz
    duration : acquisition duration in seconds

    Returns
    -------
    t    : time array (seconds)
    ch1  : CH1 voltage array
    ch2  : CH2 voltage array
    """
    ai = device.analogIn
    n  = int(fs * duration)

    ai.channelEnableSet(0, True)
    ai.channelEnableSet(1, True)
    ai.channelRangeSet(0, 5.0)
    ai.channelRangeSet(1, 5.0)
    ai.frequencySet(fs)
    ai.bufferSizeSet(n)

    print(f"Recording {duration:.0f} s at {fs:.0f} Hz... hold pendulum at 90°")
    input("Press Enter to start recording, then immediately release the pendulum.")

    ai.configure(False, True)

    while True:
        status = ai.status(True)
        if status == DwfState.Done:
            break
        time.sleep(0.05)

    ch1 = np.array(ai.statusData(0, n))
    ch2 = np.array(ai.statusData(1, n))
    t   = np.arange(n) / fs

    return t, ch1, ch2
```

### 4.3 Collect Swing Data

```python
dwf = DwfLibrary()

with openDwfDevice(dwf) as device:
    t_raw, v_pot, v_acc = acquire_two_channels(device, fs=1000, duration=20.0)

# Apply calibration equations
angle_deg = np.polyval(pot_coeffs, v_pot)          # degrees
angle_rad = np.radians(angle_deg)
accel_ms2 = np.polyval(acc_coeffs, v_acc)          # m/s²

# Save raw + calibrated data
output = np.column_stack([t_raw, v_pot, v_acc, angle_deg, accel_ms2])
np.savetxt('../Data/FirstName_LastName_Lab03_Swing.csv', output,
           header='time_s,v_pot_V,v_acc_V,angle_deg,accel_ms2',
           delimiter=',')
print("Data saved.")
```

---

## Part 5 — Post-Processing: Normal Acceleration Comparison

### 5.1 Trim the Data

Find the release point (where the pendulum starts moving) and set $t = 0$ there.

```python
# Find release: first large change in potentiometer voltage
diff   = np.abs(np.diff(v_pot))
idx0   = np.argmax(diff > 0.01) + 1
t      = t_raw[idx0:] - t_raw[idx0]
theta  = angle_rad[idx0:]
a_meas = accel_ms2[idx0:]
```

### 5.2 Calculate Normal Acceleration from Angular Velocity

Normal acceleration requires the angular velocity $\dot{\theta}$, which you compute by numerical differentiation of the angle signal.

```python
# Measure pendulum arm length (pivot to accelerometer)
r = 0.35   # meters — UPDATE with your measured value

# Numerical derivative: angular velocity (rad/s)
dt     = t[1] - t[0]
dtheta = np.gradient(theta, dt)    # np.gradient uses central differences

# Normal acceleration from kinematics
a_calc = -(dtheta**2) * r          # m/s²
```

> **Q:** Why does a higher sample rate reduce noise in this numerically computed derivative?

### 5.3 Remove Gravity Component from Accelerometer Signal

The accelerometer measures the **total** Y-axis acceleration, which includes a component due to gravity that changes with pendulum angle. Subtract it:

```python
# Gravity component along the Y-axis of the accelerometer
g = 9.81
a_gravity_component = -g * np.cos(theta)   # sign depends on your sensor orientation
                                            # check against your calibration data

a_meas_corrected = a_meas - a_gravity_component
```

> **Q:** Draw a free-body diagram in your lab notebook showing why the gravity component along the accelerometer Y-axis is $-g\cos\theta$. Make sure your sign convention matches your measured data.

### 5.4 Plot the Comparison

```python
fig2, ax2 = plt.subplots(figsize=(6.5, 4.0))
fig2.patch.set_facecolor('white')

# Plot the noisier signal first so the cleaner one remains visible
ax2.plot(t, a_calc,           color='blue', linewidth=1.5, alpha=0.8,
         label='Calculated from $\\dot{\\theta}^2 r$')
ax2.plot(t, a_meas_corrected, color='red',  linewidth=1.5,
         label='Measured (accelerometer)')

ax2.set_xlabel('Time (s)')
ax2.set_ylabel('Normal Acceleration (m/s²)')
ax2.set_title("FirstName LastName's Normal Acceleration — Date")
ax2.legend()
ax2.grid(True, which='both', linestyle='--', linewidth=0.5)
ax2.spines['top'].set_visible(False)
ax2.spines['right'].set_visible(False)

plt.tight_layout()
fig2.savefig('../Figures/FirstName_LastName_Lab03_NormalAccel.pdf', dpi=600, bbox_inches='tight')
```

> **Q:** Do the two acceleration signals agree? Where do they differ most?  
> **Q:** Which signal is noisier — the accelerometer or the calculated signal? Why?  
> **Q:** List at least two physical reasons the two signals might not match perfectly (beyond noise).

---

## Part 6 — Return Lab Space to Prior Condition

1. Remove all wires from the breadboard and return them to the kit.
2. Disconnect the pendulum signal cables.
3. Confirm all data files are saved to OneDrive and accessible to both partners.
4. Log off the computer.

---

## Post-Lab Assignment

Submit the following to the Lab 03 Canvas page by **Monday at 10:00 PM**.

### Files to Submit

- Python script: `FirstName_LastName_Lab03.py`
- Accelerometer calibration plot (`.pdf`)
- Normal acceleration comparison plot (`.pdf`)

### Calibration Plot Requirements

- Calibration data: red circles, `s=90`
- Linear fit: solid blue, 2 pt
- 95% CI: dashed black, 1 pt
- Annotated with calibration equation and $s_{yx}$
- Figure size: 6.5 in × 4.0 in
- All Lab 01 formatting standards apply

### Normal Acceleration Plot Requirements

- Calculated signal: blue line, 1.5 pt, `alpha=0.8`
- Accelerometer signal: red line, 1.5 pt
- Figure size: 6.5 in × 4.0 in

### Post-Lab Questions

1. What pydwf function call is equivalent to setting the oscilloscope sample rate in the WaveForms GUI?
2. Report your accelerometer calibration equation with units.
3. Why does the gravity-subtraction step matter? What would happen to your comparison plot if you skipped it?
4. At what point in the swing (angle and time) is the normal acceleration largest? Does this match your physical intuition?
5. Which method of measuring normal acceleration — the accelerometer or the kinematic calculation — do you trust more, and why?
