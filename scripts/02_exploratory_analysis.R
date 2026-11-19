# Background Music and Memory — Step 2: Exploratory Data Analysis

input <- file.path('data', 'processed', 'music_memory_long.csv')
if (!file.exists(input)) stop('Cannot find ', input, '. Run scripts/01_prepare_data.R first, from the .Rproj project.')
d <- read.csv(input, stringsAsFactors = FALSE)
required <- c('participant_id', 'condition', 'misses', 'moves', 'error_rate')
if (length(setdiff(required, names(d)))) stop('Missing columns: ', paste(setdiff(required, names(d)), collapse=', '))
levels_condition <- c('No music', 'Calm music', 'Rock music')
if (!setequal(unique(d$condition), levels_condition)) stop('Unexpected condition labels; check Step 1 output.')
d$condition <- factor(d$condition, levels = levels_condition)
if (anyNA(d[,required])) stop('Missing data in essential columns.')
if (anyDuplicated(d[c('participant_id','condition')])) stop('Duplicate participant/condition rows.')
if (!all(table(d$participant_id) == 3L)) stop('Each participant must have three observations.')
if (any(d$moves <= 0 | d$misses < 0 | d$misses > d$moves)) stop('Invalid counts.')
if (!isTRUE(all.equal(d$error_rate, d$misses / d$moves, tolerance = 1e-8))) stop('Error rate does not match misses / moves.')

out <- file.path('outputs', 'figures')
dir.create(out, recursive = TRUE, showWarnings = FALSE)

# Descriptive summaries; intervals below use t-based marginal means for description.
# They are NOT paired treatment-comparison confidence intervals.
split_rates <- split(d$error_rate, d$condition, drop = TRUE)
stats <- do.call(rbind, lapply(levels_condition, function(label) {
  x <- split_rates[[label]]; n <- length(x); m <- mean(x); s <- sd(x)
  se <- s / sqrt(n)
  data.frame(condition=label, n=n, mean=m, sd=s, median=median(x),
             min=min(x), max=max(x), ci_lower=m-qt(0.975,n-1)*se,
             ci_upper=m+qt(0.975,n-1)*se)
}))
write.csv(stats, file.path('outputs','eda_summary_by_condition.csv'), row.names=FALSE)

# Figure 1: distribution by condition, with individual points.
png(file.path(out,'01_error_rate_boxplots.png'), width=1400, height=950, res=160)
boxplot(error_rate ~ condition, data=d, col='grey90', border='grey30',
        xlab='Music condition', ylab='Misses / moves', main='Memory-game error rates by condition',
        ylim=c(0,1))
set.seed(4730)
stripchart(error_rate ~ condition, data=d, vertical=TRUE, method='jitter',
           pch=16, col=rgb(0,0,0,0.5), jitter=0.12, add=TRUE)
mtext('Each point represents one participant in one condition', side=1, line=4, cex=0.8)
dev.off()

# Figure 2: connected participant trajectories (descriptive, not causal estimates).
wide <- reshape(d[c('participant_id','condition','error_rate')], idvar='participant_id',
                timevar='condition', direction='wide')
wide <- wide[order(wide$participant_id),]
y <- as.matrix(wide[paste0('error_rate.',levels_condition)])
png(file.path(out,'02_participant_trajectories.png'), width=1400, height=950, res=160)
matplot(1:3, t(y), type='l', lty=1, lwd=1.2, col=rgb(0,0,0,0.2),
        xaxt='n', xlab='Music condition', ylab='Misses / moves',
        main='Within-participant error-rate patterns', ylim=c(0,1))
axis(1, at=1:3, labels=levels_condition)
lines(1:3, stats$mean, type='b', pch=19, lwd=3, col='black')
legend('topleft', legend=c('Individual participants','Condition mean'),
       col=c('grey65','black'), lwd=c(1,3), pch=c(NA,19), bty='n')
dev.off()

# Figure 3: descriptive marginal means with 95% t confidence intervals.
# Repeated observations mean these are not suitable for inference on pairwise differences.
png(file.path(out,'03_condition_means_ci.png'), width=1400, height=950, res=160)
plot(1:3, stats$mean, type='b', pch=19, lwd=2, xaxt='n', xlab='Music condition',
     ylab='Mean misses / moves', main='Mean error rate and descriptive 95% CIs',
     ylim=range(c(0,stats$ci_lower,stats$ci_upper,1)))
axis(1, at=1:3, labels=levels_condition)
arrows(1:3, stats$ci_lower, 1:3, stats$ci_upper, angle=90, code=3, length=0.08)
mtext('Intervals describe each condition mean; paired comparisons require a paired analysis',
      side=1, line=4, cex=0.75)
dev.off()

report <- c('STEP 2 — EXPLORATORY DATA ANALYSIS',
            paste('Participants:', length(unique(d$participant_id))),
            paste('Observations:', nrow(d)),
            '', 'Summary by condition:', capture.output(print(stats, row.names=FALSE)),
            '', 'Notes:',
            '- Lower error rate means fewer misses per move, under the original metric.',
            '- Descriptive differences do not establish a treatment effect.',
            '- Condition-level confidence intervals are descriptive, not paired contrasts.',
            '- Order of treatment administration was not recorded.',
            '- Extreme values are retained; no observations were removed.',
            '- No hypothesis tests or new models were fitted in Step 2.')
writeLines(report, file.path('outputs','eda_report.txt'))
cat(paste(report, collapse='\n'), '\n\nSaved 3 PNG figures to ',out,
    '\nSaved outputs/eda_summary_by_condition.csv and outputs/eda_report.txt\n', sep='')
