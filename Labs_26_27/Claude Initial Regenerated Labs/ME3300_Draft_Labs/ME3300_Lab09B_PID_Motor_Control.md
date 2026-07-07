# ME 3300 — Lab 09B: DC Motor Control with PID
## Plant Characterization, Feedback Control, and Step Response Tuning

**Author:** Dr. Christopher Bitikofer  
**Course:** ME 3300 — Mechanical Measurements  

> **This is Part B of a two-week lab.**  
> **Lab 09A (last week):** Active low-pass filter and automated Bode plot.  
> **Lab 09B (this document):** DC motor characterization and PID controller implementation.

---

## Learning Objectives

By the end of this lab, you should be able to:

- Characterize a DC motor's open-loop step response using Python and pydwf
- Identify the motor's first-order time constant from step response data
- Implement a proportional (P), proportional-integral (PI), and full PID controller in Python
- Use the ADS PWM output to drive a motor through an H-bridge
- Read a motor feedback signal (encoder or back-EMF) with the ADS analog input
- Tune PID gains to achieve a well-damped step response
- Interpret the effect of each gain term (P, I, D) on system response

---

## Check Your Understanding

- What is the difference between open-loop and closed-loop (feedback) control?
- What does each term of a PID controller do to the error signal?
- Why does a proportional-only controller typically exhibit steady-state error?
- What is integral windup, and how do you prevent it?
- What is a PWM signal, and how does duty cycle relate to average motor voltage?
- What physical property of a motor determines its first-order time constant?

---

## Required Equipment

- Analog Discovery Studio (ADS) with USB cable
- Small DC motor (e.g., 6 V, ~0.5 W gearmotor or similar)
- H-bridge motor driver module (e.g., L298N, DRV8833, or TB6612FNG breakout)
- Small flywheel or fan blade attached to motor shaft (if available)
- Motor feedback: one of the following:
  - **Option A** — Encoder module (quadrature or Hall effect) if available
  - **Option B** — Back-EMF sensing (see Part 2.3)
- 100 Ω, 1 kΩ resistors
- Breadboard, jumper wires
- 5 V external bench supply (for motor) OR ADS 5 V fixed supply for small motors

---

## Background: PID Control

A **PID controller** computes a control output $u(t)$ based on the error between a desired setpoint $r(t)$ and the measured process variable $y(t)$:

$$e(t) = r(t) - y(t)$$

$$u(t) = K_p \, e(t) + K_i \int_0^t e(\tau) \, d\tau + K_d \, \frac{de}{dt}$$

The three terms have distinct roles:

| Term | Gain | Effect |
|:--|:-:|:--|
| **Proportional** | $K_p$ | Drives output in proportion to current error. Reduces error but cannot eliminate it alone. |
| **Integral** | $K_i$ | Accumulates error over time. Eliminates steady-state error but can cause oscillation and windup. |
| **Derivative** | $K_d$ | Responds to the rate of change of error. Damping effect; reduces overshoot and oscillation. |

In discrete time (as implemented in Python), the PID equations become:

$$e_k = r_k - y_k$$

$$u_k = K_p \, e_k + K_i \sum_{j=0}^{k} e_j \Delta t + K_d \frac{e_k - e_{k-1}}{\Delta t}$$

where $\Delta t$ is the control loop time step.

### Anti-Windup

When the control output saturates (e.g., PWM duty cycle is clamped to 0–100%), the integral term keeps accumulating even though the output cannot change. This is called **integral windup** and causes large overshoots after saturation ends.

A simple anti-windup strategy: stop accumulating the integral when the output is saturated.

```python
# Anti-windup: only integrate if not saturated
if u_min < u_prev < u_max:
    integral += error * dt
```

---

## Part 1 — Motor and H-Bridge Circuit

### 1.1 H-Bridge Overview

A DC motor requires bidirectional current. The ADS digital outputs provide only 3.3 V at low current — not nearly enough to drive a motor directly. An **H-bridge** driver IC solves both problems: it accepts a low-power logic signal from the ADS and drives the motor with power from a separate supply.

The H-bridge has two key inputs:
- **PWM input:** controls speed (duty cycle = fraction of time motor is on)
- **Direction input:** controls direction (HIGH = forward, LOW = reverse)

For this lab, you will control speed only (direction can be fixed).

### 1.2 Wiring the H-Bridge

The exact wiring depends on your H-bridge module. Refer to the module datasheet on Canvas.

**General connections for most breakout modules:**

| H-bridge pin | Connection |
|:--|:--|
| VM / VMotor | 5 V motor supply |
| VCC / VLOGIC | 3.3 V from ADS |
| GND | GND (common with ADS) |
| AIN1 / IN1 | ADS DIO 0 (direction control — tie HIGH for forward) |
| PWMA / ENA | ADS DIO 1 (PWM speed control) |
| AOUT1 / OUT1 | Motor terminal A |
| AOUT2 / OUT2 | Motor terminal B |

> **Important:** The motor supply and the ADS logic supply share a **common ground**. Connect the GND of your motor supply to the GND rail on the breadboard.

### 1.3 Generate PWM from the ADS

The ADS digital output can be toggled rapidly in software to produce a PWM signal. For motor control, you will use the AWG (analog output) configured as a square wave, which is more precise than software toggling.

```python
from pydwf import DwfLibrary, DwfAnalogOutNode, DwfAnalogOutFunction
from pydwf.utilities import openDwfDevice
import time

def set_motor_pwm(device, duty_cycle_pct, pwm_freq=1000):
    """
    Set motor speed via PWM on W1 (AWG channel 0).

    duty_cycle_pct : 0 to 100 (percent)
    pwm_freq       : PWM frequency in Hz (1000 Hz is typical for DC motors)
    """
    duty = np.clip(duty_cycle_pct, 0, 100) / 100.0  # convert to 0.0–1.0
    amplitude = 1.65 * duty         # ADS outputs ±amplitude; for 3.3V logic:
    offset    = amplitude           # offset so signal stays 0 → 3.3V

    ao = device.analogOut
    ao.nodeEnableSet(0, DwfAnalogOutNode.Carrier, True)
    ao.nodeFunctionSet(0, DwfAnalogOutNode.Carrier, DwfAnalogOutFunction.Square)
    ao.nodeFrequencySet(0, DwfAnalogOutNode.Carrier, pwm_freq)
    ao.nodeAmplitudeSet(0, DwfAnalogOutNode.Carrier, amplitude)
    ao.nodeOffsetSet(0, DwfAnalogOutNode.Carrier, offset)
    ao.configure(0, True)
```

> **Q:** Connect the motor and run it at 25%, 50%, and 75% duty cycle. Observe the speed qualitatively. Does higher duty cycle produce higher speed? Note your observations.

### 1.4 Set Direction Pin

```python
from pydwf import DwfLibrary
from pydwf.utilities import openDwfDevice

dwf = DwfLibrary()
with openDwfDevice(dwf) as device:
    device.digitalIO.outputEnableSet(0x01)  # DIO 0 as output
    device.digitalIO.outputSet(0x01)        # DIO 0 HIGH = forward
```

---

## Part 2 — Motor Feedback Signal

Choose one of the two feedback options below depending on available hardware.

### Option A — Encoder Feedback (Preferred)

If your motor has an attached encoder module, connect its output to **CH1+** on the ADS. Encoder outputs are typically digital (3.3 V or 5 V pulses). Connect through a voltage divider if the encoder runs at 5 V:

```
Encoder OUT ── 1 kΩ ──┬── CH1+ (ADS)
                      │
                     1 kΩ
                      │
                     GND
```

The voltage divider brings 5 V signals down to 2.5 V — within the ADS ±5 V input range.

For a simple encoder, count pulses per unit time to get speed:

```python
# Encoder pulse counting (simplified — assumes square wave output)
# Count zero-crossings in a time window to estimate RPM
def estimate_rpm(encoder_signal, t, pulses_per_rev):
    """Estimate RPM from encoder signal array."""
    # Count rising edges
    crossings = np.where((encoder_signal[:-1] < 1.5) & (encoder_signal[1:] >= 1.5))[0]
    if len(crossings) < 2:
        return 0.0
    duration = t[crossings[-1]] - t[crossings[0]]
    n_pulses  = len(crossings) - 1
    rpm = (n_pulses / pulses_per_rev) / duration * 60.0
    return rpm
```

### Option B — Back-EMF Sensing

A DC motor also acts as a generator: when spinning, it produces a **back-EMF** proportional to speed. By briefly turning off the PWM and measuring the terminal voltage, you can estimate speed without an encoder.

Connect the motor terminal (through a 100 Ω resistor for protection) to **CH1+** on the ADS.

> **Note:** Back-EMF sensing is less accurate than an encoder and requires brief interruptions in the control output. Use Option A if an encoder is available. For this lab, back-EMF is acceptable for demonstrating the control concepts.

---

## Part 3 — Open-Loop Step Response (Plant Characterization)

Before implementing feedback control, characterize the motor's open-loop behavior. This tells you how fast the motor responds to a step change in PWM duty cycle.

```python
import numpy as np
import matplotlib.pyplot as plt

plt.rcParams['font.family'] = 'serif'
plt.rcParams['font.serif'] = ['Times New Roman']
plt.rcParams['font.size'] = 10

FS       = 1000    # Hz
DURATION = 5.0     # seconds
N        = int(FS * DURATION)
STEP_DC  = 60.0    # duty cycle percent for step test

motor_response = []
t_log          = []

dwf = DwfLibrary()

with openDwfDevice(dwf) as device:
    # Set direction pin HIGH
    device.digitalIO.outputEnableSet(0x01)
    device.digitalIO.outputSet(0x01)

    ai = device.analogIn
    ai.channelEnableSet(0, True)
    ai.channelRangeSet(0, 5.0)
    ai.frequencySet(FS)
    ai.bufferSizeSet(N)

    # Step: motor off → step to STEP_DC%
    set_motor_pwm(device, 0.0)
    time.sleep(1.0)    # ensure motor is stopped

    print(f"Applying {STEP_DC}% duty cycle step...")
    set_motor_pwm(device, STEP_DC)

    ai.configure(False, True)
    while True:
        if ai.status(True) == DwfState.Done:
            break
        time.sleep(0.01)

    feedback = np.array(ai.statusData(0, N))
    t_step   = np.arange(N) / FS

    # Stop motor
    set_motor_pwm(device, 0.0)
    device.analogOut.configure(0, False)

# Save step response
np.savetxt('../Data/FirstName_LastName_Lab09B_StepResponse.csv',
           np.column_stack([t_step, feedback]),
           header='time_s,feedback_V', delimiter=',')
```

### 3.1 Fit a First-Order Model to the Step Response

The motor speed response to a step input is approximately first-order:

$$y(t) = y_\infty \left(1 - e^{-t/\tau_m}\right)$$

```python
from scipy.optimize import curve_fit

# Load and trim data
data     = np.loadtxt('../Data/FirstName_LastName_Lab09B_StepResponse.csv',
                      delimiter=',', skiprows=1)
t_raw    = data[:, 0]
y_raw    = data[:, 1]

# Find step onset — first large increase
dy     = np.diff(y_raw)
idx0   = np.argmax(dy > 0.05) + 1
t      = t_raw[idx0:] - t_raw[idx0]
y      = y_raw[idx0:]
y_inf  = y[-int(len(y)*0.1):].mean()   # final value

def first_order_step(t, tau):
    return y_inf * (1 - np.exp(-t / tau))

popt, pcov = curve_fit(first_order_step, t, y, p0=[0.5], bounds=(0.01, 5.0))
tau_motor  = popt[0]
print(f"Motor time constant: τ_m = {tau_motor:.3f} s")

# Plot open-loop step response
t_model = np.linspace(0, t[-1], 500)
fig, ax = plt.subplots(figsize=(6.5, 3.5))
fig.patch.set_facecolor('white')

ax.plot(t, y, color='red', linewidth=1.5, label='Measured')
ax.plot(t_model, first_order_step(t_model, tau_motor), 'b--', linewidth=2,
        label=f'1st-order fit (τ = {tau_motor:.3f} s)')
ax.axhline(y_inf, color='gray', linewidth=0.8, linestyle='--',
           label=f'Steady state = {y_inf:.3f} V')

ax.set_xlabel('Time (s)')
ax.set_ylabel('Feedback Signal (V)')
ax.set_title(f'FirstName LastName — Open-Loop Step Response ({STEP_DC}% duty) — Date')
ax.legend()
ax.grid(True, linestyle='--', linewidth=0.5)
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)

plt.tight_layout()
fig.savefig('../Figures/FirstName_LastName_Lab09B_OpenLoop.pdf', dpi=600, bbox_inches='tight')
```

> **Q:** What is the motor's time constant? What does it physically represent?  
> **Q:** How many seconds does the motor take to reach 95% of its final speed?

---

## Part 4 — PID Controller Implementation

### 4.1 Control Loop Structure

```python
class PIDController:
    """
    Discrete-time PID controller with anti-windup.
    """
    def __init__(self, Kp, Ki, Kd, dt, u_min=0.0, u_max=100.0):
        self.Kp, self.Ki, self.Kd = Kp, Ki, Kd
        self.dt     = dt
        self.u_min  = u_min
        self.u_max  = u_max
        self.integral  = 0.0
        self.prev_error = 0.0

    def update(self, setpoint, measurement):
        error      = setpoint - measurement
        derivative = (error - self.prev_error) / self.dt

        # Anti-windup: only integrate when not saturated
        u_unsat = (self.Kp * error +
                   self.Ki * self.integral +
                   self.Kd * derivative)
        if self.u_min < u_unsat < self.u_max:
            self.integral += error * self.dt

        u = np.clip(self.Kp * error +
                    self.Ki * self.integral +
                    self.Kd * derivative,
                    self.u_min, self.u_max)

        self.prev_error = error
        return u, error
```

### 4.2 Run the Closed-Loop Control

Start with **P-only** control and progressively add I and D terms.

```python
# --- Tuning gains (start here, adjust based on response) ---
# Suggested starting point using τ_motor from open-loop characterization:
# Kp_start ≈ 1 / (K_motor * τ_motor)  where K_motor ≈ y_inf / (STEP_DC/100)
K_motor = y_inf / (STEP_DC / 100.0)   # rough plant gain estimate

Kp = 1.0 / (K_motor * tau_motor)   # initial proportional gain
Ki = 0.0                             # start with P-only, add I later
Kd = 0.0                             # add D after P+I is tuned

SETPOINT  = 0.60 * y_inf   # target feedback voltage (60% of max measured speed)
LOOP_DT   = 0.02           # 50 Hz control rate
LOOP_TIME = 10.0           # seconds
N_STEPS   = int(LOOP_TIME / LOOP_DT)

pid = PIDController(Kp, Ki, Kd, dt=LOOP_DT)

t_log       = []
y_log       = []
u_log       = []
error_log   = []

dwf = DwfLibrary()

with openDwfDevice(dwf) as device:
    device.digitalIO.outputEnableSet(0x01)
    device.digitalIO.outputSet(0x01)

    ai = device.analogIn
    ai.channelEnableSet(0, True)
    ai.channelRangeSet(0, 5.0)

    print(f"PID control: Kp={Kp:.3f}, Ki={Ki:.3f}, Kd={Kd:.3f}")
    print(f"Setpoint = {SETPOINT:.3f} V")

    t_start = time.time()

    for step in range(N_STEPS):
        t_now = step * LOOP_DT

        # Read current feedback (short burst acquisition)
        ai.frequencySet(1000)
        ai.bufferSizeSet(50)   # 50 ms of data for one reading
        ai.configure(False, True)
        while ai.status(True) != DwfState.Done:
            pass
        y_now = np.array(ai.statusData(0, 50)).mean()

        # PID update
        u, err = pid.update(SETPOINT, y_now)

        # Apply control output
        set_motor_pwm(device, u)

        # Log
        t_log.append(t_now)
        y_log.append(y_now)
        u_log.append(u)
        error_log.append(err)

        # Pace the loop
        elapsed = time.time() - t_start - t_now
        if elapsed < LOOP_DT:
            time.sleep(LOOP_DT - elapsed)

    set_motor_pwm(device, 0.0)
    device.analogOut.configure(0, False)

t_log     = np.array(t_log)
y_log     = np.array(y_log)
u_log     = np.array(u_log)
error_log = np.array(error_log)

# Save
np.savetxt('../Data/FirstName_LastName_Lab09B_PID.csv',
           np.column_stack([t_log, y_log, u_log, error_log]),
           header='time_s,feedback_V,duty_pct,error_V',
           delimiter=',')
```

### 4.3 Plot the Closed-Loop Response

```python
fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(6.5, 6.0), sharex=True)
fig.patch.set_facecolor('white')

# Top: process variable vs setpoint
ax1.plot(t_log, y_log, color='red', linewidth=1.5, label='Measured (feedback)')
ax1.axhline(SETPOINT, color='blue', linewidth=1.5, linestyle='--',
            label=f'Setpoint = {SETPOINT:.3f} V')
gains_text = f'Kp={Kp:.3f}, Ki={Ki:.3f}, Kd={Kd:.3f}'
ax1.text(0.02, 0.05, gains_text, transform=ax1.transAxes, fontsize=9,
         bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))
ax1.set_ylabel('Feedback Signal (V)')
ax1.set_title('FirstName LastName — PID Closed-Loop Response — Date')
ax1.legend()
ax1.grid(True, linestyle='--', linewidth=0.5)
ax1.spines['top'].set_visible(False)
ax1.spines['right'].set_visible(False)

# Bottom: control output
ax2.plot(t_log, u_log, color='green', linewidth=1.5)
ax2.set_xlabel('Time (s)')
ax2.set_ylabel('Duty Cycle (%)')
ax2.set_ylim(-5, 105)
ax2.grid(True, linestyle='--', linewidth=0.5)
ax2.spines['top'].set_visible(False)
ax2.spines['right'].set_visible(False)

plt.tight_layout()
fig.savefig('../Figures/FirstName_LastName_Lab09B_PID.pdf', dpi=600, bbox_inches='tight')
```

---

## Part 5 — Tuning Progression

Work through the following sequence, saving a plot at each stage. The goal is to understand what each gain term does to the response.

**Step 1 — P-only:** Set $K_i = 0$, $K_d = 0$. Increase $K_p$ until the response is reasonably fast but without large oscillation.  
> **Q:** Does P-only control eliminate steady-state error? Measure the steady-state error from your plot.

**Step 2 — P + I:** Add a small $K_i$ (start at $K_i \approx K_p / \tau_m$). Observe whether the steady-state error disappears. Increase $K_i$ carefully — too large will cause oscillation.  
> **Q:** Does integral action eliminate steady-state error? What happens when $K_i$ is too large?

**Step 3 — P + I + D:** Add a small $K_d$ (start at $K_d \approx K_p \cdot \tau_m / 4$). Observe whether overshoot decreases.  
> **Q:** What effect does $K_d$ have on the response? Does it help or hurt in your system?

**Step 4 — Best response:** Find the combination of gains that gives the fastest response with less than 10% overshoot and no steady-state error. Record your final gains.

---

## Part 6 — Return Lab Space to Prior Condition

1. Stop the motor and disable all ADS outputs before disconnecting.
2. Carefully disconnect the H-bridge circuit.
3. Return all components to their labeled containers.
4. Save all scripts, data, and figures to OneDrive.
5. Confirm both partners have copies of all files.
6. Log off the computer. This is the last regular lab of the semester — leave the station in excellent condition.

---

## Post-Lab Assignment

Submit the following to the Lab 09B Canvas page by **Monday at 10:00 PM**.

### Files to Submit

- Python script: `FirstName_LastName_Lab09B.py`
- Open-loop step response plot (`.pdf`)
- At least 3 closed-loop response plots showing P-only, P+I, and best P+I+D (`.pdf`)

### Plot Requirements

All closed-loop plots: two-panel layout (feedback vs. setpoint + duty cycle vs. time). Gains annotated on each plot. Figure size: 6.5 in × 6.0 in.

### Post-Lab Questions

1. What is the motor's open-loop time constant $\tau_m$? What does it represent physically?
2. Report your final PID gains: $K_p$, $K_i$, $K_d$. Briefly describe your tuning process.
3. What was the steady-state error with P-only control? Did adding integral action eliminate it?
4. Did adding derivative action improve the response in your system? What might make $K_d$ less effective in a noisy real system?
5. Describe one capstone project application where a PID controller like the one you built today would be directly applicable. Identify what the setpoint, process variable, and actuator would be in that application.

---

## Congratulations

You have completed the ME 3300 laboratory sequence. Over this semester you have built a complete measurement and control engineering toolkit:

- **Python and data analysis:** loading, processing, visualizing, and statistically characterizing experimental data
- **Sensor calibration:** converting raw signals to physical units with quantified uncertainty  
- **DAQ automation:** replacing manual GUI workflows with reproducible Python scripts
- **Signal theory:** sampling, aliasing, Nyquist, FFT, and frequency domain analysis
- **Signal conditioning:** op-amps, instrumentation amplifiers, and active filters
- **Measurement systems:** strain gauges, thermocouples, accelerometers, potentiometers
- **Feedback control:** characterizing a plant, implementing PID, and tuning for performance

These tools appear directly in capstone projects, research, and industry work. The habits you have built — calibrating sensors, quantifying uncertainty, automating measurements, and understanding the signal chain from physical phenomenon to computer — are the foundation of competent experimental engineering.
