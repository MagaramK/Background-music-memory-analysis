# Background Music and Memory — Step 3: RCBD ANOVA and model diagnostics
# Individual extension of MATH 4730 group project
# Base R only. Open music_memory.Rproj before sourcing this file.
# No data are excluded and no mixed-effects model is fitted.

input <- file.path('data', 'processed', 'music_memory_long.csv')
if (!file.exists(input)) stop('Missing ', input, '. Run Step 1 first and open the .Rproj file.')
d <- read.csv(input, stringsAsFactors = FALSE)
required <- c('participant_id', 'condition', 'misses', 'moves', 'error_rate')
if (length(setdiff(required, names(d))) > 0) stop('Missing required columns: ', paste(setdiff(required, names(d)), collapse=', '))
conditions <- c('No music', 'Calm music', 'Rock music')
if (!setequal(unique(d$condition), conditions)) stop('Unexpected music condition labels.')
if (anyNA(d[, required])) stop('Missing required data.')
if (anyDuplicated(d[c('participant_id', 'condition')])) stop('Duplicate participant-condition combination.')
if (length(unique(d$participant_id)) != 30L || nrow(d) != 90L || !all(table(d$participant_id) == 3L)) stop('Expected 30 participants, each measured in three conditions.')
if (any(d$moves <= 0 | d$misses < 0 | d$misses > d$moves)) stop('Invalid misses or moves.')
if (!isTRUE(all.equal(d$error_rate, d$misses/d$moves, tolerance=1e-8))) stop('Error rate differs from misses / moves.')

d$condition <- factor(d$condition, levels=conditions)
d$participant_id <- factor(d$participant_id)
dir.create(file.path('outputs', 'figures'), recursive=TRUE, showWarnings=FALSE)

# RCBD: participant as fixed blocking factor, following the original course analysis.
rcbd <- aov(error_rate ~ condition + participant_id, data=d)
# CRD is an illustrative comparison only: it ignores within-participant dependence,
# so its treatment p-value is NOT a valid alternative test for this repeated-measures experiment.
crd <- aov(error_rate ~ condition, data=d)
rcbd_tab <- summary(rcbd)[[1]]
crd_tab <- summary(crd)[[1]]
comparison <- data.frame(
  model=c('RCBD (participant blocking)', 'CRD (ignores repeated measures)'),
  residual_df=c(df.residual(rcbd), df.residual(crd)),
  residual_MSE=c(deviance(rcbd)/df.residual(rcbd), deviance(crd)/df.residual(crd)),
  treatment_F=c(rcbd_tab['condition','F value'], crd_tab['condition','F value']),
  treatment_p=c(rcbd_tab['condition','Pr(>F)'], crd_tab['condition','Pr(>F)'])
)
write.csv(comparison, file.path('outputs','model_comparison.csv'), row.names=FALSE)

# Residual diagnostics: visuals are primary; tests cannot prove assumptions.
res <- residuals(rcbd)
fit <- fitted(rcbd)
std_res <- rstandard(rcbd)
# Shapiro-Wilk is supplemental; observations/residuals are structured, and the
# test alone should not determine whether the ANOVA is appropriate.
shapiro <- shapiro.test(res)

png(file.path('outputs','figures','04_residuals_vs_fitted.png'), width=1400, height=950, res=160)
plot(fit, res, pch=16, col=rgb(0,0,0,0.45), xlab='Fitted error rate', ylab='Residual',
     main='RCBD diagnostics: residuals vs fitted values')
abline(h=0, lty=2, lwd=2)
lines(lowess(fit, res), col='steelblue4', lwd=2)
dev.off()

png(file.path('outputs','figures','05_normal_qq.png'), width=1400, height=950, res=160)
qqnorm(res, pch=16, col=rgb(0,0,0,0.55), main='RCBD diagnostics: normal Q-Q plot')
qqline(res, col='steelblue4', lwd=2)
dev.off()

png(file.path('outputs','figures','06_residuals_by_condition.png'), width=1400, height=950, res=160)
boxplot(res ~ d$condition, col='grey90', border='grey35', xlab='Music condition',
        ylab='RCBD residual', main='RCBD diagnostics: residuals by condition')
abline(h=0, lty=2)
set.seed(4730)
stripchart(res ~ d$condition, vertical=TRUE, method='jitter', jitter=0.10,
           pch=16, col=rgb(0,0,0,0.4), add=TRUE)
dev.off()

# Flag potentially unusual observations for REVIEW only, not automatic removal.
flags <- data.frame(participant_id=as.character(d$participant_id),
                    condition=as.character(d$condition), error_rate=d$error_rate,
                    fitted=fit, residual=res, standardized_residual=std_res)
flags <- flags[abs(flags$standardized_residual) > 2, , drop=FALSE]
write.csv(flags, file.path('outputs','observations_to_review.csv'), row.names=FALSE)

# Sensitivity: re-fit RCBD after omitting each WHOLE participant in turn.
# This is a descriptive stability check, not a new confirmatory hypothesis test.
ids <- levels(d$participant_id)
loo <- do.call(rbind, lapply(ids, function(id) {
  m <- aov(error_rate ~ condition + participant_id, data=d[d$participant_id != id, , drop=FALSE])
  a <- summary(m)[[1]]
  data.frame(omitted_participant=id,
             treatment_F=a['condition','F value'], treatment_p=a['condition','Pr(>F)'],
             residual_MSE=deviance(m)/df.residual(m))
}))
write.csv(loo, file.path('outputs','leave_one_participant_out.csv'), row.names=FALSE)

# Participant-paired contrasts with 95% t intervals are descriptive/exploratory.
# No multiple-testing adjusted claims are made in this step.
wide <- reshape(data.frame(participant_id=as.character(d$participant_id),
                           condition=as.character(d$condition), error_rate=d$error_rate),
                idvar='participant_id', timevar='condition', direction='wide')
pairs <- combn(conditions, 2, simplify=FALSE)
paired <- do.call(rbind, lapply(pairs, function(pair) {
  diff <- wide[[paste0('error_rate.',pair[2])]] - wide[[paste0('error_rate.',pair[1])]]
  ci <- mean(diff) + c(-1,1)*qt(0.975,length(diff)-1)*sd(diff)/sqrt(length(diff))
  data.frame(condition_B=pair[2], condition_A=pair[1],
             mean_difference_B_minus_A=mean(diff), ci_lower=ci[1], ci_upper=ci[2])
}))
write.csv(paired, file.path('outputs','exploratory_paired_differences.csv'), row.names=FALSE)

report <- c(
  'STEP 3 — RCBD ANOVA AND MODEL DIAGNOSTICS',
  'Original course analysis reproduced using the Step 1 cleaned data.',
  'Primary model: error_rate ~ condition + participant_id',
  '', 'RCBD ANOVA:', capture.output(print(summary(rcbd))),
  '', 'CRD ANOVA (comparison only; ignores repeated-measures dependence):', capture.output(print(summary(crd))),
  '', 'Model comparison:', capture.output(print(comparison, row.names=FALSE)),
  '', paste('Reduction in residual MSE with blocking:',
           sprintf('%.1f%%', 100*(1-comparison$residual_MSE[1]/comparison$residual_MSE[2]))),
  '', paste('Shapiro-Wilk residual p-value (supplementary only):', signif(shapiro$p.value,4)),
  paste('Number of observations flagged for review (|standardized residual| > 2):',nrow(flags)),
  '', 'Leave-one-participant-out treatment p-value range:',
  paste(signif(range(loo$treatment_p),4), collapse=' to '),
  '', 'Exploratory participant-paired differences (B minus A; unadjusted 95% intervals):',
  capture.output(print(paired, row.names=FALSE)),
  '', 'INTERPRETATION CAUTIONS:',
  '- RCBD is the primary analysis; CRD ignores participant pairing and is shown only to illustrate residual variation.',
  '- Residual plots assess approximate normality and spread; neither a plot nor a test proves assumptions.',
  '- With one observation per participant-condition cell, participant-by-condition interaction cannot be separately estimated from residual error.',
  '- Randomized order was not recorded; learning, fatigue and carryover cannot be directly evaluated.',
  '- Error rate is bounded between 0 and 1; examine the impact of extremes and non-normal tails.',
  '- Participant-paired intervals are exploratory, unadjusted for multiple comparisons.',
  '- No observations were deleted and no mixed-effects model was fitted.'
)
writeLines(report, file.path('outputs','statistical_analysis_report.txt'))
cat(paste(report, collapse='\n'), '\n\nSaved diagnostic PNGs and CSVs in outputs/.\n')
