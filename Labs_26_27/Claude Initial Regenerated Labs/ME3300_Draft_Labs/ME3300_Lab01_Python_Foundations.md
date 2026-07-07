# ME 3300 — Lab 01: Python Foundations
## Data Analysis and Visualization

**Author:** Dr. Christopher Bitikofer  
**Course:** ME 3300 — Mechanical Measurements  

---

## Learning Objectives

By the end of this lab, you should be able to:

- Set up a Python development environment using VS Code and conda
- Load experimental data from CSV files using `pandas` and `numpy`
- Create and format publication-quality scatter plots and histograms using `matplotlib`
- Compute basic descriptive statistics: mean, median, standard deviation, and variance
- Perform linear regression and compute 95% confidence intervals on the fit
- Generate synthetic normally-distributed data and visualize probability density functions (PDFs)
- Save figures as high-resolution `.pdf` and `.png` files

---

## Check Your Understanding

By the end of this lab, you should be able to answer all of these questions without looking things up.

- How do I create and activate a conda environment in VS Code?
- How do I load a CSV file using `pandas`? How about `numpy`?
- What is the difference between a `pandas` DataFrame and a `numpy` array? When would you use each?
- How do I access the 50th element of a numpy array?
- How do I slice elements 4 through 8 from a 1D array?
- What function saves a matplotlib figure at 600 DPI?
- How do I set figure size in inches in matplotlib?
- How do I set font size and font family for axis labels?
- What numpy function performs polynomial fitting? What does it return?
- What scipy function computes the Student's t-value for confidence intervals?
- What does `np.random.randn(N)` return, and how do you scale it to a desired mean and standard deviation?

---

## Software & Setup

### Required Software

- [VS Code](https://code.visualstudio.com/) with the **Python** and **Pylance** extensions installed
- [Miniconda](https://docs.conda.io/en/latest/miniconda.html) (recommended) or Anaconda

### Step 1 — Create your ME 3300 Python environment

You only need to do this once for the semester. Open the **Anaconda Prompt** (Windows) or **Terminal** (Mac/Linux) and run the following commands:

```bash
conda create -n me3300 python=3.11
conda activate me3300
pip install numpy scipy matplotlib pandas
```

At the start of every future lab session, activate your environment with:

```bash
conda activate me3300
```

> **Why a dedicated environment?** Conda environments keep each project's packages isolated so updates to one project don't break another. It is standard practice in professional engineering and scientific computing.

### Step 2 — Configure VS Code

1. Open VS Code.
2. Press `Ctrl+Shift+P` and type **Python: Select Interpreter**.
3. Choose the interpreter from your `me3300` environment (it will say `me3300` in the name).
4. If prompted, install the **Python** and **Pylance** extensions.

Confirm your setup is working by opening a new terminal in VS Code (`Ctrl+`` `) and running:

```bash
python -c "import numpy, scipy, matplotlib, pandas; print('All good!')"
```

You should see `All good!` printed. If you see an error, ask your TA.

### Step 3 — Set up your folder structure

Use the following folder structure for **every lab this semester**. Consistent organization saves time and prevents the most common student mistake: not knowing where files are.

```
ME3300/
├── Lab_01/
│   ├── Code/
│   │   └── FirstName_LastName_Lab01.py
│   ├── Data/
│   │   └── time_voltage_data.csv
│   └── Figures/
├── Lab_02/
│   ├── Code/
│   ├── Data/
│   └── Figures/
...
```

Create this folder structure now. Download `time_voltage_data.csv` from the Lab 01 Canvas page and place it in your `Data/` folder. Save your script as `FirstName_LastName_Lab01.py` inside `Code/`.

> **A note on hand-typing code:** Example solutions and starter scripts are available on Canvas. You are strongly encouraged to **type the code yourself** rather than copying and pasting — especially early in the semester. Typing forces you to read each line actively, which builds familiarity with Python syntax much faster than reading alone. Once you understand what the code does, you will find it easier to adapt and extend in later labs.

### VS Code Quick Reference

| Action | Shortcut |
|:--|:--|
| Run current file | `F5` or click the ▷ button |
| Run selected lines | `Shift+Enter` |
| Open terminal | `` Ctrl+` `` |
| Command palette | `Ctrl+Shift+P` |
| Comment/uncomment line | `Ctrl+/` |
| Auto-format file | `Shift+Alt+F` |
| Go to definition | `F12` |
| Hover for docs | hover over any function name |

---

## Lab Introduction

This lab has three parts that build on each other.

**Part 1** establishes the core data workflow you will repeat every lab: load data from a file, compute basic statistics, and visualize the data. These skills form the foundation of nearly every experiment this semester.

**Part 2** introduces curve fitting with uncertainty quantification. You will fit a linear model to experimental data and compute a confidence interval on the fit — a tool you will use directly in Labs 2 and 3 for sensor calibration.

**Part 3** connects the statistics from Part 1 and the modeling from Part 2 by working with probability density functions (PDFs). You will generate synthetic data, build normalized histograms, and overlay analytical PDFs. This is the mathematical basis for the uncertainty analysis you will apply in later labs.

---

## Part 1 — Scatter Plot and Histogram from Voltage Data

You will load real voltage data from a CSV file, compute descriptive statistics, and create a scatter plot and histogram.

### Background: CSV Files

Data can be stored in many formats (`.csv`, `.mat`, `.xlsx`, etc.). This course uses **CSV (comma-separated values)** throughout. CSV files store tabular data as plain text with values separated by commas. They are human-readable, easy to inspect in any text editor, and compatible with Python, Excel, and nearly every analysis tool you will encounter in your career.

Before writing any code, open `time_voltage_data.csv` in VS Code or Notepad++ and inspect it directly.

> **Q:** How many columns of data are in the file?  
> **Q:** Does the file include column headers? Do the values below the headers make sense — does time count upward, and is the voltage scale reasonable?

### Instructions

**1. Start your script with standard imports**

These four libraries are the core Python scientific computing stack. You will import them at the top of every script this semester.

```python
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
from scipy import stats
```

**2. Apply consistent figure formatting defaults**

Add these lines after your imports. Setting these once at the top of your script applies them to every figure you create, so you don't have to repeat them.

```python
plt.rcParams['font.family'] = 'serif'
plt.rcParams['font.serif'] = ['Times New Roman']
plt.rcParams['font.size'] = 10
```

**3. Load the data — two methods**

Learn both loading methods. Each has its place.

*Method 1 — using `pandas` (recommended when your file has headers):*

```python
df = pd.read_csv('../Data/time_voltage_data.csv')
time    = df['time'].values     # .values converts the column to a numpy array
voltage = df['voltage'].values
```

*Method 2 — using `numpy` (useful for simple, headerless files):*

```python
data    = np.loadtxt('../Data/time_voltage_data.csv', delimiter=',', skiprows=1)
time    = data[:, 0]    # all rows, column 0
voltage = data[:, 1]    # all rows, column 1
```

> **Q:** What is the key difference between a pandas DataFrame and a numpy array? When would you prefer to use each?

**4. Compute statistics**

```python
v_mean   = np.mean(voltage)
v_median = np.median(voltage)
v_std    = np.std(voltage, ddof=1)   # ddof=1 gives the sample standard deviation
v_var    = np.var(voltage, ddof=1)

print(f"Mean:    {v_mean:.4f} V")
print(f"Median:  {v_median:.4f} V")
print(f"Std Dev: {v_std:.4f} V")
print(f"Variance:{v_var:.4f} V²")
```

Record these values in your lab notebook.

> **Q:** What does `ddof=1` do? What would change if you omitted it and used `ddof=0` instead?

**5. Create the scatter plot**

```python
fig1, ax1 = plt.subplots(figsize=(6.5, 3.5))
fig1.patch.set_facecolor('white')

ax1.scatter(time, voltage, s=25, color='blue', alpha=0.8, zorder=3, label='Data')
ax1.axhline(v_mean,           color='black', linewidth=1.5,
            label=f'Mean = {v_mean:.4f} V')
ax1.axhline(v_mean + v_std,   color='red',   linewidth=1.5, linestyle='--',
            label=f'+1σ = {v_mean + v_std:.4f} V')
ax1.axhline(v_mean - v_std,   color='red',   linewidth=1.5, linestyle='--',
            label=f'−1σ = {v_mean - v_std:.4f} V')

ax1.set_xlabel('Time (s)')
ax1.set_ylabel('Voltage (V)')
ax1.set_title('FirstName LastName — Voltage vs. Time — Date')
ax1.legend(loc='upper right')
ax1.grid(True, which='both', linestyle='--', linewidth=0.5)
ax1.spines['top'].set_visible(False)
ax1.spines['right'].set_visible(False)

plt.tight_layout()
```

**6. Create the histogram**

```python
fig2, ax2 = plt.subplots(figsize=(6.5, 3.5))
fig2.patch.set_facecolor('white')

ax2.hist(voltage, bins=20, color='blue', edgecolor='white')
ax2.set_xlabel('Voltage (V)')
ax2.set_ylabel('Count')
ax2.set_title('FirstName LastName — Voltage Histogram — Date')
ax2.grid(True, which='major', linestyle='--', linewidth=0.5)
ax2.spines['top'].set_visible(False)
ax2.spines['right'].set_visible(False)

plt.tight_layout()
```

**7. Save your figures**

```python
fig1.savefig('../Figures/FirstName_LastName_Lab01_Scatter.pdf', dpi=600, bbox_inches='tight')
fig1.savefig('../Figures/FirstName_LastName_Lab01_Scatter.png', dpi=600, bbox_inches='tight')

fig2.savefig('../Figures/FirstName_LastName_Lab01_Histogram.pdf', dpi=600, bbox_inches='tight')
fig2.savefig('../Figures/FirstName_LastName_Lab01_Histogram.png', dpi=600, bbox_inches='tight')
```

> **Q:** What is the significance of figure DPI? When would you need a higher DPI? When might a lower DPI be acceptable?

### Figure Format Checklist

Use this checklist before submitting your figures. **These requirements apply to every lab this semester** — your TAs will check for them.

- [ ] Figure size: 6.5 in wide × 3.5 in tall
- [ ] White background
- [ ] Font: Times New Roman, 10 pt minimum
- [ ] Major and minor grid lines visible
- [ ] Top and right border (spine) removed
- [ ] Axis labels include units where applicable
- [ ] Title includes your name and today's date
- [ ] Legend does not cover data
- [ ] Data: blue scatter markers, `s=25`, `alpha=0.8`
- [ ] Mean line: black, `linewidth=1.5`
- [ ] ±1σ lines: red dashed, `linewidth=1.5`
- [ ] Histogram: blue fill, 10–40 bins

---

## Part 2 — Linear Curve Fit on Scatter Data

You will fit a linear model to calibration-style data, compute a 95% confidence interval on the fit, and annotate the plot with the fit equation and slope uncertainty.

### Background: Confidence Intervals on a Linear Fit

When we fit a line to data, we need to quantify how much uncertainty there is in that fit. The 95% confidence band around the fitted line is:

$$y_{cl} = y_{fit} \pm t_{\nu,\, 0.95} \cdot s_{yx}$$

where the **standard error of the fit** is:

$$s_{yx} = \sqrt{\frac{\sum_{i=1}^{N}(y_i - y_{c,i})^2}{\nu}}$$

Here $\nu = N - 2$ is the degrees of freedom for a linear fit, $y_{c,i}$ are the values predicted by the fit, and $t_{\nu,\,0.95}$ is the Student's t-value at 95% confidence.

The **standard deviation of the slope** — which tells you how precisely the slope is determined — is:

$$S_{a_1} = s_{yx} \sqrt{\frac{1}{\sum_{i=1}^{N}(x_i - \bar{x})^2}}$$

### Data

Enter the following calibration dataset into your script. This data represents voltage output from a sensor as a function of fluid velocity — the kind of calibration dataset you will generate in Lab 02.

| Velocity (m/s) | Voltage (V) |
|:-:|:-:|
| 0.0 | 0.7036 |
| 1.0 | 1.0096 |
| 2.0 | 1.3907 |
| 3.0 | 1.8867 |
| 4.0 | 2.2557 |
| 5.0 | 2.6313 |
| 6.0 | 2.9504 |

### Instructions

**1. Enter the data as numpy arrays**

```python
velocity = np.array([0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0])
voltage  = np.array([0.7036, 1.0096, 1.3907, 1.8867, 2.2557, 2.6313, 2.9504])
```

**2. Fit a linear model**

`np.polyfit` returns coefficients `[slope, intercept]` for a degree-1 polynomial.  
`np.polyval` evaluates the polynomial at any set of x-values.

```python
coeffs      = np.polyfit(velocity, voltage, 1)   # [slope, intercept]
voltage_fit = np.polyval(coeffs, velocity)
```

**3. Compute the standard error and confidence interval**

```python
N         = len(velocity)
nu        = N - 2                                          # degrees of freedom
residuals = voltage - voltage_fit
s_yx      = np.sqrt(np.sum(residuals**2) / nu)             # standard error of fit

t_val     = stats.t.ppf(0.95, df=nu)                       # t-value at 95% confidence
CI        = t_val * s_yx                                   # half-width of confidence band

# Standard deviation of the slope
S_a1 = s_yx / np.sqrt(np.sum((velocity - np.mean(velocity))**2))
```

**4. Create the plot**

```python
v_range  = np.linspace(velocity.min(), velocity.max(), 200)
fit_line = np.polyval(coeffs, v_range)

fig3, ax3 = plt.subplots(figsize=(6.5, 3.5))
fig3.patch.set_facecolor('white')

ax3.scatter(velocity, voltage, s=75, color='red', zorder=5, label='Data')
ax3.plot(v_range, fit_line,        color='blue',  linewidth=2,   label='Linear fit')
ax3.plot(v_range, fit_line + CI,   color='black', linewidth=1,   linestyle='--', label='95% CI')
ax3.plot(v_range, fit_line - CI,   color='black', linewidth=1,   linestyle='--')

fit_label = (f'$y = {coeffs[0]:.4f}x + {coeffs[1]:.4f}$\n'
             f'$S_{{a_1}} = {S_a1:.4f}$ V/(m/s)\n'
             f'$s_{{yx}} = {s_yx:.4f}$ V')
ax3.text(0.05, 0.95, fit_label, transform=ax3.transAxes,
         fontsize=10, verticalalignment='top',
         bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))

ax3.set_xlabel('Velocity (m/s)')
ax3.set_ylabel('Voltage (V)')
ax3.set_title('FirstName LastName — Velocity vs. Voltage Calibration — Date')
ax3.legend(loc='lower right')
ax3.grid(True, which='both', linestyle='--', linewidth=0.5)
ax3.spines['top'].set_visible(False)
ax3.spines['right'].set_visible(False)

plt.tight_layout()
fig3.savefig('../Figures/FirstName_LastName_Lab01_CurveFit.pdf', dpi=600, bbox_inches='tight')
```

> **Q:** What does $s_{yx}$ tell you about the quality of a fit? What would a larger value mean physically?  
> **Q:** How would you formally report the slope with its uncertainty? Write it out in your notebook using appropriate units and significant figures.

---

## Part 3 — Synthetic Data: Histograms and Probability Density Functions

You will generate synthetic datasets from normal distributions, plot normalized histograms, and overlay analytical PDFs. This exercise builds the statistical intuition behind uncertainty analysis in measurement systems.

### Background: Normal Distribution PDF

The probability density function (PDF) for a normal distribution is:

$$p(x) = \frac{1}{\sigma\sqrt{2\pi}} \exp\!\left[-\frac{1}{2}\left(\frac{x - \mu}{\sigma}\right)^2\right]$$

where $\mu$ is the population mean and $\sigma$ is the population standard deviation.

When we compare a histogram to a PDF, the histogram must be **normalized** so that its total area equals 1 — otherwise the y-axis scales are incompatible. In matplotlib, `density=True` does this automatically.

### Instructions

Generate four datasets (N = 1000 points each) with the following parameters:

| Dataset | Mean ($\mu$) | Std. Dev. ($\sigma$) | Color |
|:-:|:-:|:-:|:-:|
| 1 | −2 | 0.80 | black |
| 2 | 0 | 0.50 | red |
| 3 | 0 | 2.00 | green |
| 4 | 3 | 2.00 | blue |

**1. Define parameters and generate data**

```python
N      = 1000
params = [(-2, 0.80), (0, 0.50), (0, 2.00), (3, 2.00)]
colors = ['black', 'red', 'green', 'blue']

# List comprehension: generates one dataset per (mu, sigma) pair
datasets = [np.random.randn(N) * sigma + mu for mu, sigma in params]
```

> **Hint:** `np.random.randn(N)` generates N samples from a standard normal distribution (mean=0, std=1).  
> Scaling by `sigma` and shifting by `mu` transforms it to the desired distribution.

**2. Define the PDF function**

```python
def normal_pdf(x, mu, sigma):
    """Evaluate the normal distribution PDF at values x."""
    return (1.0 / (sigma * np.sqrt(2 * np.pi))) * np.exp(-0.5 * ((x - mu) / sigma)**2)
```

**3. Build the two-panel figure**

```python
x = np.linspace(-10, 10, 500)

fig4, (ax4_top, ax4_bot) = plt.subplots(2, 1, figsize=(6.5, 7.0), sharex=True)
fig4.patch.set_facecolor('white')

for (mu, sigma), data, color in zip(params, datasets, colors):
    label = f'μ={mu}, σ={sigma}'
    # Top panel: normalized histogram
    ax4_top.hist(data, bins=50, density=True, color=color, alpha=0.5, label=label)
    # Bottom panel: analytical PDF
    ax4_bot.plot(x, normal_pdf(x, mu, sigma), color=color, linewidth=2, label=label)

# Top panel formatting
ax4_top.set_ylabel('Probability Density')
ax4_top.set_title('FirstName LastName — Normalized Histograms — Date')
ax4_top.legend(fontsize=9)
ax4_top.grid(True, linestyle='--', linewidth=0.5)
ax4_top.spines['top'].set_visible(False)
ax4_top.spines['right'].set_visible(False)
ax4_top.set_ylim(bottom=0)

# Bottom panel formatting
ax4_bot.set_xlabel('x')
ax4_bot.set_ylabel('Probability Density')
ax4_bot.set_title('Analytical PDFs')
ax4_bot.legend(fontsize=9)
ax4_bot.grid(True, linestyle='--', linewidth=0.5)
ax4_bot.spines['top'].set_visible(False)
ax4_bot.spines['right'].set_visible(False)
ax4_bot.set_xlim(-10, 10)
ax4_bot.set_ylim(bottom=0)

plt.tight_layout()
fig4.savefig('../Figures/FirstName_LastName_Lab01_PDFs.pdf', dpi=600, bbox_inches='tight')
```

> **Q:** What does `density=True` do in `ax.hist()`? Why is it necessary for comparing the histogram to the analytical PDF?  
> **Q:** What happens to the shape of the PDF when $\sigma$ decreases? When $\mu$ increases?  
> **Q:** Datasets 3 and 4 have the same $\sigma$ but different $\mu$. How do their PDFs differ in your plot? What does this tell you about the role of mean vs. standard deviation in a distribution?

---

## Post-Lab Assignment

Submit the following to the Lab 01 Canvas page by **Monday at 10:00 PM**.

### Files to Submit

- Your completed Python script: `FirstName_LastName_Lab01.py`
- Part 1 — Time vs. Voltage scatter plot (`.pdf`)
- Part 1 — Voltage histogram (`.pdf`)
- Part 2 — Velocity vs. Voltage curve fit plot (`.pdf`)
- Part 3 — PDF figure (`.pdf`)

File naming convention: `FirstName_LastName_Lab01_PartX.pdf`  
All submitted figures must include your name and the date in the title.

### Post-Lab Questions

Answer the following on the Canvas quiz before the deadline.

1. What happens to the shape of a normal distribution PDF when the standard deviation decreases?
2. What happens to the distribution when the mean increases?
3. Report your slope from Part 2 with its uncertainty: $a_1 = \_\_\_ \pm \_\_\_$ V/(m/s). Show how you computed the ± value.
4. What is the 95% confidence interval half-width ($t_{\nu,\,0.95} \cdot s_{yx}$) from your Part 2 fit?
5. In one sentence each: what does $s_{yx}$ tell you, and what does $S_{a_1}$ tell you?

### Before You Leave Lab

Make sure you can answer all of the **Check Your Understanding** questions at the top of this manual before you leave. If you cannot, ask your TA — these concepts are foundational for every lab that follows.

Confirm that your data files are saved to OneDrive and accessible to all team members.

---

## Quick Reference: Matplotlib Formatting

This table summarizes the formatting commands you will use every lab.

| Task | Python command |
|:--|:--|
| Create figure + axes | `fig, ax = plt.subplots(figsize=(6.5, 3.5))` |
| Two-panel figure | `fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(6.5, 7.0), sharex=True)` |
| White background | `fig.patch.set_facecolor('white')` |
| Axis label | `ax.set_xlabel('Label (units)')` |
| Axis label font size | `ax.set_xlabel('Label (units)', fontsize=10)` |
| Title | `ax.set_title('Title', fontsize=10)` |
| Grid on | `ax.grid(True, which='both', linestyle='--', linewidth=0.5)` |
| Remove top/right border | `ax.spines['top'].set_visible(False)` |
| Set axis limits | `ax.set_xlim(0, 10)` / `ax.set_ylim(0, 5)` |
| Legend | `ax.legend(loc='upper right', fontsize=10)` |
| Annotate with text box | `ax.text(0.05, 0.95, 'text', transform=ax.transAxes, verticalalignment='top', bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))` |
| Horizontal reference line | `ax.axhline(y_value, color='black', linewidth=1.5)` |
| Save PDF at 600 DPI | `fig.savefig('name.pdf', dpi=600, bbox_inches='tight')` |
| Save PNG at 600 DPI | `fig.savefig('name.png', dpi=600, bbox_inches='tight')` |

---

## Python Quick Reference: Key Functions This Lab

| Function | What it does |
|:--|:--|
| `pd.read_csv('path/file.csv')` | Load a CSV into a pandas DataFrame |
| `df['column'].values` | Extract a column from a DataFrame as a numpy array |
| `np.loadtxt('path', delimiter=',', skiprows=1)` | Load a CSV directly into a numpy array |
| `np.mean(x)` | Arithmetic mean |
| `np.std(x, ddof=1)` | Sample standard deviation |
| `np.var(x, ddof=1)` | Sample variance |
| `np.polyfit(x, y, 1)` | Linear (degree-1) polynomial fit; returns `[slope, intercept]` |
| `np.polyval(coeffs, x)` | Evaluate polynomial at values x |
| `stats.t.ppf(0.95, df=nu)` | Student's t-value at 95% confidence, ν degrees of freedom |
| `np.random.randn(N)` | N samples from standard normal distribution (μ=0, σ=1) |
| `np.linspace(start, stop, N)` | N evenly spaced values from start to stop |
| `ax.scatter(x, y, s=25, color='blue', alpha=0.8)` | Scatter plot |
| `ax.hist(x, bins=20, density=True)` | Histogram (normalized if `density=True`) |
| `ax.plot(x, y, color='blue', linewidth=2)` | Line plot |
