# Background Music and Memory Performance

### A Repeated-Measures Statistical Analysis in R

## Project Overview

Does background music affect memory performance?

This project investigates whether different background music conditions influence performance on a memory-matching task. The experiment involved 30 York University students, each completing a 24-card memory puzzle under three conditions: no music, calm music, and rock music.

Using R, I analyzed the results through exploratory data analysis, a Randomized Complete Block Design (RCBD), model diagnostics, and sensitivity analyses. The goal was to evaluate differences in performance while accounting for individual variability and assessing the reliability of the statistical findings.

## Research Question

Does memory-game performance differ significantly across three background music conditions?

The response variable was defined as:

**Error Rate = Number of Misses / Number of Moves**

Lower error rates indicate better performance on the memory-matching task.

## Dataset

The dataset contains 90 observations from 30 participants, with each participant completing the puzzle under all three music conditions.

The recorded information includes the number of misses and moves for each condition, along with participant characteristics such as age, sex, academic program, music preference, and familiarity with memory games.

The data was validated and transformed into long format for analysis.

## Methodology

The analysis was conducted in four stages:

1. **Data Preparation:** Validated the original dataset, checked for missing and duplicate records, and calculated error rates.
2. **Exploratory Data Analysis:** Examined distributions, descriptive statistics, and within-participant performance patterns.
3. **Statistical Analysis:** Applied RCBD ANOVA, compared it with an unblocked model, and examined model assumptions using residual diagnostics.
4. **Sensitivity Analysis:** Conducted a Friedman test and assessed the stability of the ANOVA conclusion through leave-one-participant-out analysis.

All analyses were performed using R.

## Key Findings

| Analysis | Result |
|---|---|
| RCBD ANOVA | F(2, 58) = 0.524, p = 0.595 |
| Friedman test | χ²(2) = 5.00, p = 0.082 |
| RCBD residual MSE | 0.01433 |
| Unblocked model residual MSE | 0.02647 |
| Reduction in residual MSE | 45.9% |

The results did not provide sufficient statistical evidence of a difference in performance across music conditions at the 5% significance level.

However, accounting for participant-level differences substantially reduced unexplained variation, highlighting the importance of using an appropriate repeated-measures design.

Residual diagnostics revealed departures from normality, motivating the complementary Friedman analysis. Both tests led to the same statistical decision, although they examine different hypotheses.

## Visualizations

The project includes six figures illustrating:

- Error-rate distributions across music conditions.
- Individual participant performance patterns.
- Mean error rates and descriptive 95% confidence intervals.
- Residuals versus fitted values.
- Normal Q-Q plot.
- Residual distributions by music condition.

The figures are available in `outputs/figures/`.

## Repository Structure

```text
Background-music-memory-analysis/
├── data/
│   ├── raw/
│   │   └── music_memory.csv
│   └── processed/
│       └── music_memory_long.csv
├── scripts/
│   ├── 00_run_analysis.R
│   ├── 01_prepare_data.R
│   ├── 02_exploratory_analysis.R
│   ├── 03_statistical_analysis.R
│   └── 04_sensitivity_analysis.R
├── outputs/
│   ├── figures/
│   └── [statistical results and reports]
├── music_memory_research_report.docx
├── DATA_DICTIONARY.md
├── music_memory.Rproj
└── README.md
```

## Reproducing the Analysis

1. Download or clone this repository.
2. Open `music_memory.Rproj` in RStudio.
3. Run the following command from the project root:

```r
source("scripts/00_run_analysis.R")
```

The scripts execute sequentially, from data preparation to sensitivity analysis.

Generated figures and statistical outputs are saved in the `outputs/` directory.

The analysis uses base R.

## Limitations

The study involved a relatively small convenience sample of York University students, limiting generalizability.

Although music-condition order was randomized during data collection, the actual sequence was not retained in the dataset. Potential learning, fatigue, and carryover effects therefore could not be directly assessed.

Additionally, departures from residual normality suggest that the ANOVA findings should be interpreted with caution.

## Research Report

The full research report is available in `music_memory_research_report.docx`. It provides additional details about the experimental design, statistical methodology, diagnostic findings, and interpretation of the results.

## Project Background and Contributions

This analysis builds on a group project completed for MATH 4730 (Experimental Design) at York University in March 2026. The original experimental design, data collection, and initial statistical analysis were completed collaboratively.

For this portfolio project, I independently developed a reproducible R workflow, expanded the exploratory analysis, evaluated model assumptions, conducted additional sensitivity analyses, and refined the presentation and interpretation of the findings.
