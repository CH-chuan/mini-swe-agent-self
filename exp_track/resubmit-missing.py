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

    # Group by model -> personality -> round
    by_model = defaultdict(lambda: defaultdict(list))

    for exp_path, data in report.items():
        parts = exp_path.split('/')
        model, instruction, personality, round_tag = parts
        round_num = int(round_tag[1:])

        by_model[model][personality].append({
            'round': round_num,
            'missing_ids': data['missing_ids'],
            'missing_count': data['missing_count']
        })

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
            lines.append(f"# --- {personality} ({len(rounds)} rounds) ---")

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

    with open(OUTPUT_PATH, 'w') as f:
        f.write('\n'.join(lines))

    mode_str = " (DRY RUN)" if args.dry_run else ""
    print(f"Generated {OUTPUT_PATH}{mode_str}")
    print(f"Total experiment runs to resubmit: {len(report)}")

    # Print summary by model
    for model in sorted(by_model.keys()):
        total_rounds = sum(len(rounds) for rounds in by_model[model].values())
        print(f"  {model}: {total_rounds} incomplete runs")


if __name__ == "__main__":
    main()
