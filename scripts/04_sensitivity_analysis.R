# Background Music and Memory — Step 4: Friedman sensitivity analysis
# Individual extension of MATH 4730 group project
# Base R only. Open music_memory.Rproj before sourcing.
# This is a complementary rank-based test, not a replacement for RCBD ANOVA.

input <- file.path('data', 'processed', 'music_memory_long.csv')
if (!file.exists(input)) stop('Cannot find ', input, '. Open music_memory.Rproj and run Step 1 first.')
d <- read.csv(input, stringsAsFactors = FALSE)
needed <- c('participant_id', 'condition', 'error_rate')
if (!all(needed %in% names(d))) stop('Required columns missing: ', paste(setdiff(needed, names(d)), collapse=', '))
conditions <- c('No music', 'Calm music', 'Rock music')
if (!setequal(unique(d$condition), conditions)) stop('Unexpected condition labels.')
if (anyNA(d[, needed])) stop('Missing participant ID, condition or error rate.')
if (anyDuplicated(d[c('participant_id', 'condition')])) stop('Duplicate participant-condition records.')
if (any(!is.finite(d$error_rate)) || any(d$error_rate < 0 | d$error_rate > 1)) stop('Invalid error rates.')
ids <- unique(d$participant_id)
if (length(ids) != 30L || nrow(d) != 90L || any(table(d$participant_id) != 3L)) stop('Expected 30 participants and 3 conditions per participant.')
if (!all(vapply(split(d$condition, d$participant_id), function(x) setequal(x, conditions), logical(1)))) stop('Incomplete participant blocks.')

d$condition <- factor(d$condition, levels=conditions)
d$participant_id <- factor(d$participant_id)

# Friedman test accounts for participant blocking by ranking conditions within
# each participant. R handles tied ranks using its standard correction.
fr <- friedman.test(error_rate ~ condition | participant_id, data=d)

# Summarize condition means/medians for context (not the Friedman estimand).
summary_table <- data.frame(
  condition=conditions,
  n=as.integer(table(d$condition)[conditions]),
  mean_error_rate=as.numeric(tapply(d$error_rate, d$condition, mean)[conditions]),
  median_error_rate=as.numeric(tapply(d$error_rate, d$condition, median)[conditions])
)

# Mean within-participant ranks; smaller ranks mean lower error rates.
wide <- matrix(NA_real_, nrow=length(ids), ncol=length(conditions),
               dimnames=list(as.character(ids), conditions))
for (i in seq_len(nrow(d))) {
  wide[as.character(d$participant_id[i]), as.character(d$condition[i])] <- d$error_rate[i]
}
ranks <- t(apply(wide, 1, rank, ties.method='average'))
summary_table$mean_within_participant_rank <- colMeans(ranks)[conditions]

# Kendall's W is a descriptive concordance measure; with ties, the conventional
# chi-square/(n*(k-1)) relationship is an approximation to the untied formula.
n <- nrow(wide); k <- ncol(wide)
W_approx <- as.numeric(fr$statistic)/(n*(k-1))

# RCBD result provided for side-by-side context, not for selecting a test
# based on which yields a smaller p-value.
rcbd <- aov(error_rate ~ condition + participant_id, data=d)
a <- summary(rcbd)[[1]]
rcbd_p <- a['condition', 'Pr(>F)']

if (!dir.exists('outputs')) dir.create('outputs', recursive=TRUE)
write.csv(summary_table, file.path('outputs', 'friedman_condition_summary.csv'), row.names=FALSE)
comparison <- data.frame(
  method=c('RCBD ANOVA (mean differences)', 'Friedman (within-participant ranks)'),
  statistic=c(unname(a['condition','F value']), unname(fr$statistic)),
  df=c(unname(a['condition','Df']), unname(fr$parameter)),
  p_value=c(unname(rcbd_p), unname(fr$p.value))
)
write.csv(comparison, file.path('outputs', 'friedman_vs_rcbd.csv'), row.names=FALSE)

report <- c(
  'STEP 4 — FRIEDMAN SENSITIVITY ANALYSIS',
  sprintf('Participants: %d; conditions: %d; observations: %d', n, k, nrow(d)),
  '', 'Condition summaries (including mean within-participant ranks):',
  capture.output(print(summary_table, row.names=FALSE, digits=5)),
  '', 'Friedman test (tie-adjusted when needed):',
  capture.output(print(fr)),
  sprintf('Approximate Kendall W = %.4f (interpret cautiously with ties)', W_approx),
  '', 'Comparison with primary RCBD ANOVA:',
  capture.output(print(comparison, row.names=FALSE, digits=5)),
  '', 'Interpretation notes:',
  '- Friedman tests whether the conditions differ in within-participant ranks; it is not identical to the RCBD mean-effect test.',
  '- Participants are the independent blocks; each contributes one measurement per condition.',
  '- Friedman does not require normally distributed ANOVA residuals, but does not establish that RCBD assumptions hold.',
  '- The chi-square p-value is an asymptotic approximation and ties are present in some data.',
  '- A non-significant result is not evidence of equivalence or absence of an effect.',
  '- No observations were removed; no post-hoc pairwise tests were conducted.'
)
writeLines(report, file.path('outputs', 'friedman_sensitivity_report.txt'))
cat(paste(report, collapse='\n'), '\n\n')
cat('Saved outputs/friedman_condition_summary.csv, outputs/friedman_vs_rcbd.csv, and outputs/friedman_sensitivity_report.txt\n')
