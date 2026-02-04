#!/usr/bin/env python3
"""Generate resubmit-missing.sh from missing_instances_report.json"""

import argparse
import json
from collections import defaultdict
from pathlib import Path

# Script lives in exp_track/, output goes to project root
SCRIPT_DIR = Path(__file__).parent.resolve()
PROJECT_ROOT = SCRIPT_DIR.parent
OUTPUT_PATH = PROJECT_ROOT / "resubmit-missing.sh"


def get_time_limit(missing_count: int) -> str:
    """Calculate SLURM time limit based on number of missing instances."""
    if missing_count <= 10:
        return "00:30:00"  # 30 min
    elif missing_count <= 25:
        return "01:00:00"  # 1 hr
    elif missing_count <= 40:
        return "01:30:00"  # 1.5 hr
    else:
        return "02:00:00"  # 2 hr


def main():
    parser = argparse.ArgumentParser(description="Generate resubmission script for missing experiment instances")
    parser.add_argument("report_path", type=Path, help="Path to missing_instances_report.json (e.g., 260203/missing_instances_report.json)")
    parser.add_argument("--dry-run", action="store_true", help="Add 'echo' prefix to commands for testing")
    args = parser.parse_args()

    report_path = args.report_path
    # If relative path, resolve relative to script directory (exp_track/)
    if not report_path.is_absolute():
        report_path = SCRIPT_DIR / report_path
    if not report_path.exists():
        print(f"Error: Report file not found: {report_path}")
        return 1

    with open(report_path) as f:
        report = json.load(f)

    # Handle both old format (entries at root) and new format (incomplete_runs + missing_runs)
    if 'incomplete_runs' in report:
        incomplete_runs = report['incomplete_runs']
        missing_runs = report.get('missing_runs', {})
    else:
        # Backward compatibility: treat root as incomplete runs
        incomplete_runs = report
        missing_runs = {}

    # Group incomplete runs by model -> personality -> round
    by_model = defaultdict(lambda: defaultdict(list))

    for exp_path, data in incomplete_runs.items():
        parts = exp_path.split('/')
        model, instruction, personality, round_tag = parts
        round_num = int(round_tag[1:])

        by_model[model][personality].append({
            'round': round_num,
            'missing_ids': data['missing_ids'],
            'missing_count': data['missing_count']
        })

    # Group missing runs by model -> personality -> list of rounds
    missing_by_model = defaultdict(lambda: defaultdict(list))

    for exp_path, rounds in missing_runs.items():
        parts = exp_path.split('/')
        model, instruction, personality = parts
        for round_tag in rounds:
            round_num = int(round_tag[1:])
            missing_by_model[model][personality].append(round_num)

    # Prefix for dry-run mode
    cmd_prefix = "echo " if args.dry_run else ""

    # Generate shell script
    lines = [
        "#!/bin/bash",
        "# Auto-generated resubmission script",
        f"# Source: {report_path}",
    ]
    if args.dry_run:
        lines.append("# DRY RUN MODE - commands are echoed, not executed")
    lines.extend([
        "",
        "set -euo pipefail",
        ""
    ])

    for model in sorted(by_model.keys()):
        lines.append(f"# {'='*50}")
        lines.append(f"# {model}")
        lines.append(f"# {'='*50}")
        lines.append("")

        for personality in sorted(by_model[model].keys()):
            rounds = by_model[model][personality]
            lines.append(f"# --- {personality} ({len(rounds)} incomplete rounds) ---")

            for r in sorted(rounds, key=lambda x: x['round']):
                # Create regex filter from missing IDs
                filter_regex = '^(' + '|'.join(r['missing_ids']) + ')$'
                time_limit = get_time_limit(r['missing_count'])

                lines.append(f"{cmd_prefix}./submit-experiment.sh -m {model} -p {personality} \\")
                lines.append(f"    -r {r['round']}:{r['round']+1} --redo-existing \\")
                lines.append(f"    --time-limit {time_limit} \\")
                lines.append(f"    -t '{filter_regex}'")
                lines.append("")

        lines.append("")

    # Generate commands for completely missing runs
    if missing_by_model:
        lines.append(f"# {'='*50}")
        lines.append("# COMPLETELY MISSING RUNS (full 60 instances)")
        lines.append(f"# {'='*50}")
        lines.append("")

        for model in sorted(missing_by_model.keys()):
            lines.append(f"# {model}")
            lines.append("")

            for personality in sorted(missing_by_model[model].keys()):
                rounds = sorted(missing_by_model[model][personality])
                lines.append(f"# --- {personality} ({len(rounds)} missing rounds) ---")

                for round_num in rounds:
                    lines.append(f"{cmd_prefix}./submit-experiment.sh -m {model} -p {personality} \\")
                    lines.append(f"    -r {round_num}:{round_num+1} \\")
                    lines.append(f"    --time-limit 03:00:00")
                    lines.append("")

            lines.append("")

    with open(OUTPUT_PATH, 'w') as f:
        f.write('\n'.join(lines))

    mode_str = " (DRY RUN)" if args.dry_run else ""
    print(f"Generated {OUTPUT_PATH}{mode_str}")

    total_incomplete = sum(
        len(rounds)
        for personalities in by_model.values()
        for rounds in personalities.values()
    )
    total_missing = sum(
        len(rounds)
        for personalities in missing_by_model.values()
        for rounds in personalities.values()
    )

    print(f"Total experiment runs to resubmit: {total_incomplete + total_missing}")
    print(f"  Incomplete runs (partial instances): {total_incomplete}")
    print(f"  Missing runs (full 60 instances): {total_missing}")

    # Print summary by model
    all_models = sorted(set(by_model.keys()) | set(missing_by_model.keys()))
    for model in all_models:
        incomplete_count = sum(len(rounds) for rounds in by_model.get(model, {}).values())
        missing_count = sum(len(rounds) for rounds in missing_by_model.get(model, {}).values())
        parts = []
        if incomplete_count:
            parts.append(f"{incomplete_count} incomplete")
        if missing_count:
            parts.append(f"{missing_count} missing")
        print(f"  {model}: {', '.join(parts)}")


if __name__ == "__main__":
    main()
