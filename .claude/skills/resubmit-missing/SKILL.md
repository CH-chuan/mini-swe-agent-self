---
name: resubmit-missing
description: Generate a resubmission script for missing experiment instances from a tracking report. Use when you need to resubmit failed or timed-out SWE-bench experiments.
argument-hint: <report-path> [--dry-run]
disable-model-invocation: true
allowed-tools: Bash(python *)
---

# Resubmit Missing Instances

Generate `resubmit-missing.sh` from a missing instances report JSON file.

## Arguments

- `$0` - Path to the missing instances report (relative to `exp_track/`, e.g., `260203/missing_instances_report.json`)
- `--dry-run` - Optional flag to add "echo" prefix to generated commands for testing

## Usage Examples

```
/resubmit-missing 260203/missing_instances_report.json
/resubmit-missing 260203/missing_instances_report.json --dry-run
```

## Instructions

Run the resubmit-missing.py script with the provided arguments:

```bash
python exp_track/resubmit-missing.py $ARGUMENTS
```

After running, report to the user:
1. The total number of experiment runs to resubmit
2. A breakdown by model
3. Where the output script was generated
4. If `--dry-run` was used, remind the user to regenerate without it for production

## Output

The script generates `resubmit-missing.sh` in the project root containing `submit-experiment.sh` commands with:
- `--redo-existing` flag to force re-run
- `-t` regex filter targeting only the missing instances
- Dynamic time limits based on missing count (≤10: 30min, ≤25: 1hr, ≤40: 1.5hr, >40: 2hr)
