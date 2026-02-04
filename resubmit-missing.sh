#!/bin/bash
# Auto-generated resubmission script
# Source: /home/cche/projects/mini-swe-agent-self/exp_track/262024/missing_instances_report.json

set -euo pipefail

# ==================================================
# devstral-small
# ==================================================

# --- HC-item-300 (1 incomplete rounds) ---
./submit-experiment.sh -m devstral-small -p HC-item-300 \
    -r 14:15 --redo-existing \
    --time-limit 00:30:00 \
    -t '^(sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

# --- HC-p2 (3 incomplete rounds) ---
./submit-experiment.sh -m devstral-small -p HC-p2 \
    -r 0:1 --redo-existing \
    --time-limit 01:00:00 \
    -t '^(django__django-16493|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-p2 \
    -r 4:5 --redo-existing \
    --time-limit 01:00:00 \
    -t '^(django__django-16493|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-p2 \
    -r 15:16 --redo-existing \
    --time-limit 01:00:00 \
    -t '^(django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

# --- HC-p2-modify (1 incomplete rounds) ---
./submit-experiment.sh -m devstral-small -p HC-p2-modify \
    -r 14:15 --redo-existing \
    --time-limit 01:00:00 \
    -t '^(django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

# --- LC-p2-modify (1 incomplete rounds) ---
./submit-experiment.sh -m devstral-small -p LC-p2-modify \
    -r 18:19 --redo-existing \
    --time-limit 01:30:00 \
    -t '^(django__django-13741|django__django-14493|django__django-14752|django__django-14787|django__django-14855|django__django-15277|django__django-15368|django__django-15380|django__django-15467|django__django-15572|django__django-15741|django__django-15863|django__django-16139|django__django-16493|django__django-16527|django__django-16612|django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

# --- NOP (1 incomplete rounds) ---
./submit-experiment.sh -m devstral-small -p NOP \
    -r 1:2 --redo-existing \
    --time-limit 00:30:00 \
    -t '^(django__django-11749)$'


# ==================================================
# COMPLETELY MISSING RUNS (full 60 instances)
# ==================================================

# gptoss-120b

# --- LC-p2 (3 missing rounds) ---
./submit-experiment.sh -m gptoss-120b -p LC-p2 \
    -r 11:12 \
    --time-limit 03:00:00

./submit-experiment.sh -m gptoss-120b -p LC-p2 \
    -r 12:13 \
    --time-limit 03:00:00

./submit-experiment.sh -m gptoss-120b -p LC-p2 \
    -r 14:15 \
    --time-limit 03:00:00

