
# ============================================================
# Background Music and Memory Performance
# Complete Analysis Workflow
# ============================================================

# Run this script from the RStudio project root.
# Each script runs in sequence.

# Step 1: Data preparation and quality checks
source("scripts/01_prepare_data.R")

# Step 2: Exploratory data analysis
source("scripts/02_exploratory_analysis.R")

# Step 3: RCBD ANOVA and model diagnostics
source("scripts/03_statistical_analysis.R")

# Step 4: Friedman sensitivity analysis
source("scripts/04_sensitivity_analysis.R")

# Completion message
cat("\n========================================\n")
cat("All analysis steps completed successfully!\n")
cat("Check the outputs folder for results.\n")
cat("========================================\n")
