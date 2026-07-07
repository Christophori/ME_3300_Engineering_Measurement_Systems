# Prelab 01 Canvas Quiz — Suggested Questions & Answer Key

**Instructor reference — do not distribute.** These map one-to-one to the 🟦 CHECKPOINT boxes in `Lab01_Prelab_Walkthrough.ipynb`. All numeric answers are deterministic: the temperature data is a fixed CSV and the synthetic-data section uses `np.random.seed(3300)`. Suggested Canvas type is noted per question; numeric questions work well as "Numerical Answer" with a small tolerance (e.g., ±0.001) to absorb rounding.

## Checkpoint 1 — Loading data (Section 2)

**Q1.** How many rows of data are in `walkthrough_temperature_data.csv`?
*Type: numerical.* **Answer: 120**

**Q2.** Which object type keeps column *names* from the CSV header?
*Type: multiple choice — (a) NumPy array, (b) pandas DataFrame, (c) both, (d) neither.* **Answer: (b) pandas DataFrame**

**Q3 (optional, concept).** You want to compute statistics on a single column of numbers as fast as possible. Which is the more natural tool? *(a) DataFrame (b) NumPy array.* **Answer: (b)** — typical workflow loads with pandas, then extracts columns with `.values`.

## Checkpoint 2 — Indexing (Section 3)

**Q4.** What is the value of the 50th temperature data point (`temp[49]`)?
*Type: numerical.* **Answer: 20.859**

**Q5.** What is the mean of data points 4 through 8, `np.mean(temp[3:8])`, to 4 decimal places?
*Type: numerical.* **Answer: 21.1292**

## Checkpoint 3 — Statistics (Section 4)

**Q6.** Mean temperature, 4 decimal places. **Answer: 21.2483** (°C)

**Q7.** Sample standard deviation with `ddof=1`, 4 decimal places. **Answer: 0.3487** (°C)
*(Population value with `ddof=0` is 0.3472 — a good distractor for multiple choice.)*

**Q8.** Why do we use `ddof=1` for experimental data?
*Type: short answer / essay.* **Expected:** measurements are a *sample* of the population, not the whole population; dividing by N−1 gives the (unbiased) sample standard deviation, matching the $s_x$ formula from lecture.

## Checkpoint 4 — Curve fit & confidence interval (Section 7)

**Q9.** Slope (spring constant) from `np.polyfit`, 4 decimal places. **Answer: 0.8039** (N/mm)

**Q10.** Standard error of the fit $s_{yx}$, 4 decimal places. **Answer: 0.7081** (N)

**Q11.** t-value for a two-sided 95% CI with ν = 5, 4 decimal places. **Answer: 2.5706**

**Q12.** Which call produces the correct t-value for a 95% confidence interval?
*Type: multiple choice — (a) `stats.t.ppf(0.95, df=nu)`, (b) `stats.t.ppf(0.975, df=nu)`, (c) `stats.t.ppf(0.05, df=nu)`.* **Answer: (b)** — `ppf` takes a cumulative (one-tailed) probability; a two-sided 95% CI leaves 2.5% in each tail, so q = 1 − 0.05/2 = 0.975. *(a) gives 2.0150, only a 90% CI — the classic mistake.*

**Q13.** Standard error of the slope $S_{a_1}$, 5 decimal places. **Answer: 0.02676** (N/mm)

## Checkpoint 5 — Synthetic data & PDFs (Section 8)

**Q14.** Sample mean of the 1000 generated points (seed 3300), 4 decimal places. **Answer: 5.0150**

**Q15.** Sample standard deviation (`ddof=1`), 4 decimal places. **Answer: 1.4906**

**Q16.** What does `density=True` change about a histogram, and why is it needed to compare against a PDF curve?
*Type: short answer.* **Expected:** it normalizes the histogram so total area = 1, turning the y-axis from raw counts into probability density — the same units as the theoretical PDF, so the two can be overlaid.

## Regrading notes

- Q4–Q7 depend only on the fixed CSV; Q9–Q13 depend only on the hard-coded spring data; Q14–Q15 depend on `np.random.seed(3300)` with `np.random.randn(1000)` called immediately after. If a student gets different values for Q14–Q15, they most likely re-ran the cell (advancing the random state) without re-running the seed line — running the cell top-to-bottom fixes it, and that itself is a teachable moment.
