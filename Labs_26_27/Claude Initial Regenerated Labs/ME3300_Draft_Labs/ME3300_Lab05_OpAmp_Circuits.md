# ME 3300 — Lab 05: Operational Amplifier Circuits
## Non-Inverting Amplifier and Instrumentation Amplifier

**Author:** Dr. Christopher Bitikofer  
**Course:** ME 3300 — Mechanical Measurements  

---

## Learning Objectives

By the end of this lab, you should be able to:

- Explain the operating principle of an ideal operational amplifier
- Design and build a non-inverting amplifier using the LM358 op-amp
- Design and build an instrumentation amplifier circuit using the AD622
- Predict gain from component values and verify experimentally
- Use the ADS AWG and analog inputs with pydwf to perform automated gain measurements
- Plot gain error across a range of input voltages and identify sources of non-ideal behavior

---

## Check Your Understanding

- What are the two golden rules of an ideal op-amp?
- For a non-inverting amplifier, what is the gain formula in terms of $R_1$ and $R_2$?
- What is the difference between a general-purpose op-amp (LM358) and an instrumentation amplifier (AD622)?
- What is the ADS ±12 V supply used for, and why do op-amps require a dual-rail power supply?
- What does "input range" mean for an op-amp, and what happens when you exceed it?

---

## Required Equipment

- Analog Discovery Studio (ADS) with USB cable
- LM358AN op-amp (DIP-8 package)
- AD622AN instrumentation amplifier (DIP-8 package)
- Breadboard and jumper wire kit
- Resistor kit (10 kΩ and 20 kΩ resistors required; see Part 1)
- Digital multimeter (DMM)

---

## Software Required

- VS Code with `me3300` conda environment
- Python packages: `numpy`, `matplotlib`, `pydwf`

---

## Background: Operational Amplifiers

An **operational amplifier** (op-amp) is a high-gain differential voltage amplifier. In practice, negative feedback is used to set a precise, stable gain determined entirely by external resistors — not by the op-amp's internal gain.

The two **golden rules** of an ideal op-amp with negative feedback:

1. **The voltage at the inverting (−) and non-inverting (+) inputs are equal.**
2. **No current flows into either input terminal.**

These rules simplify circuit analysis enormously and are accurate for most practical circuits.

### Non-Inverting Amplifier

The non-inverting amplifier has a gain of:

$$G = 1 + \frac{R_2}{R_1}$$

The output voltage is:

$$V_{out} = G \cdot V_{in}$$

The output is in phase with (not inverted from) the input.

### Instrumentation Amplifier

The AD622 is a single-chip instrumentation amplifier. Its gain is set by a single external resistor $R_G$:

$$G = 1 + \frac{50{,}400 \, \Omega}{R_G}$$

Instrumentation amplifiers have very high input impedance, high common-mode rejection, and are designed for amplifying small differential signals in the presence of noise — exactly the application you will encounter in the strain gauge lab next week.

---

## Part 1 — Non-Inverting Amplifier

### 1.1 Enable the ±12 V Power Supply

The LM358 requires a dual-rail power supply. The ADS provides ±12 V directly.

1. In WaveForms, open **Supplies**.
2. Enable both the **+12 V** and **−12 V** outputs.
3. Verify each supply with your DMM before connecting anything.

Alternatively, enable the supplies from Python:

```python
from pydwf import DwfLibrary
from pydwf.utilities import openDwfDevice

dwf = DwfLibrary()

with openDwfDevice(dwf) as device:
    ps = device.analogIO

    # Channel 0 = positive supply, Channel 1 = negative supply
    # Node 0 = enable, Node 1 = voltage setpoint
    ps.channelNodeSet(0, 0, 1)      # enable positive supply
    ps.channelNodeSet(0, 1, 12.0)   # set to +12 V

    ps.channelNodeSet(1, 0, 1)      # enable negative supply
    ps.channelNodeSet(1, 1, -12.0)  # set to −12 V

    ps.enableSet(True)              # master enable
    print("±12 V supplies enabled.")
    input("Press Enter to disable and exit...")
    ps.enableSet(False)
```

> **Warning:** Always enable the power supply **after** building and verifying your circuit, not before. Double-check all connections before applying power to an op-amp circuit.

### 1.2 Build the Non-Inverting Amplifier

**Target gain: G = 3**

Choose resistor values:

$$G = 1 + \frac{R_2}{R_1} = 3 \implies \frac{R_2}{R_1} = 2$$

Use $R_1 = 10 \, \text{k}\Omega$ and $R_2 = 20 \, \text{k}\Omega$.

**Before building:** Measure the actual values of both resistors with your DMM and record them. You will use the measured values (not nominal values) to compute the expected gain.

**Circuit connections (LM358 DIP-8 pinout):**

| LM358 Pin | Connection |
|:-:|:--|
| 8 (V+) | +12 V from ADS |
| 4 (V−) | −12 V from ADS |
| 3 (+IN, non-inverting) | Input signal (W1 from ADS AWG) |
| 2 (−IN, inverting) | Junction of R1 and R2 |
| 1 (OUT) | Output → CH2+ (ADS Analog In) and top of R2 |
| R1 bottom | GND |
| R2 top | Output |
| R2 bottom | −IN (pin 2) |

> The LM358 contains two independent op-amps. This lab uses **Op-Amp A** (pins 1, 2, 3). The pinout diagram is provided in the lab appendix and on the Canvas page.

Build the circuit neatly. Run power supply rails along the long breadboard rails. Place the DIP chip across the center channel.

### 1.3 Automated Gain Measurement with pydwf

You will sweep the AWG output from −2 V to +2 V and measure the amplifier output at each step.

```python
from pydwf import DwfLibrary, DwfState, DwfAnalogOutNode, DwfAnalogOutFunction
from pydwf.utilities import openDwfDevice
import numpy as np
import matplotlib.pyplot as plt
import time

plt.rcParams['font.family'] = 'serif'
plt.rcParams['font.serif'] = ['Times New Roman']
plt.rcParams['font.size'] = 10

# Measured resistor values — UPDATE with your DMM readings
R1_measured = 9980.0    # ohms
R2_measured = 19950.0   # ohms
G_expected  = 1 + R2_measured / R1_measured
print(f"Expected gain (from measured resistors): {G_expected:.4f}")

# Input voltage sweep
v_in_targets = np.linspace(-2.0, 2.0, 25)

v_in_measured  = []
v_out_measured = []

fs       = 1000
duration = 0.1    # 100 ms per measurement point
n        = int(fs * duration)

dwf = DwfLibrary()

with openDwfDevice(dwf) as device:
    ao  = device.analogOut
    ai  = device.analogIn
    ps  = device.analogIO

    # Enable ±12 V supplies
    ps.channelNodeSet(0, 0, 1); ps.channelNodeSet(0, 1, 12.0)
    ps.channelNodeSet(1, 0, 1); ps.channelNodeSet(1, 1, -12.0)
    ps.enableSet(True)
    time.sleep(0.2)

    # Configure analog inputs
    for ch in [0, 1]:
        ai.channelEnableSet(ch, True)
        ai.channelRangeSet(ch, 10.0)   # ±10 V range for op-amp output
    ai.frequencySet(fs)
    ai.bufferSizeSet(n)

    # Configure AWG (W1 → op-amp input)
    ao.nodeEnableSet(0, DwfAnalogOutNode.Carrier, True)
    ao.nodeFunctionSet(0, DwfAnalogOutNode.Carrier, DwfAnalogOutFunction.DC)
    ao.nodeOffsetSet(0, DwfAnalogOutNode.Carrier, 0.0)
    ao.configure(0, True)
    time.sleep(0.1)

    for v_target in v_in_targets:
        # Set DC output
        ao.nodeOffsetSet(0, DwfAnalogOutNode.Carrier, float(v_target))
        ao.configure(0, True)
        time.sleep(0.05)   # settle

        # Acquire both channels
        ai.configure(False, True)
        while True:
            if ai.status(True) == DwfState.Done:
                break
            time.sleep(0.005)

        ch1_data = np.array(ai.statusData(0, n))   # input (V_in)
        ch2_data = np.array(ai.statusData(1, n))   # output (V_out)

        v_in_measured.append(ch1_data.mean())
        v_out_measured.append(ch2_data.mean())

    ao.configure(0, False)
    ps.enableSet(False)

v_in_measured  = np.array(v_in_measured)
v_out_measured = np.array(v_out_measured)
G_measured     = v_out_measured / v_in_measured
```

### 1.4 Plot the Results

```python
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(6.5, 3.5))
fig.patch.set_facecolor('white')

# Left: V_out vs V_in with ideal line
v_ideal = G_expected * v_in_measured
ax1.scatter(v_in_measured, v_out_measured, s=40, color='blue', zorder=5, label='Measured')
ax1.plot(v_in_measured, v_ideal, 'r--', linewidth=1.5,
         label=f'Ideal (G={G_expected:.3f})')
ax1.set_xlabel('$V_{in}$ (V)')
ax1.set_ylabel('$V_{out}$ (V)')
ax1.set_title('Output vs. Input')
ax1.legend(fontsize=9)
ax1.grid(True, linestyle='--', linewidth=0.5)
ax1.spines['top'].set_visible(False)
ax1.spines['right'].set_visible(False)

# Right: gain error vs V_in
gain_error_pct = (G_measured - G_expected) / G_expected * 100
ax2.scatter(v_in_measured, gain_error_pct, s=40, color='red', zorder=5)
ax2.axhline(0, color='black', linewidth=1.0, linestyle='--')
ax2.set_xlabel('$V_{in}$ (V)')
ax2.set_ylabel('Gain Error (%)')
ax2.set_title('Gain Error vs. Input Voltage')
ax2.grid(True, linestyle='--', linewidth=0.5)
ax2.spines['top'].set_visible(False)
ax2.spines['right'].set_visible(False)

fig.suptitle('FirstName LastName — Non-Inverting Amplifier — Date', fontsize=10)
plt.tight_layout()
fig.savefig('../Figures/FirstName_LastName_Lab05_NonInverting.pdf', dpi=600, bbox_inches='tight')
```

> **Q:** Does the measured gain match the expected gain from your resistor values? What is the maximum gain error as a percentage?  
> **Q:** At what input voltage does the output begin to saturate (stop increasing linearly)? Why does this happen?  
> **Q:** How does the LM358's supply voltage (±12 V) limit the output swing?

---

## Part 2 — Instrumentation Amplifier (AD622)

### 2.1 Gain Design

**Target gain: G = 3**

$$G = 1 + \frac{50{,}400}{R_G} = 3 \implies R_G = \frac{50{,}400}{G-1} = \frac{50{,}400}{2} = 25{,}200 \, \Omega$$

The nearest standard resistor value is **24.9 kΩ** (if available) or use two 12.7 kΩ resistors in series, or look in the resistor kit for the closest match. Measure the actual value with your DMM and compute the true expected gain.

$$G_{expected} = 1 + \frac{50{,}400}{R_G^{measured}}$$

**AD622 DIP-8 Pinout:**

| AD622 Pin | Connection |
|:-:|:--|
| 1 (RG−) | One end of $R_G$ |
| 8 (RG+) | Other end of $R_G$ |
| 2 (−IN) | Inverting input signal |
| 3 (+IN) | Non-inverting input signal |
| 4 (V−) | −12 V from ADS |
| 7 (V+) | +12 V from ADS |
| 6 (OUT) | Output → CH2 on ADS |
| 5 (REF) | GND (sets output reference) |

### 2.2 Build the Instrumentation Amplifier Circuit

Remove the LM358 circuit from the breadboard. Build the AD622 circuit:

1. Place the AD622 across the breadboard center channel.
2. Connect the $R_G$ resistor between pins 1 and 8.
3. Connect the ADS **W1** output to pin 3 (+IN). Connect pin 2 (−IN) to **GND** — for this test, you are amplifying a single-ended signal, not a differential one.
4. Connect ±12 V supply rails to pins 7 and 4.
5. Connect pin 5 (REF) to GND.
6. Connect pin 6 (OUT) to **CH2+** on the ADS (CH2− to GND).

### 2.3 Repeat the Automated Gain Sweep

Reuse the same pydwf gain measurement script from Part 1, updating only `G_expected`:

```python
R_G_measured = 24900.0   # ohms — UPDATE with your DMM measurement
G_expected   = 1 + 50400.0 / R_G_measured
print(f"Expected gain (AD622): {G_expected:.4f}")
```

Run the sweep, generate the same two-panel plot, and save as `FirstName_LastName_Lab05_InstAmp.pdf`.

> **Q:** Compare the gain error between the LM358 and AD622 circuits. Which has smaller error across the sweep range? Why?  
> **Q:** An AD622 is used in the strain gauge lab next week. Based on what you observed today, why is an instrumentation amplifier preferred over a general-purpose op-amp for that application?  
> **Q:** If you needed G = 100 with the AD622, what value of $R_G$ would you choose?

---

## Part 3 — Return Lab Space to Prior Condition

1. Disable the ADS power supplies before removing any wires.
2. Remove all components from the breadboard and return them to labeled containers.
3. Confirm all data and scripts are saved to OneDrive.
4. Log off the computer.

---

## Post-Lab Assignment

Submit the following to the Lab 05 Canvas page by **Monday at 10:00 PM**.

### Files to Submit

- Python script: `FirstName_LastName_Lab05.py`
- Non-inverting amplifier plot (`.pdf`) — V_out vs. V_in + gain error panel
- Instrumentation amplifier plot (`.pdf`) — same format

### Plot Requirements

Both plots: two side-by-side panels (V_out vs. V_in with ideal line; gain error % vs. V_in). Figure size: 6.5 in × 3.5 in. All Lab 01 formatting standards.

### Post-Lab Questions

1. Report your measured resistor values and the resulting expected gain for Part 1.
2. What was the maximum gain error (%) for the LM358 circuit? At what input voltage did it occur?
3. What was the expected and measured gain for the AD622 circuit?
4. At what input voltage did the LM358 output begin to saturate? Does this make sense given the ±12 V supply?
5. You need to amplify a 5 mV signal from a load cell by a factor of 500. Would you use the LM358 or the AD622 for this application? Justify your answer.

---

## Appendix: Chip Pinouts

### LM358AN (DIP-8)

```
        ┌─────────┐
 OUT A  │1       8│  V+
  −IN A │2       7│  OUT B
  +IN A │3       6│  −IN B
    V−  │4       5│  +IN B
        └─────────┘
```

### AD622AN (DIP-8)

```
        ┌─────────┐
   RG−  │1       8│  RG+
  −IN   │2       7│  V+
  +IN   │3       6│  OUT
    V−  │4       5│  REF
        └─────────┘
```
