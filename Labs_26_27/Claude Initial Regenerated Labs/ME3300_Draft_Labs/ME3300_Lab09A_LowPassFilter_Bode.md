# ME 3300 — Lab 09A: Active Low-Pass Filter and Automated Bode Plot
## Frequency Response, Triggering, and Measurement Automation

**Author:** Dr. Christopher Bitikofer  
**Course:** ME 3300 — Mechanical Measurements  

> **This is Part A of a two-week lab.**  
> **Lab 09A (this document):** Filter circuit, manual frequency sweep, automated Bode plot with triggering.  
> **Lab 09B (next week):** DC motor characterization and PID control.

---

## Learning Objectives

By the end of this lab, you should be able to:

- Design and build an active inverting low-pass filter using the LM358 op-amp
- Predict the cutoff frequency and magnitude ratio from component values
- Use the WaveForms GUI to manually observe filter frequency response
- Use `pydwf` to automate an AWG frequency sweep and capture triggered acquisition
- Explain why triggered capture is necessary for accurate phase measurement
- Compute magnitude ratio and phase shift from captured waveforms
- Plot an experimental Bode diagram and compare to the theoretical response

---

## Check Your Understanding

- What is a low-pass filter, and what does its cutoff frequency represent physically?
- What is a Bode plot, and what are its two panels?
- Why does a passive RC filter have a gain less than 1 even at DC?
- What is the advantage of an active filter over a passive RC filter?
- Why does a triggered capture give more accurate phase measurements than a free-running capture?
- What does a −3 dB point represent in terms of power and amplitude?

---

## Required Equipment

- Analog Discovery Studio (ADS) with USB cable
- LM358AN op-amp (DIP-8)
- Resistors: 2× 5 MΩ (or the nearest available value — see Part 1)
- Capacitor: 0.05 µF (50 nF)
- Breadboard, ±12 V supply, jumper wires
- Digital multimeter (DMM)

---

## Background: Active Inverting Low-Pass Filter

The circuit for this lab is an **active inverting low-pass filter** built from a single op-amp, two resistors ($R_1$ and $R_2$), and one capacitor ($C$). The filter passes low-frequency signals and attenuates high-frequency signals.

The magnitude ratio (output amplitude / input amplitude) as a function of frequency is:

$$M(\omega) = \frac{B}{KA} = \frac{1}{\sqrt{1 + (\omega\tau)^2}}$$

where $\tau = R_2 C$ is the filter time constant and $\omega = 2\pi f$ is angular frequency.

The phase shift is:

$$\phi(\omega) = -\tan^{-1}(\omega\tau) \quad \text{(radians)}$$

Note the negative sign: this filter introduces a **phase lag** — the output lags the input.

The **cutoff frequency** is defined where $M = 1/\sqrt{2} \approx -3$ dB:

$$f_c = \frac{1}{2\pi\tau} = \frac{1}{2\pi R_2 C}$$

In decibels, magnitude ratio is expressed as:

$$M_{dB} = 20 \log_{10}(M)$$

Above the cutoff frequency, the filter rolls off at −20 dB per decade (a factor of 10 in frequency reduces amplitude by a factor of 10).

---

## Part 1 — Circuit Design and Build

### 1.1 Choose Component Values

For this lab, use $R_1 = R_2 = 5 \, \text{M}\Omega$ and $C = 0.05 \, \mu\text{F} = 50 \times 10^{-9} \, \text{F}$.

Calculate the cutoff frequency:

$$f_c = \frac{1}{2\pi R_2 C} = \frac{1}{2\pi \times 5\times10^6 \times 50\times10^{-9}}$$

> **Q:** Compute $f_c$ in Hz. Record this in your lab notebook — you will compare it to your experimental result.

Measure the actual values of $R_1$, $R_2$, and $C$ with your DMM and compute the true expected cutoff frequency using measured values.

### 1.2 Build the Active Low-Pass Filter

**Circuit connections (LM358 op-amp Op-A, pins 1–3):**

```
AWG (W1) ──── R1 ──── (+IN, pin 3) ──── OUT (pin 1) ──── CH2+ (ADS)
                            │                  │
                           R2 ────┬──── C ─────┤ (−IN, pin 2)
                                  │
                                 GND
```

More precisely:
- W1 (AWG output) → one end of $R_1$
- Other end of $R_1$ → op-amp pin 3 (+IN) AND one end of $R_2$
- Other end of $R_2$ → one end of $C$ AND op-amp pin 2 (−IN)
- Other end of $C$ → op-amp pin 1 (OUT) and CH2+ on ADS
- Op-amp pin 8 → +12 V; pin 4 → −12 V
- CH1+ → W1 (monitor the input); CH1− → GND

> Double-check: the capacitor bridges $R_2$ and the output. This creates the frequency-dependent feedback that produces the low-pass characteristic.

> **Q:** Draw this circuit schematic in your lab notebook before building. Label all component values, pin numbers, and signal names.

---

## Part 2 — Manual Frequency Sweep in WaveForms

Before automating anything, manually sweep the frequency in WaveForms to develop intuition for the filter's behavior.

### 2.1 Configure WaveForms

1. Open **Wavegen** and set W1: Sine, Amplitude 1.0 V, Offset 0 V, Frequency 1 Hz.
2. Open **Scope** with CH1 and CH2 both enabled, Range ±2 V, Time 500 ms/div.
3. Enable ±12 V supplies in Supplies.
4. Run both instruments.

### 2.2 Observe and Record

Sweep the frequency from 0.1 Hz to 100 Hz in steps. At each frequency, use the WaveForms Measurements panel to record:
- Input amplitude (CH1 peak-to-peak / 2)
- Output amplitude (CH2 peak-to-peak / 2)
- Phase difference (CH2 vs. CH1, in degrees)

Record data at approximately: 0.1, 0.5, 1, 2, 5, 10, 20, $f_c$, 50, 100 Hz (adjust based on your $f_c$).

| Frequency (Hz) | $A_{in}$ (V) | $A_{out}$ (V) | $M = A_{out}/A_{in}$ | $M_{dB}$ | $\phi$ (°) |
|:-:|:-:|:-:|:-:|:-:|:-:|
| 0.1 | | | | | |
| ... | | | | | |

> **Q:** At what frequency does the output amplitude drop to approximately $1/\sqrt{2} \approx 0.707$ of the input? Does this match your computed $f_c$?  
> **Q:** What phase shift do you observe at $f_c$? Does it match the theoretical value of $-45°$?

---

## Part 3 — Automated Bode Plot with Triggered Acquisition

Now you will replace the manual measurement process with Python. The key to accurate phase measurement is **triggering**: both channels must start capturing at the same reference point (a rising zero-crossing of the input). Without this, you are computing phase from two unrelated time windows.

### 3.1 Why Triggering Matters for Phase

Imagine sampling CH1 and CH2 at arbitrary times. Each has its own starting phase. When you compute the time shift between the two signals, part of that shift reflects the actual filter phase delay, and another part reflects the arbitrary starting offsets — and you cannot separate them.

With a **rising-edge trigger on CH1**: both channels always start capturing from the same point in the input cycle. Any time shift you measure between CH1 and CH2 is entirely due to the filter's phase response. This is how every real spectrum analyzer works.

### 3.2 Automated Sweep Code

```python
from pydwf import (DwfLibrary, DwfState, DwfAnalogOutNode, DwfAnalogOutFunction,
                   DwfAnalogInTriggerSource, DwfTriggerSlope, DwfAcquisitionMode)
from pydwf.utilities import openDwfDevice
import numpy as np
import matplotlib.pyplot as plt
import time

plt.rcParams['font.family'] = 'serif'
plt.rcParams['font.serif'] = ['Times New Roman']
plt.rcParams['font.size'] = 10

# --- Sweep Parameters ---
# Logarithmically spaced from 0.1 Hz to 200 Hz
freqs_sweep = np.logspace(np.log10(0.1), np.log10(200), 40)

FS         = 10000     # acquisition sample rate (Hz) — must be >> max sweep freq
N_CYCLES   = 8         # number of cycles to capture per frequency
AMPLITUDE  = 1.0       # AWG amplitude (V)

# Component values (UPDATE with measured values)
R2_meas    = 5.0e6     # ohms
C_meas     = 50e-9     # farads
tau_theory = R2_meas * C_meas
fc_theory  = 1.0 / (2 * np.pi * tau_theory)
print(f"Theoretical cutoff: fc = {fc_theory:.3f} Hz")

def measure_at_freq(device, freq, fs=FS, n_cycles=N_CYCLES, amplitude=AMPLITUDE):
    """
    Output a sine at `freq` Hz via AWG, trigger on CH1 rising edge,
    capture both channels, and return magnitude ratio and phase shift.
    """
    ao  = device.analogOut
    ai  = device.analogIn

    # Number of samples: enough for n_cycles, minimum 512
    period    = 1.0 / freq
    n_samples = max(512, int(fs * n_cycles * period))
    n_samples = min(n_samples, 16384)   # hardware buffer limit

    # --- Configure AWG (W1) ---
    ao.nodeEnableSet(0, DwfAnalogOutNode.Carrier, True)
    ao.nodeFunctionSet(0, DwfAnalogOutNode.Carrier, DwfAnalogOutFunction.Sine)
    ao.nodeFrequencySet(0, DwfAnalogOutNode.Carrier, freq)
    ao.nodeAmplitudeSet(0, DwfAnalogOutNode.Carrier, amplitude)
    ao.nodeOffsetSet(0, DwfAnalogOutNode.Carrier, 0.0)
    ao.configure(0, True)
    time.sleep(max(0.05, 3 * period))   # let AWG settle (at least 3 cycles)

    # --- Configure analog input ---
    for ch in [0, 1]:
        ai.channelEnableSet(ch, True)
        ai.channelRangeSet(ch, 5.0)
    ai.frequencySet(fs)
    ai.bufferSizeSet(n_samples)
    ai.acquisitionModeSet(DwfAcquisitionMode.Single)

    # --- Configure trigger: rising edge on CH1, level = 0 V ---
    ai.triggerSourceSet(DwfAnalogInTriggerSource.DetectorAnalogIn)
    ai.triggerChannelSet(0)                      # trigger on CH1
    ai.triggerLevelSet(0.0)                      # trigger at 0 V
    ai.triggerConditionSet(DwfTriggerSlope.Rise)  # rising edge
    ai.triggerHysteresisSet(0.05)                # 50 mV hysteresis (noise rejection)

    ai.configure(True, True)   # arm trigger and start

    # Wait for triggered capture to complete
    timeout = time.time() + 5.0   # 5-second timeout
    while True:
        status = ai.status(True)
        if status == DwfState.Done:
            break
        if time.time() > timeout:
            raise TimeoutError(f"Trigger timeout at {freq:.2f} Hz")
        time.sleep(0.005)

    ch1 = np.array(ai.statusData(0, n_samples))
    ch2 = np.array(ai.statusData(1, n_samples))
    t   = np.arange(n_samples) / fs

    # --- Compute magnitude ratio ---
    A_in  = np.std(ch1) * np.sqrt(2)    # RMS → peak estimate
    A_out = np.std(ch2) * np.sqrt(2)
    M     = A_out / A_in if A_in > 1e-4 else np.nan

    # --- Compute phase shift using cross-correlation ---
    # Find time delay between CH1 and CH2 by locating their first rising zero-crossings
    def first_rising_zero(signal, t_arr):
        for i in range(1, len(signal)):
            if signal[i-1] < 0 and signal[i] >= 0:
                # Linear interpolation for sub-sample accuracy
                frac = -signal[i-1] / (signal[i] - signal[i-1])
                return t_arr[i-1] + frac * (t_arr[i] - t_arr[i-1])
        return np.nan

    t_zero_ch1 = first_rising_zero(ch1, t)
    t_zero_ch2 = first_rising_zero(ch2, t)
    dt_phase   = t_zero_ch2 - t_zero_ch1    # time delay (seconds)
    phase_deg  = -dt_phase * freq * 360.0   # convert to degrees (negative = lag)

    return M, phase_deg

# --- Run the sweep ---
M_measured     = []
phase_measured = []
freqs_valid    = []

dwf = DwfLibrary()

with openDwfDevice(dwf) as device:
    ps = device.analogIO
    ps.channelNodeSet(0, 0, 1); ps.channelNodeSet(0, 1, 12.0)
    ps.channelNodeSet(1, 0, 1); ps.channelNodeSet(1, 1, -12.0)
    ps.enableSet(True)
    time.sleep(0.3)

    for freq in freqs_sweep:
        try:
            M, phi = measure_at_freq(device, freq)
            M_measured.append(M)
            phase_measured.append(phi)
            freqs_valid.append(freq)
            print(f"  {freq:8.3f} Hz  |  M = {M:.4f}  ({20*np.log10(M):+.2f} dB)  |  φ = {phi:+.1f}°")
        except Exception as e:
            print(f"  {freq:8.3f} Hz  — skipped ({e})")

    device.analogOut.configure(0, False)
    ps.enableSet(False)

freqs_valid    = np.array(freqs_valid)
M_measured     = np.array(M_measured)
phase_measured = np.array(phase_measured)
M_dB_measured  = 20 * np.log10(M_measured)
```

### 3.3 Plot the Bode Diagram

```python
# Theoretical curves
f_theory = np.logspace(np.log10(0.05), np.log10(500), 500)
omega_t  = 2 * np.pi * f_theory * tau_theory
M_theory = 1.0 / np.sqrt(1 + omega_t**2)
phi_theory = -np.degrees(np.arctan(omega_t))

fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(6.5, 7.0), sharex=True)
fig.patch.set_facecolor('white')

# --- Magnitude panel ---
ax1.semilogx(f_theory,  20*np.log10(M_theory), color='blue', linewidth=2,
             linestyle='--', label=f'Theory (fc = {fc_theory:.3f} Hz)')
ax1.semilogx(freqs_valid, M_dB_measured, 'ro', markersize=6, label='Measured')

# Mark -3 dB line and cutoff
ax1.axhline(-3, color='gray', linewidth=1.0, linestyle=':', label='−3 dB')
# Find measured cutoff frequency (where M_dB first crosses -3 dB)
if np.any(M_dB_measured < -3):
    idx_fc = np.argmin(np.abs(M_dB_measured - (-3)))
    fc_meas = freqs_valid[idx_fc]
    ax1.axvline(fc_meas, color='green', linewidth=1.0, linestyle=':',
                label=f'Measured fc ≈ {fc_meas:.3f} Hz')

ax1.set_ylabel('Magnitude (dB)')
ax1.set_title('FirstName LastName — Bode Plot — Date')
ax1.legend(fontsize=9)
ax1.grid(True, which='both', linestyle='--', linewidth=0.5)
ax1.spines['top'].set_visible(False)
ax1.spines['right'].set_visible(False)

# --- Phase panel ---
ax2.semilogx(f_theory, phi_theory, color='blue', linewidth=2, linestyle='--',
             label='Theory')
ax2.semilogx(freqs_valid, phase_measured, 'ro', markersize=6, label='Measured')
ax2.axhline(-45, color='gray', linewidth=1.0, linestyle=':', label='−45° (at fc)')

ax2.set_xlabel('Frequency (Hz)')
ax2.set_ylabel('Phase (degrees)')
ax2.set_ylim(-100, 10)
ax2.legend(fontsize=9)
ax2.grid(True, which='both', linestyle='--', linewidth=0.5)
ax2.spines['top'].set_visible(False)
ax2.spines['right'].set_visible(False)

plt.tight_layout()
fig.savefig('../Figures/FirstName_LastName_Lab09A_Bode.pdf', dpi=600, bbox_inches='tight')
print("Bode plot saved.")
```

> **Q:** Does your measured cutoff frequency match the theoretical value? What is the percent error?  
> **Q:** At frequencies well above $f_c$, at what rate (dB/decade) does the magnitude decrease? Does this match the theoretical −20 dB/decade?  
> **Q:** At $f_c$, what phase shift do you measure? Does it match the theoretical −45°?  
> **Q:** Explain in your own words why triggering was necessary to get accurate phase measurements. What would have gone wrong without it?

---

## Part 4 — Connection to Previous Labs

This lab ties together concepts from across the semester. Answer the following in your lab notebook before leaving:

> **Q:** In Lab 04, you characterized aliasing by sampling a signal at different rates. In this lab, you chose $f_s = 10{,}000$ Hz for your sweep. Using the Nyquist theorem, what is the maximum signal frequency you could have measured with this sample rate?  
> **Q:** The low-pass filter you built today is the kind of anti-aliasing filter that is placed before a DAQ input in real measurement systems. Explain in one paragraph why an analog filter is needed before the ADC, rather than just filtering the data in software after sampling.  
> **Q:** In the thermocouple lab (Lab 08), the sensor had a time constant $\tau$. You just built a circuit that also has a time constant $\tau = R_2 C$. What do these two time constants have in common physically?

---

## Part 5 — Return Lab Space to Prior Condition

1. Disable all ADS power supplies before removing wires.
2. Remove all circuit components. Return capacitors and large resistors to their labeled containers.
3. Save all scripts and figures to OneDrive.
4. **Do not dismantle your workstation setup** — you will need the breadboard and ADS again next week for Lab 09B.
5. Log off the computer.

---

## Post-Lab Assignment

Submit the following to the Lab 09A Canvas page by **Monday at 10:00 PM**.

### Files to Submit

- Python script: `FirstName_LastName_Lab09A.py`
- Bode plot — two-panel (magnitude + phase) (`.pdf`)

### Bode Plot Requirements

- Both panels share a log-scale x-axis
- Measured data: red circles, marker size 6
- Theory: dashed blue line, 2 pt
- −3 dB reference line annotated on magnitude panel
- −45° reference line annotated on phase panel
- Theoretical and measured $f_c$ both marked
- Figure size: 6.5 in × 7.0 in

### Post-Lab Questions

1. Report your theoretical $f_c$ (from measured component values) and your experimentally measured $f_c$. What is the percentage error?
2. At 10× the cutoff frequency, what magnitude ratio (in dB) do you measure? How does this compare to the theoretical −20 dB/decade rolloff?
3. Explain in two to three sentences why triggered acquisition was necessary for accurate phase measurement in this lab.
4. An engineer needs to measure vibrations up to 500 Hz using this filter as an anti-aliasing filter. What minimum sample rate would be required to satisfy the Nyquist criterion after the filter's cutoff frequency?
5. You increase $R_2$ by a factor of 10. What happens to $f_c$? What happens to the DC gain of the filter?
