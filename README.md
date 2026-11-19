# Background Music and Memory Performance

**Step 1 — Data preparation**  
Individual portfolio extension of the MATH 4730 (Experimental Design) group project at York University, March 2026.

## Research question
How does background music condition (no music, calm music, rock music) relate to memory-game performance in a repeated-measures experiment involving 30 student participants?

## Run in RStudio
1. Extract the ZIP archive.
2. Open `music_memory.Rproj` in RStudio.
3. Open `scripts/01_prepare_data.R` and click **Source** (or run `source('scripts/01_prepare_data.R')` in the Console).
4. Review `outputs/data_quality_report.txt` and `data/processed/music_memory_long.csv`.

Only base R is needed. The script validates the data and stops with an explanatory error if required fields or measurements are invalid.

## Files
- `data/raw/music_memory.csv` — original, unchanged source dataset
- `scripts/01_prepare_data.R` — validation, reshape, derived error rate, export
- `data/processed/` — generated cleaned long-format CSV
- `outputs/` — generated data quality report
- `DATA_DICTIONARY.md` — variable definitions and coding cautions

## Methodological notes
Each of 30 participants completed all three music conditions, yielding 90 observations. The response variable follows the original project definition: **error rate = misses / moves**. This first stage does **not** fit a statistical model or establish causal effects. Condition order was randomized in the original experiment but is not available in the CSV, so order effects cannot be assessed here.

The original project was completed collaboratively. New analyses and portfolio improvements should be clearly identified as individual extensions, while acknowledging the original group members. Verify that the anonymized participant dataset is permitted to be publicly shared before publishing it on GitHub.
