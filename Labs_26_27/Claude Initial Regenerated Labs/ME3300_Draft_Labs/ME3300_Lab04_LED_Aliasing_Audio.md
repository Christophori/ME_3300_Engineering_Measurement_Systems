# ME 3300 — Lab 04: Signals, Sampling, and Real-Time Control
## Aliasing, Nyquist, and LED Audio Visualizer

**Author:** Dr. Christopher Bitikofer  
**Course:** ME 3300 — Mechanical Measurements  

---

## Learning Objectives

By the end of this lab, you should be able to:

- Use the WaveForms Wavegen (AWG) to generate a programmable sine wave
- Use `pydwf` to generate signals with the AWG from Python
- Explain the Nyquist sampling theorem and predict alias frequencies
- Demonstrate aliasing experimentally by sampling above and below the Nyquist frequency
- Wire a simple LED circuit using the ADS digital output pins
- Control digital output pins from Python using `pydwf`
- Acquire audio from a microphone, compute an FFT, and map frequency bands to LEDs in real time

---

## Check Your Understanding

- What is the Nyquist frequency, and how does it relate to sample rate?
- If you sample a 450 Hz sine wave at 1000 Hz, what alias frequency will you observe?
- What is the folding formula for predicting alias frequency?
- How do you enable a digital output pin on the ADS using `pydwf`?
- What does `np.fft.rfft` return, and how do you convert output indices to frequencies in Hz?
- What does it mean for an LED to be driven by a digital HIGH signal from the ADS?

---

## Required Equipment

- Analog Discovery Studio (ADS) with USB cable
- Breadboard and jumper wire kit
- 4× LEDs (any color — variety recommended: red, yellow, green, blue)
- 4× 330 Ω resistors
- Electret microphone module (with built-in amplifier, e.g., MAX4466-based breakout)

---

## Software Required

- VS Code with `me3300` conda environment
- Python packages: `numpy`, `scipy`, `matplotlib`, `pandas`, `pydwf`

---

## Lab Introduction

This lab has three parts that each stand alone but connect deeply.

**Part 1** introduces the WaveForms AWG — the signal generation instrument you saw on the WaveForms welcome screen in Lab 02. You will use it to generate a known sine wave, observe it on the scope, and then capture it with Python at different sample rates to produce aliasing deliberately.

**Part 2** introduces the ADS digital output and LED circuits. This is the simplest circuit in the course — an LED and a resistor — but it teaches the foundation of every digital control output you will use in capstone and beyond.

**Part 3** brings everything together: you will write a Python program that reads an audio signal from a microphone, computes a Fast Fourier Transform (FFT) to split the signal into frequency bands, and lights different LEDs based on energy in each band. The result is a live, physically satisfying demonstration of everything you have learned about signals, sampling, and hardware control this semester.

---

## Background: Sampling, Nyquist, and Aliasing

A digital data acquisition system cannot capture a signal at every instant in time — it samples the signal at discrete time intervals at a rate of $f_s$ samples per second.

The **Nyquist frequency** is:

$$f_N = \frac{f_s}{2}$$

This is the highest frequency that can be accurately represented at a given sample rate. Any signal component with frequency $f > f_N$ **cannot be distinguished** from a lower-frequency component and will appear as an **alias** — a false frequency.

The alias frequency of a signal at frequency $f_{signal}$ sampled at $f_s$ is predicted by the folding formula:

$$f_{alias} = \left| f_{signal} - \text{round}\!\left(\frac{f_{signal}}{f_s}\right) \cdot f_s \right|$$

This is not just a textbook curiosity. Aliasing has caused real engineering failures: sensors sampled too slowly have missed dangerous vibrations, and audio systems have produced phantom tones from undersampled inputs. Every time you choose a sample rate in this course — and in your career — the Nyquist theorem governs what you can and cannot detect.

---

## Part 1 — AWG Signal Generation and Aliasing

### 1.1 Generate a Sine Wave with the WaveForms GUI

**Before writing any code**, explore the AWG in the WaveForms GUI.

1. Open WaveForms. Open the **Scope** and **Wavegen** instruments side-by-side.
2. In Wavegen, configure **W1** (Channel 1 output):
   - Waveform: **Sine**
   - Frequency: **100 Hz**
   - Amplitude: **1.0 V** (peak)
   - Offset: **0.0 V**
3. Click **Run** in both Wavegen and Scope.
4. Connect **W1** on the ADS to **CH1+** on the ADS with a short jumper wire (loop the output back to an input).
5. You should see a clean 100 Hz sine wave on the scope.

> **Q:** Using the WaveForms cursor tool, measure the period of the waveform. Does it match 1/100 Hz = 10 ms?  
> **Q:** What is the relationship between the Wavegen panel in WaveForms and `device.analogOut` in pydwf?

### 1.2 Generate the Same Signal with pydwf

Stop WaveForms and close it. Now replicate the same 100 Hz sine wave from Python:

```python
from pydwf import DwfLibrary, DwfAnalogOutNode, DwfAnalogOutFunction
from pydwf.utilities import openDwfDevice
import time

dwf = DwfLibrary()

FREQ      = 100.0   # Hz
AMPLITUDE = 1.0     # V peak
OFFSET    = 0.0     # V DC offset

with openDwfDevice(dwf) as device:
    ao = device.analogOut
    ch = 0   # W1 is channel 0 (0-indexed)

    ao.nodeEnableSet(ch, DwfAnalogOutNode.Carrier, True)
    ao.nodeFunctionSet(ch, DwfAnalogOutNode.Carrier, DwfAnalogOutFunction.Sine)
    ao.nodeFrequencySet(ch, DwfAnalogOutNode.Carrier, FREQ)
    ao.nodeAmplitudeSet(ch, DwfAnalogOutNode.Carrier, AMPLITUDE)
    ao.nodeOffsetSet(ch, DwfAnalogOutNode.Carrier, OFFSET)
    ao.configure(ch, True)   # start output

    print(f"Generating {FREQ} Hz sine wave on W1. Open WaveForms Scope to verify.")
    input("Press Enter to stop...")

    ao.configure(ch, False)  # stop output
```

Open WaveForms Scope (you can open it alongside a running pydwf script since it only reads, not controls). Confirm the signal looks identical to what you set up manually in step 1.1.

> **Q:** What is the benefit of generating signals programmatically rather than setting them by hand each time?

### 1.3 Aliasing Demonstration

You will now sample the AWG signal at different rates and observe aliasing. Keep the AWG outputting a **100 Hz** sine wave throughout this part.

Write a function that acquires N samples at a given sample rate and plots the result:

```python
import numpy as np
import matplotlib.pyplot as plt

plt.rcParams['font.family'] = 'serif'
plt.rcParams['font.serif'] = ['Times New Roman']
plt.rcParams['font.size'] = 10

def capture_and_plot(device, ax, fs, duration, label):
    """Capture signal at sample rate fs and plot on axes ax."""
    ai  = device.analogIn
    n   = int(fs * duration)

    ai.channelEnableSet(0, True)
    ai.channelRangeSet(0, 5.0)
    ai.frequencySet(fs)
    ai.bufferSizeSet(n)
    ai.configure(False, True)

    while True:
        from pydwf import DwfState
        if ai.status(True) == DwfState.Done:
            break
        time.sleep(0.005)

    data = np.array(ai.statusData(0, n))
    t    = np.arange(n) / fs

    ax.plot(t * 1000, data, marker='o', markersize=3, linewidth=1.0)
    ax.set_title(f'{label}  (fs = {fs} Hz, fN = {fs/2:.0f} Hz)', fontsize=10)
    ax.set_xlabel('Time (ms)')
    ax.set_ylabel('Voltage (V)')
    ax.set_ylim(-1.5, 1.5)
    ax.grid(True, linestyle='--', linewidth=0.5)
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
```

Now acquire at five sample rates and plot all five in a single figure:

```python
F_SIGNAL = 100.0   # Hz — AWG output frequency
F_N      = 500.0   # Nyquist frequency for fs=1000 Hz

sample_rates = [
    (1000, f'Well below Nyquist: f_sig = 0.20 × f_N'),    # 100 Hz << 500 Hz
    (222,  f'Near Nyquist: f_sig ≈ 0.90 × f_N'),          # 100 Hz ≈ 0.9 × 111 Hz
    (200,  f'At Nyquist: f_sig = 1.00 × f_N'),             # 100 Hz = 0.5 × 200 Hz
    (182,  f'Above Nyquist: f_sig = 1.10 × f_N'),          # predicted alias: 18 Hz
    (89,   f'Well above Nyquist: f_sig = 2.25 × f_N'),     # predicted alias: 11 Hz
]

# Compute predicted alias frequencies
print("\nAlias frequency predictions:")
for fs, label in sample_rates:
    f_alias = abs(F_SIGNAL - round(F_SIGNAL / fs) * fs)
    print(f"  fs={fs:5d} Hz → predicted alias = {f_alias:.1f} Hz  ({label[:30]})")

fig, axes = plt.subplots(5, 1, figsize=(6.5, 10.0), constrained_layout=True)
fig.patch.set_facecolor('white')

dwf = DwfLibrary()
with openDwfDevice(dwf) as device:
    # Start AWG
    ao = device.analogOut
    ao.nodeEnableSet(0, DwfAnalogOutNode.Carrier, True)
    ao.nodeFunctionSet(0, DwfAnalogOutNode.Carrier, DwfAnalogOutFunction.Sine)
    ao.nodeFrequencySet(0, DwfAnalogOutNode.Carrier, F_SIGNAL)
    ao.nodeAmplitudeSet(0, DwfAnalogOutNode.Carrier, 1.0)
    ao.nodeOffsetSet(0, DwfAnalogOutNode.Carrier, 0.0)
    ao.configure(0, True)
    time.sleep(0.1)   # let AWG settle

    for ax, (fs, label) in zip(axes, sample_rates):
        capture_and_plot(device, ax, fs=fs, duration=0.05, label=label)

    ao.configure(0, False)

fig.suptitle(f'FirstName LastName — Aliasing Demo (f_signal = {F_SIGNAL} Hz) — Date',
             fontsize=10)
fig.savefig('../Figures/FirstName_LastName_Lab04_Aliasing.pdf', dpi=600)
```

> **Q:** In the 3rd plot (at Nyquist), what does the sampled signal look like? Does it still look like a sine wave?  
> **Q:** For the 4th case (fs = 182 Hz), what alias frequency do you observe? Does it match your prediction from the folding formula?  
> **Q:** For the 5th case (fs = 89 Hz), what alias frequency do you observe?  
> **Q:** This lab uses only one DAQ sample rate. In your previous pendulum labs, you also chose sample rates. Could aliasing have affected those measurements? Explain.

---

## Part 2 — LED Circuits and Digital Output

### 2.1 LED Circuit Background

An LED (light-emitting diode) emits light when current flows through it in the forward direction. Like all diodes, it has a forward voltage drop $V_f$ (typically 1.8–2.2 V for standard LEDs). A series resistor limits the current to a safe value.

The ADS digital output pins supply **3.3 V** when HIGH. To limit current to a safe ~10 mA:

$$R = \frac{V_{supply} - V_f}{I} = \frac{3.3 - 2.0}{0.010} = 130 \, \Omega$$

A **330 Ω** resistor (the next standard value up) gives a safe and visible brightness. Do not omit the resistor — connecting an LED directly to a voltage source will burn it out immediately.

### 2.2 Wire Four LED Circuits

Wire four identical circuits on the breadboard:

```
ADS Digital Pin (DIO 0–3) → 330 Ω resistor → LED anode (+) → LED cathode (−) → GND
```

| LED | ADS Digital Pin |
|:--|:--|
| LED 1 (Bass — Low freq) | DIO 0 |
| LED 2 (Low-mid freq) | DIO 1 |
| LED 3 (High-mid freq) | DIO 2 |
| LED 4 (Treble — High freq) | DIO 3 |

> **LED polarity:** The longer leg of the LED is the **anode** (+) and connects toward the resistor (positive side). The shorter leg is the **cathode** (−) and connects to GND.

Verify each LED before moving on by temporarily connecting the resistor/LED chain between 3.3 V and GND. All four should illuminate.

### 2.3 Control LEDs with pydwf

```python
from pydwf import DwfLibrary
from pydwf.utilities import openDwfDevice
import time

dwf = DwfLibrary()

with openDwfDevice(dwf) as device:
    dio = device.digitalIO

    # Enable pins 0–3 as outputs (bitmask: lower 4 bits = 1)
    dio.outputEnableSet(0x0F)   # 0b00001111

    # Chase pattern to verify all four LEDs
    print("Running LED test sequence...")
    for _ in range(3):
        for pin in range(4):
            dio.outputSet(1 << pin)   # shift 1 left by pin number
            time.sleep(0.15)
    dio.outputSet(0x00)  # all off
    print("Test complete.")
```

Run this script. You should see each LED light in sequence, three times.

> **Q:** What does `1 << pin` compute for pin = 0, 1, 2, 3? Write out each value in binary and decimal.  
> **Q:** How would you modify `dio.outputSet(...)` to turn on LEDs 1 and 3 simultaneously?

---

## Part 3 — Real-Time Audio Visualizer

### 3.1 Wire the Microphone

The electret microphone module outputs an analog voltage proportional to sound pressure level. Wire it as follows:

| Microphone module pin | ADS connection |
|:--|:--|
| VCC | 3.3 V |
| GND | GND |
| OUT | CH1+ (Analog In) |
| (CH1−) | GND |

Hold the module in a fixed position or tape it to the breadboard to keep the signal stable.

Test the connection: open WaveForms Scope and observe CH1 while speaking or clapping near the microphone. You should see the voltage fluctuate with the audio.

> **Q:** With the room quiet, what is the approximate DC offset voltage from the microphone? What is the approximate peak-to-peak variation when you speak normally?

### 3.2 Understand the FFT Approach

The core of the audio visualizer is the **Fast Fourier Transform (FFT)**, which decomposes a time-domain signal into its frequency components.

Given N samples at sample rate $f_s$:

```python
spectrum = np.fft.rfft(signal)          # real FFT (N/2 + 1 complex values)
freqs    = np.fft.rfftfreq(N, d=1/fs)  # corresponding frequencies in Hz
magnitudes = np.abs(spectrum)           # amplitude of each frequency component
```

You will split the frequency range into four bands and compute the total energy in each:

| LED | Frequency band |
|:--|:--|
| DIO 0 | 20 – 300 Hz (bass) |
| DIO 1 | 300 – 1000 Hz (low-mid) |
| DIO 2 | 1000 – 4000 Hz (high-mid) |
| DIO 3 | 4000 – 10000 Hz (treble) |

An LED lights up when the energy in its band exceeds a threshold.

### 3.3 Real-Time Visualizer Program

This is the most complex program you have written in this course. Read through the full structure before running anything.

```python
from pydwf import DwfLibrary, DwfState
from pydwf.utilities import openDwfDevice
import numpy as np
import time

# --- Parameters ---
FS         = 20000    # 20 kHz sample rate — covers audio range up to 10 kHz
CHUNK_SIZE = 2048     # samples per FFT window
DURATION   = CHUNK_SIZE / FS   # seconds per chunk (~0.1 s)

# Frequency band boundaries (Hz)
BANDS = [(20, 300), (300, 1000), (1000, 4000), (4000, 10000)]
N_LEDS = len(BANDS)

# Sensitivity threshold for each band — tune these during the lab
# Higher threshold = less sensitive (LED harder to trigger)
THRESHOLDS = [5.0, 3.0, 2.0, 2.0]   # starting values; adjust as needed

def compute_band_energies(signal, fs, bands):
    """
    Compute the total FFT magnitude in each frequency band.

    Returns a list of float energies, one per band.
    """
    spectrum   = np.fft.rfft(signal)
    freqs      = np.fft.rfftfreq(len(signal), d=1.0/fs)
    magnitudes = np.abs(spectrum) / len(signal)   # normalize by N

    energies = []
    for f_low, f_high in bands:
        mask   = (freqs >= f_low) & (freqs < f_high)
        energy = np.sum(magnitudes[mask])
        energies.append(energy)
    return energies

def energies_to_led_mask(energies, thresholds):
    """Convert band energies to a 4-bit LED bitmask."""
    mask = 0
    for i, (energy, threshold) in enumerate(zip(energies, thresholds)):
        if energy > threshold:
            mask |= (1 << i)
    return mask

# --- Main loop ---
print("Starting audio visualizer. Press Ctrl+C to stop.")
print(f"Sample rate: {FS} Hz  |  Chunk size: {CHUNK_SIZE}  |  Nyquist: {FS//2} Hz")

dwf = DwfLibrary()

try:
    with openDwfDevice(dwf) as device:
        ai  = device.analogIn
        dio = device.digitalIO

        # Configure analog input
        ai.channelEnableSet(0, True)
        ai.channelRangeSet(0, 5.0)
        ai.frequencySet(FS)
        ai.bufferSizeSet(CHUNK_SIZE)

        # Configure digital output
        dio.outputEnableSet(0x0F)
        dio.outputSet(0x00)

        while True:
            # Acquire one chunk
            ai.configure(False, True)
            while True:
                if ai.status(True) == DwfState.Done:
                    break
                time.sleep(0.001)
            chunk = np.array(ai.statusData(0, CHUNK_SIZE))

            # Remove DC offset
            chunk = chunk - chunk.mean()

            # Compute FFT and band energies
            energies = compute_band_energies(chunk, FS, BANDS)

            # Update LEDs
            led_mask = energies_to_led_mask(energies, THRESHOLDS)
            dio.outputSet(led_mask)

except KeyboardInterrupt:
    print("\nStopped.")
    # Turn off LEDs on exit
    with openDwfDevice(dwf) as device:
        device.digitalIO.outputEnableSet(0x0F)
        device.digitalIO.outputSet(0x00)
```

### 3.4 Run and Tune the Visualizer

1. Run the script.
2. Speak, clap, whistle, or play music near the microphone.
3. Observe which LEDs respond to which sounds.
4. Adjust the `THRESHOLDS` list to make the visualizer more or less sensitive.
   - If all LEDs are always on (too sensitive): increase the threshold values.
   - If no LEDs ever light up (not sensitive enough): decrease the threshold values.

> **Q:** Which LED (frequency band) responds to a hand clap? To a low hum? To a whistle?  
> **Q:** Why do we subtract the mean (`chunk.mean()`) before computing the FFT? What would happen if we did not?  
> **Q:** The sample rate is 20,000 Hz. What is the Nyquist frequency? Does this cover the full range of human hearing?  
> **Q:** Aliasing: if a sound at 12,000 Hz enters the microphone, what alias frequency would appear in your FFT? Which LED band would it falsely trigger?  
> **Q:** How does this program relate to what you did in Part 1? Describe the connection between the aliasing demonstration and the design decisions (sample rate, chunk size) in this visualizer.

### 3.5 Capture and Plot a Sample FFT

Add the following code to capture one chunk and produce a static FFT plot for your post-lab submission. Run it **after** testing the real-time loop.

```python
dwf = DwfLibrary()

with openDwfDevice(dwf) as device:
    ai = device.analogIn
    ai.channelEnableSet(0, True)
    ai.channelRangeSet(0, 5.0)
    ai.frequencySet(FS)
    ai.bufferSizeSet(CHUNK_SIZE)
    ai.configure(False, True)

    while True:
        if ai.status(True) == DwfState.Done:
            break
        time.sleep(0.001)

    chunk = np.array(ai.statusData(0, CHUNK_SIZE))

chunk = chunk - chunk.mean()
spectrum   = np.fft.rfft(chunk)
freqs      = np.fft.rfftfreq(CHUNK_SIZE, d=1.0/FS)
magnitudes = np.abs(spectrum) / CHUNK_SIZE

import matplotlib.pyplot as plt
plt.rcParams['font.family'] = 'serif'
plt.rcParams['font.serif'] = ['Times New Roman']
plt.rcParams['font.size'] = 10

band_colors = ['red', 'orange', 'green', 'blue']
band_labels = ['Bass (20–300 Hz)', 'Low-mid (300–1 kHz)',
               'High-mid (1–4 kHz)', 'Treble (4–10 kHz)']

fig, ax = plt.subplots(figsize=(6.5, 3.5))
fig.patch.set_facecolor('white')

ax.plot(freqs / 1000, magnitudes, color='black', linewidth=0.8, alpha=0.7)

for (f_low, f_high), color, lbl in zip(BANDS, band_colors, band_labels):
    mask = (freqs >= f_low) & (freqs < f_high)
    ax.fill_between(freqs[mask] / 1000, magnitudes[mask], alpha=0.4,
                    color=color, label=lbl)

ax.set_xlabel('Frequency (kHz)')
ax.set_ylabel('Magnitude (normalized)')
ax.set_xlim(0, 10)
ax.set_title('FirstName LastName — Audio FFT with Frequency Bands — Date')
ax.legend(fontsize=9)
ax.grid(True, which='both', linestyle='--', linewidth=0.5)
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)

plt.tight_layout()
fig.savefig('../Figures/FirstName_LastName_Lab04_AudioFFT.pdf', dpi=600, bbox_inches='tight')
print("FFT plot saved.")
```

Capture this while making a consistent sound (e.g., humming a steady note, or playing a tone from your phone) so the spectrum has visible peaks.

---

## Part 4 — Return Lab Space to Prior Condition

1. Remove all wires from the breadboard. Return LEDs and resistors to their labeled containers.
2. Save all scripts and figures to OneDrive.
3. Confirm both partners have access to all files.
4. Log off the computer.

---

## Post-Lab Assignment

Submit the following to the Lab 04 Canvas page by **Monday at 10:00 PM**.

### Files to Submit

- Python script: `FirstName_LastName_Lab04.py`
- Aliasing figure — 5-panel subplot (`.pdf`)
- Audio FFT plot with frequency bands (`.pdf`)

### Aliasing Figure Requirements

- 5 subplots (one per sample rate), stacked vertically
- Each subplot title includes: measured sample rate, signal frequency, predicted alias frequency, and observed alias frequency
- Time axis in milliseconds
- Show only the first 3–5 cycles in each subplot
- Figure size: 6.5 in × 10.0 in

### Audio FFT Requirements

- Frequency bands shaded in distinct colors with legend
- X-axis in kHz, 0–10 kHz range
- Captured while producing a recognizable sound (note in title)
- All Lab 01 formatting standards apply

### Post-Lab Questions

1. For a sample rate of 1000 Hz, what is the Nyquist frequency?
2. You sample a 550 Hz signal at 1000 Hz. Use the folding formula to predict the alias frequency.
3. In your aliasing plot, does the observed alias frequency from the 4th panel match your prediction? If not, what might explain the discrepancy?
4. Why was the sample rate for the audio visualizer set to 20,000 Hz? What would happen if you used 1,000 Hz instead?
5. Explain in two to three sentences how the LED visualizer relates to the aliasing demonstration — what do they have in common in terms of the underlying signal theory?
