# Data dictionary

## Original dataset (`data/raw/music_memory.csv`)
| Field | Description |
|---|---|
| `subid` | Participant identifier (numeric code) |
| `music_pref` | Music preference code; original R code uses 0 = non-music lover, 1 = music lover |
| `age` | Age category code; category boundaries not supplied in the uploaded code/report |
| `sex` | Sex code; original R code uses 0 = male, 1 = female |
| `game_familiarity` | Familiarity code; category meanings need confirmation |
| `program` | Academic program as entered, with original spellings preserved |
| `misses.no_music`, `misses.calm`, `misses.rock` | Number of misses in each condition |
| `moves.no_music`, `moves.calm`, `moves.rock` | Number of moves in each condition |

## Processed dataset (`data/processed/music_memory_long.csv`)
One row per participant and condition. `participant_id`, `music_pref`, `age_code`, `sex_code`, `game_familiarity`, and `program` are carried forward from the original data. `condition` labels the treatment; `misses` and `moves` hold the corresponding counts; `error_rate` is `misses / moves`.

**Caution:** The provided files do not fully define the age and familiarity codebooks. Avoid inventing labels. Treatment order was not retained in the provided CSV.
