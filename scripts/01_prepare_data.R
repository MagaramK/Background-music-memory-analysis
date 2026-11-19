# Background Music and Memory — Step 1: Data Preparation
# Base R only; no package installation required.

input_path <- file.path('data', 'raw', 'music_memory.csv')
output_path <- file.path('data', 'processed', 'music_memory_long.csv')
report_path <- file.path('outputs', 'data_quality_report.txt')
if (!file.exists(input_path)) stop('Missing file: ', input_path, '\nOpen the .Rproj file first.')
raw <- read.csv(input_path, stringsAsFactors = FALSE, check.names = TRUE)

expected <- c('subid', 'music_pref', 'age', 'sex', 'game_familiarity', 'program',
              'misses.no_music', 'moves.no_music', 'misses.calm', 'moves.calm',
              'misses.rock', 'moves.rock')
missing_cols <- setdiff(expected, names(raw))
if (length(missing_cols)) stop('Missing expected columns: ', paste(missing_cols, collapse = ', '))
if (anyNA(raw)) stop('Missing values detected. Inspect raw data before proceeding.')
if (anyDuplicated(raw$subid)) stop('Duplicate participant IDs detected.')
if (anyNA(raw$subid)) stop('Missing participant IDs detected.')

conditions <- c('no_music', 'calm', 'rock')
for (condition in conditions) {
  misses <- raw[[paste0('misses.', condition)]]
  moves <- raw[[paste0('moves.', condition)]]
  if (!is.numeric(misses) || !is.numeric(moves)) stop('Non-numeric misses/moves: ', condition)
  if (any(!is.finite(misses)) || any(!is.finite(moves))) stop('Non-finite counts: ', condition)
  if (any(moves <= 0) || any(misses < 0) || any(misses > moves)) stop('Invalid counts: ', condition)
  if (any(moves != floor(moves)) || any(misses != floor(misses))) stop('Non-integer counts: ', condition)
}

long <- do.call(rbind, lapply(conditions, function(condition) {
  data.frame(
    participant_id = raw$subid,
    music_pref = raw$music_pref,
    age_code = raw$age,
    sex_code = raw$sex,
    game_familiarity = raw$game_familiarity,
    program = raw$program,
    condition = condition,
    misses = raw[[paste0('misses.', condition)]],
    moves = raw[[paste0('moves.', condition)]],
    stringsAsFactors = FALSE
  )
}))
long$error_rate <- long$misses / long$moves
long$condition <- factor(long$condition, levels = conditions,
                         labels = c('No music', 'Calm music', 'Rock music'))
long <- long[order(long$participant_id, long$condition), ]
row.names(long) <- NULL

if (nrow(long) != 3L * nrow(raw)) stop('Unexpected observation count.')
if (!all(table(long$participant_id) == 3L)) stop('Each participant must have three conditions.')
if (!all(table(long$condition) == nrow(raw))) stop('Unbalanced condition counts.')
if (any(long$error_rate < 0 | long$error_rate > 1)) stop('Error rate outside [0,1].')

# Note: program labels are left as recorded, including spelling differences.
# No participant-identifying names are included in the exported dataset.
dir.create(dirname(output_path), recursive = TRUE, showWarnings = FALSE)
dir.create(dirname(report_path), recursive = TRUE, showWarnings = FALSE)
write.csv(long, output_path, row.names = FALSE)

summary_by_condition <- aggregate(error_rate ~ condition, data = long,
                                  FUN = function(x) c(mean = mean(x), sd = sd(x)))
report <- c(
  'STEP 1 — DATA QUALITY REPORT',
  paste('Participants:', nrow(raw)),
  paste('Original columns:', ncol(raw)),
  paste('Long-format observations:', nrow(long)),
  paste('Missing cells in original:', sum(is.na(raw))),
  paste('Duplicate participant IDs:', sum(duplicated(raw$subid))),
  paste('Error rate range:', paste(round(range(long$error_rate), 4), collapse = ' to ')),
  '', 'Summary by music condition:', capture.output(print(summary_by_condition)),
  '', 'Program values as recorded:', capture.output(print(table(raw$program))),
  '', 'Note: Age/sex/music preference/familiarity codes are preserved, not reinterpreted.',
  'Note: Randomized treatment order is not recorded in this dataset.'
)
writeLines(report, report_path)
cat(paste(report, collapse = '\n'), '\n')
cat('\nSaved:', output_path, '\nSaved:', report_path, '\n')
