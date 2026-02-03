#!/bin/bash
# Auto-generated resubmission script
# Source: /home/cche/projects/mini-swe-agent-self/exp_track/260203/missing_instances_report.json

set -euo pipefail

# ==================================================
# devstral-small
# ==================================================

# --- HC-gpt (10 rounds) ---
./submit-experiment.sh -m devstral-small -p HC-gpt \
    -r 2:3 --redo-existing \
    --time-limit 00:30:00 \
    -t '^(sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-gpt \
    -r 3:4 --redo-existing \
    --time-limit 00:30:00 \
    -t '^(sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-gpt \
    -r 8:9 --redo-existing \
    --time-limit 00:30:00 \
    -t '^(sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-gpt \
    -r 10:11 --redo-existing \
    --time-limit 00:30:00 \
    -t '^(sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-gpt \
    -r 11:12 --redo-existing \
    --time-limit 00:30:00 \
    -t '^(sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-gpt \
    -r 13:14 --redo-existing \
    --time-limit 00:30:00 \
    -t '^(sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-gpt \
    -r 16:17 --redo-existing \
    --time-limit 00:30:00 \
    -t '^(sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-gpt \
    -r 17:18 --redo-existing \
    --time-limit 00:30:00 \
    -t '^(sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-gpt \
    -r 18:19 --redo-existing \
    --time-limit 00:30:00 \
    -t '^(sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-gpt \
    -r 20:21 --redo-existing \
    --time-limit 00:30:00 \
    -t '^(sympy__sympy-23534|sympy__sympy-24213)$'

# --- HC-item-120 (15 rounds) ---
./submit-experiment.sh -m devstral-small -p HC-item-120 \
    -r 0:1 --redo-existing \
    --time-limit 00:30:00 \
    -t '^(sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-item-120 \
    -r 1:2 --redo-existing \
    --time-limit 01:30:00 \
    -t '^(django__django-11749|django__django-11951|django__django-12050|django__django-12419|django__django-13516|django__django-13670|django__django-13741|django__django-14493|django__django-14752|django__django-14787|django__django-14855|django__django-15277|django__django-15368|django__django-15380|django__django-15467|django__django-15572|django__django-15741|django__django-15863|django__django-16139|django__django-16493|django__django-16527|django__django-16612|django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-item-120 \
    -r 2:3 --redo-existing \
    --time-limit 01:30:00 \
    -t '^(django__django-11749|django__django-11951|django__django-12050|django__django-12419|django__django-13516|django__django-13670|django__django-13741|django__django-14493|django__django-14752|django__django-14787|django__django-14855|django__django-15277|django__django-15368|django__django-15380|django__django-15467|django__django-15572|django__django-15741|django__django-15863|django__django-16139|django__django-16493|django__django-16527|django__django-16612|django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-item-120 \
    -r 3:4 --redo-existing \
    --time-limit 01:30:00 \
    -t '^(django__django-11749|django__django-11951|django__django-12050|django__django-12419|django__django-13516|django__django-13670|django__django-13741|django__django-14493|django__django-14752|django__django-14787|django__django-14855|django__django-15277|django__django-15368|django__django-15380|django__django-15467|django__django-15572|django__django-15741|django__django-15863|django__django-16139|django__django-16493|django__django-16527|django__django-16612|django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-item-120 \
    -r 5:6 --redo-existing \
    --time-limit 00:30:00 \
    -t '^(sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-item-120 \
    -r 6:7 --redo-existing \
    --time-limit 00:30:00 \
    -t '^(sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-item-120 \
    -r 7:8 --redo-existing \
    --time-limit 01:30:00 \
    -t '^(django__django-11749|django__django-11951|django__django-12050|django__django-12419|django__django-13516|django__django-13670|django__django-13741|django__django-14493|django__django-14752|django__django-14787|django__django-14855|django__django-15277|django__django-15368|django__django-15380|django__django-15467|django__django-15572|django__django-15741|django__django-15863|django__django-16139|django__django-16493|django__django-16527|django__django-16612|django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-item-120 \
    -r 8:9 --redo-existing \
    --time-limit 00:30:00 \
    -t '^(sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-item-120 \
    -r 10:11 --redo-existing \
    --time-limit 01:30:00 \
    -t '^(django__django-11749|django__django-11951|django__django-12050|django__django-12419|django__django-13516|django__django-13670|django__django-13741|django__django-14493|django__django-14752|django__django-14787|django__django-14855|django__django-15277|django__django-15368|django__django-15380|django__django-15467|django__django-15572|django__django-15741|django__django-15863|django__django-16139|django__django-16493|django__django-16527|django__django-16612|django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-item-120 \
    -r 11:12 --redo-existing \
    --time-limit 00:30:00 \
    -t '^(sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-item-120 \
    -r 12:13 --redo-existing \
    --time-limit 01:30:00 \
    -t '^(django__django-11749|django__django-11951|django__django-12050|django__django-12419|django__django-13516|django__django-13670|django__django-13741|django__django-14493|django__django-14752|django__django-14787|django__django-14855|django__django-15277|django__django-15368|django__django-15380|django__django-15467|django__django-15572|django__django-15741|django__django-15863|django__django-16139|django__django-16493|django__django-16527|django__django-16612|django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-item-120 \
    -r 13:14 --redo-existing \
    --time-limit 01:30:00 \
    -t '^(django__django-11749|django__django-11951|django__django-12050|django__django-12419|django__django-13516|django__django-13670|django__django-13741|django__django-14493|django__django-14752|django__django-14787|django__django-14855|django__django-15277|django__django-15368|django__django-15380|django__django-15467|django__django-15572|django__django-15741|django__django-15863|django__django-16139|django__django-16493|django__django-16527|django__django-16612|django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-item-120 \
    -r 17:18 --redo-existing \
    --time-limit 01:30:00 \
    -t '^(django__django-11749|django__django-11951|django__django-12050|django__django-12419|django__django-13516|django__django-13670|django__django-13741|django__django-14493|django__django-14752|django__django-14787|django__django-14855|django__django-15277|django__django-15368|django__django-15380|django__django-15467|django__django-15572|django__django-15741|django__django-15863|django__django-16139|django__django-16493|django__django-16527|django__django-16612|django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-item-120 \
    -r 18:19 --redo-existing \
    --time-limit 01:30:00 \
    -t '^(django__django-11749|django__django-11951|django__django-12050|django__django-12419|django__django-13516|django__django-13670|django__django-13741|django__django-14493|django__django-14752|django__django-14787|django__django-14855|django__django-15277|django__django-15368|django__django-15380|django__django-15467|django__django-15572|django__django-15741|django__django-15863|django__django-16139|django__django-16493|django__django-16527|django__django-16612|django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-item-120 \
    -r 19:20 --redo-existing \
    --time-limit 01:30:00 \
    -t '^(django__django-11749|django__django-11951|django__django-12050|django__django-12419|django__django-13516|django__django-13670|django__django-13741|django__django-14493|django__django-14752|django__django-14787|django__django-14855|django__django-15277|django__django-15368|django__django-15380|django__django-15467|django__django-15572|django__django-15741|django__django-15863|django__django-16139|django__django-16493|django__django-16527|django__django-16612|django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

# --- HC-item-300 (16 rounds) ---
./submit-experiment.sh -m devstral-small -p HC-item-300 \
    -r 0:1 --redo-existing \
    --time-limit 01:30:00 \
    -t '^(django__django-13516|django__django-13670|django__django-13741|django__django-14493|django__django-14752|django__django-14787|django__django-14855|django__django-15277|django__django-15368|django__django-15380|django__django-15467|django__django-15572|django__django-15741|django__django-15863|django__django-16139|django__django-16493|django__django-16527|django__django-16612|django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-item-300 \
    -r 1:2 --redo-existing \
    --time-limit 01:00:00 \
    -t '^(django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-item-300 \
    -r 3:4 --redo-existing \
    --time-limit 01:00:00 \
    -t '^(django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-item-300 \
    -r 4:5 --redo-existing \
    --time-limit 01:00:00 \
    -t '^(django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-item-300 \
    -r 5:6 --redo-existing \
    --time-limit 01:00:00 \
    -t '^(django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-item-300 \
    -r 6:7 --redo-existing \
    --time-limit 01:00:00 \
    -t '^(django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-item-300 \
    -r 7:8 --redo-existing \
    --time-limit 01:00:00 \
    -t '^(django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-item-300 \
    -r 10:11 --redo-existing \
    --time-limit 01:00:00 \
    -t '^(django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-item-300 \
    -r 11:12 --redo-existing \
    --time-limit 01:00:00 \
    -t '^(django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-item-300 \
    -r 12:13 --redo-existing \
    --time-limit 01:00:00 \
    -t '^(django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-item-300 \
    -r 13:14 --redo-existing \
    --time-limit 01:00:00 \
    -t '^(django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-item-300 \
    -r 14:15 --redo-existing \
    --time-limit 01:00:00 \
    -t '^(django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-item-300 \
    -r 15:16 --redo-existing \
    --time-limit 01:30:00 \
    -t '^(django__django-13516|django__django-13670|django__django-13741|django__django-14493|django__django-14752|django__django-14787|django__django-14855|django__django-15277|django__django-15368|django__django-15380|django__django-15467|django__django-15572|django__django-15741|django__django-15863|django__django-16139|django__django-16493|django__django-16527|django__django-16612|django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-item-300 \
    -r 18:19 --redo-existing \
    --time-limit 01:00:00 \
    -t '^(django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-item-300 \
    -r 19:20 --redo-existing \
    --time-limit 01:00:00 \
    -t '^(django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-item-300 \
    -r 20:21 --redo-existing \
    --time-limit 01:30:00 \
    -t '^(django__django-11951|django__django-12050|django__django-12419|django__django-13516|django__django-13670|django__django-13741|django__django-14493|django__django-14752|django__django-14787|django__django-14855|django__django-15277|django__django-15368|django__django-15380|django__django-15467|django__django-15572|django__django-15741|django__django-15863|django__django-16139|django__django-16493|django__django-16527|django__django-16612|django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

# --- HC-p2 (21 rounds) ---
./submit-experiment.sh -m devstral-small -p HC-p2 \
    -r 0:1 --redo-existing \
    --time-limit 01:00:00 \
    -t '^(django__django-15863|django__django-16139|django__django-16493|django__django-16527|django__django-16612|django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-p2 \
    -r 1:2 --redo-existing \
    --time-limit 01:00:00 \
    -t '^(django__django-16612|django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-p2 \
    -r 2:3 --redo-existing \
    --time-limit 01:00:00 \
    -t '^(django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-p2 \
    -r 3:4 --redo-existing \
    --time-limit 01:00:00 \
    -t '^(django__django-15863|django__django-16139|django__django-16493|django__django-16527|django__django-16612|django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-p2 \
    -r 4:5 --redo-existing \
    --time-limit 01:00:00 \
    -t '^(django__django-16493|django__django-16527|django__django-16612|django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-p2 \
    -r 5:6 --redo-existing \
    --time-limit 00:30:00 \
    -t '^(sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-p2 \
    -r 6:7 --redo-existing \
    --time-limit 01:00:00 \
    -t '^(django__django-16493|django__django-16527|django__django-16612|django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-p2 \
    -r 7:8 --redo-existing \
    --time-limit 01:00:00 \
    -t '^(django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-p2 \
    -r 8:9 --redo-existing \
    --time-limit 01:00:00 \
    -t '^(django__django-16493|django__django-16527|django__django-16612|django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-p2 \
    -r 9:10 --redo-existing \
    --time-limit 01:00:00 \
    -t '^(django__django-16139|django__django-16493|django__django-16527|django__django-16612|django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-p2 \
    -r 10:11 --redo-existing \
    --time-limit 01:30:00 \
    -t '^(django__django-15380|django__django-15467|django__django-15572|django__django-15741|django__django-15863|django__django-16139|django__django-16493|django__django-16527|django__django-16612|django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-p2 \
    -r 11:12 --redo-existing \
    --time-limit 01:00:00 \
    -t '^(django__django-15572|django__django-15741|django__django-15863|django__django-16139|django__django-16493|django__django-16527|django__django-16612|django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-p2 \
    -r 12:13 --redo-existing \
    --time-limit 01:00:00 \
    -t '^(django__django-15741|django__django-15863|django__django-16139|django__django-16493|django__django-16527|django__django-16612|django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-p2 \
    -r 13:14 --redo-existing \
    --time-limit 01:30:00 \
    -t '^(django__django-13516|django__django-13670|django__django-13741|django__django-14493|django__django-14752|django__django-14787|django__django-14855|django__django-15277|django__django-15368|django__django-15380|django__django-15467|django__django-15572|django__django-15741|django__django-15863|django__django-16139|django__django-16493|django__django-16527|django__django-16612|django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-p2 \
    -r 14:15 --redo-existing \
    --time-limit 01:00:00 \
    -t '^(django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-p2 \
    -r 15:16 --redo-existing \
    --time-limit 01:30:00 \
    -t '^(django__django-11749|django__django-11951|django__django-12050|django__django-12419|django__django-13516|django__django-13670|django__django-13741|django__django-14493|django__django-14752|django__django-14787|django__django-14855|django__django-15277|django__django-15368|django__django-15380|django__django-15467|django__django-15572|django__django-15741|django__django-15863|django__django-16139|django__django-16493|django__django-16527|django__django-16612|django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-p2 \
    -r 16:17 --redo-existing \
    --time-limit 01:00:00 \
    -t '^(django__django-16139|django__django-16493|django__django-16527|django__django-16612|django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-p2 \
    -r 17:18 --redo-existing \
    --time-limit 01:00:00 \
    -t '^(django__django-15572|django__django-15741|django__django-15863|django__django-16139|django__django-16493|django__django-16527|django__django-16612|django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-p2 \
    -r 18:19 --redo-existing \
    --time-limit 01:00:00 \
    -t '^(django__django-16139|django__django-16493|django__django-16527|django__django-16612|django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-p2 \
    -r 19:20 --redo-existing \
    --time-limit 01:00:00 \
    -t '^(django__django-16493|django__django-16527|django__django-16612|django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-p2 \
    -r 20:21 --redo-existing \
    --time-limit 01:00:00 \
    -t '^(django__django-15863|django__django-16139|django__django-16493|django__django-16527|django__django-16612|django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

# --- HC-p2-modify (5 rounds) ---
./submit-experiment.sh -m devstral-small -p HC-p2-modify \
    -r 2:3 --redo-existing \
    --time-limit 00:30:00 \
    -t '^(sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-p2-modify \
    -r 4:5 --redo-existing \
    --time-limit 00:30:00 \
    -t '^(sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-p2-modify \
    -r 10:11 --redo-existing \
    --time-limit 01:30:00 \
    -t '^(django__django-11749|django__django-11951|django__django-12050|django__django-12419|django__django-13516|django__django-13670|django__django-13741|django__django-14493|django__django-14752|django__django-14787|django__django-14855|django__django-15277|django__django-15368|django__django-15380|django__django-15467|django__django-15572|django__django-15741|django__django-15863|django__django-16139|django__django-16493|django__django-16527|django__django-16612|django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-p2-modify \
    -r 14:15 --redo-existing \
    --time-limit 01:30:00 \
    -t '^(django__django-13516|django__django-13670|django__django-13741|django__django-14493|django__django-14752|django__django-14787|django__django-14855|django__django-15277|django__django-15368|django__django-15380|django__django-15467|django__django-15572|django__django-15741|django__django-15863|django__django-16139|django__django-16493|django__django-16527|django__django-16612|django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p HC-p2-modify \
    -r 20:21 --redo-existing \
    --time-limit 00:30:00 \
    -t '^(sympy__sympy-23534|sympy__sympy-24213)$'

# --- LC-gpt (2 rounds) ---
./submit-experiment.sh -m devstral-small -p LC-gpt \
    -r 8:9 --redo-existing \
    --time-limit 01:30:00 \
    -t '^(django__django-13516|django__django-13670|django__django-13741|django__django-14493|django__django-14752|django__django-14787|django__django-14855|django__django-15277|django__django-15368|django__django-15380|django__django-15467|django__django-15572|django__django-15741|django__django-15863|django__django-16139|django__django-16493|django__django-16527|django__django-16612|django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p LC-gpt \
    -r 12:13 --redo-existing \
    --time-limit 01:30:00 \
    -t '^(django__django-14493|django__django-14752|django__django-14787|django__django-14855|django__django-15277|django__django-15368|django__django-15380|django__django-15467|django__django-15572|django__django-15741|django__django-15863|django__django-16139|django__django-16493|django__django-16527|django__django-16612|django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

# --- LC-item-120 (6 rounds) ---
./submit-experiment.sh -m devstral-small -p LC-item-120 \
    -r 5:6 --redo-existing \
    --time-limit 00:30:00 \
    -t '^(sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p LC-item-120 \
    -r 7:8 --redo-existing \
    --time-limit 00:30:00 \
    -t '^(sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p LC-item-120 \
    -r 8:9 --redo-existing \
    --time-limit 01:00:00 \
    -t '^(matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p LC-item-120 \
    -r 17:18 --redo-existing \
    --time-limit 01:00:00 \
    -t '^(django__django-15741|django__django-15863|django__django-16139|django__django-16493|django__django-16527|django__django-16612|django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p LC-item-120 \
    -r 19:20 --redo-existing \
    --time-limit 00:30:00 \
    -t '^(sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p LC-item-120 \
    -r 20:21 --redo-existing \
    --time-limit 01:00:00 \
    -t '^(matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

# --- LC-item-300 (5 rounds) ---
./submit-experiment.sh -m devstral-small -p LC-item-300 \
    -r 0:1 --redo-existing \
    --time-limit 01:00:00 \
    -t '^(django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p LC-item-300 \
    -r 9:10 --redo-existing \
    --time-limit 01:30:00 \
    -t '^(django__django-13516|django__django-13670|django__django-13741|django__django-14493|django__django-14752|django__django-14787|django__django-14855|django__django-15277|django__django-15368|django__django-15380|django__django-15467|django__django-15572|django__django-15741|django__django-15863|django__django-16139|django__django-16493|django__django-16527|django__django-16612|django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p LC-item-300 \
    -r 10:11 --redo-existing \
    --time-limit 01:30:00 \
    -t '^(django__django-14493|django__django-14752|django__django-14787|django__django-14855|django__django-15277|django__django-15368|django__django-15380|django__django-15467|django__django-15572|django__django-15741|django__django-15863|django__django-16139|django__django-16493|django__django-16527|django__django-16612|django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p LC-item-300 \
    -r 13:14 --redo-existing \
    --time-limit 00:30:00 \
    -t '^(sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p LC-item-300 \
    -r 17:18 --redo-existing \
    --time-limit 00:30:00 \
    -t '^(sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

# --- LC-p2 (4 rounds) ---
./submit-experiment.sh -m devstral-small -p LC-p2 \
    -r 12:13 --redo-existing \
    --time-limit 01:30:00 \
    -t '^(django__django-13516|django__django-13670|django__django-13741|django__django-14493|django__django-14752|django__django-14787|django__django-14855|django__django-15277|django__django-15368|django__django-15380|django__django-15467|django__django-15572|django__django-15741|django__django-15863|django__django-16139|django__django-16493|django__django-16527|django__django-16612|django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p LC-p2 \
    -r 13:14 --redo-existing \
    --time-limit 01:00:00 \
    -t '^(django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p LC-p2 \
    -r 15:16 --redo-existing \
    --time-limit 01:00:00 \
    -t '^(django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p LC-p2 \
    -r 19:20 --redo-existing \
    --time-limit 01:00:00 \
    -t '^(django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

# --- LC-p2-modify (4 rounds) ---
./submit-experiment.sh -m devstral-small -p LC-p2-modify \
    -r 4:5 --redo-existing \
    --time-limit 02:00:00 \
    -t '^(astropy__astropy-14995|django__django-10914|django__django-11133|django__django-11163|django__django-11603|django__django-11749|django__django-11951|django__django-12050|django__django-12419|django__django-13516|django__django-13670|django__django-13741|django__django-14493|django__django-14752|django__django-14787|django__django-14855|django__django-15277|django__django-15368|django__django-15380|django__django-15467|django__django-15572|django__django-15741|django__django-15863|django__django-16139|django__django-16493|django__django-16527|django__django-16612|django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p LC-p2-modify \
    -r 5:6 --redo-existing \
    --time-limit 02:00:00 \
    -t '^(astropy__astropy-14995|django__django-10914|django__django-11133|django__django-11163|django__django-11603|django__django-11749|django__django-11951|django__django-12050|django__django-12419|django__django-13516|django__django-13670|django__django-13741|django__django-14493|django__django-14752|django__django-14787|django__django-14855|django__django-15277|django__django-15368|django__django-15380|django__django-15467|django__django-15572|django__django-15741|django__django-15863|django__django-16139|django__django-16493|django__django-16527|django__django-16612|django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p LC-p2-modify \
    -r 6:7 --redo-existing \
    --time-limit 00:30:00 \
    -t '^(sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p LC-p2-modify \
    -r 18:19 --redo-existing \
    --time-limit 02:00:00 \
    -t '^(astropy__astropy-14995|django__django-10914|django__django-11133|django__django-11163|django__django-11603|django__django-11749|django__django-11951|django__django-12050|django__django-12419|django__django-13516|django__django-13670|django__django-13741|django__django-14493|django__django-14752|django__django-14787|django__django-14855|django__django-15277|django__django-15368|django__django-15380|django__django-15467|django__django-15572|django__django-15741|django__django-15863|django__django-16139|django__django-16493|django__django-16527|django__django-16612|django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

# --- NOP (15 rounds) ---
./submit-experiment.sh -m devstral-small -p NOP \
    -r 1:2 --redo-existing \
    --time-limit 02:00:00 \
    -t '^(django__django-11603|django__django-11749|django__django-11951|django__django-12050|django__django-12419|django__django-13516|django__django-13670|django__django-13741|django__django-14493|django__django-14752|django__django-14787|django__django-14855|django__django-15277|django__django-15368|django__django-15380|django__django-15467|django__django-15572|django__django-15741|django__django-15863|django__django-16139|django__django-16493|django__django-16527|django__django-16612|django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p NOP \
    -r 2:3 --redo-existing \
    --time-limit 01:30:00 \
    -t '^(django__django-14493|django__django-14752|django__django-14787|django__django-14855|django__django-15277|django__django-15368|django__django-15380|django__django-15467|django__django-15572|django__django-15741|django__django-15863|django__django-16139|django__django-16493|django__django-16527|django__django-16612|django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p NOP \
    -r 3:4 --redo-existing \
    --time-limit 02:00:00 \
    -t '^(django__django-11603|django__django-11749|django__django-11951|django__django-12050|django__django-12419|django__django-13516|django__django-13670|django__django-13741|django__django-14493|django__django-14752|django__django-14787|django__django-14855|django__django-15277|django__django-15368|django__django-15380|django__django-15467|django__django-15572|django__django-15741|django__django-15863|django__django-16139|django__django-16493|django__django-16527|django__django-16612|django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p NOP \
    -r 4:5 --redo-existing \
    --time-limit 01:00:00 \
    -t '^(django__django-15741|django__django-15863|django__django-16139|django__django-16493|django__django-16527|django__django-16612|django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p NOP \
    -r 5:6 --redo-existing \
    --time-limit 02:00:00 \
    -t '^(django__django-11603|django__django-11749|django__django-11951|django__django-12050|django__django-12419|django__django-13516|django__django-13670|django__django-13741|django__django-14493|django__django-14752|django__django-14787|django__django-14855|django__django-15277|django__django-15368|django__django-15380|django__django-15467|django__django-15572|django__django-15741|django__django-15863|django__django-16139|django__django-16493|django__django-16527|django__django-16612|django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p NOP \
    -r 6:7 --redo-existing \
    --time-limit 02:00:00 \
    -t '^(django__django-11603|django__django-11749|django__django-11951|django__django-12050|django__django-12419|django__django-13516|django__django-13670|django__django-13741|django__django-14493|django__django-14752|django__django-14787|django__django-14855|django__django-15277|django__django-15368|django__django-15380|django__django-15467|django__django-15572|django__django-15741|django__django-15863|django__django-16139|django__django-16493|django__django-16527|django__django-16612|django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p NOP \
    -r 7:8 --redo-existing \
    --time-limit 01:00:00 \
    -t '^(django__django-15741|django__django-15863|django__django-16139|django__django-16493|django__django-16527|django__django-16612|django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p NOP \
    -r 9:10 --redo-existing \
    --time-limit 02:00:00 \
    -t '^(django__django-11603|django__django-11749|django__django-11951|django__django-12050|django__django-12419|django__django-13516|django__django-13670|django__django-13741|django__django-14493|django__django-14752|django__django-14787|django__django-14855|django__django-15277|django__django-15368|django__django-15380|django__django-15467|django__django-15572|django__django-15741|django__django-15863|django__django-16139|django__django-16493|django__django-16527|django__django-16612|django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p NOP \
    -r 10:11 --redo-existing \
    --time-limit 02:00:00 \
    -t '^(django__django-11603|django__django-11749|django__django-11951|django__django-12050|django__django-12419|django__django-13516|django__django-13670|django__django-13741|django__django-14493|django__django-14752|django__django-14787|django__django-14855|django__django-15277|django__django-15368|django__django-15380|django__django-15467|django__django-15572|django__django-15741|django__django-15863|django__django-16139|django__django-16493|django__django-16527|django__django-16612|django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p NOP \
    -r 13:14 --redo-existing \
    --time-limit 02:00:00 \
    -t '^(django__django-11603|django__django-11749|django__django-11951|django__django-12050|django__django-12419|django__django-13516|django__django-13670|django__django-13741|django__django-14493|django__django-14752|django__django-14787|django__django-14855|django__django-15277|django__django-15368|django__django-15380|django__django-15467|django__django-15572|django__django-15741|django__django-15863|django__django-16139|django__django-16493|django__django-16527|django__django-16612|django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p NOP \
    -r 14:15 --redo-existing \
    --time-limit 01:30:00 \
    -t '^(django__django-11951|django__django-12050|django__django-12419|django__django-13516|django__django-13670|django__django-13741|django__django-14493|django__django-14752|django__django-14787|django__django-14855|django__django-15277|django__django-15368|django__django-15380|django__django-15467|django__django-15572|django__django-15741|django__django-15863|django__django-16139|django__django-16493|django__django-16527|django__django-16612|django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p NOP \
    -r 15:16 --redo-existing \
    --time-limit 02:00:00 \
    -t '^(django__django-11603|django__django-11749|django__django-11951|django__django-12050|django__django-12419|django__django-13516|django__django-13670|django__django-13741|django__django-14493|django__django-14752|django__django-14787|django__django-14855|django__django-15277|django__django-15368|django__django-15380|django__django-15467|django__django-15572|django__django-15741|django__django-15863|django__django-16139|django__django-16493|django__django-16527|django__django-16612|django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p NOP \
    -r 16:17 --redo-existing \
    --time-limit 02:00:00 \
    -t '^(django__django-11603|django__django-11749|django__django-11951|django__django-12050|django__django-12419|django__django-13516|django__django-13670|django__django-13741|django__django-14493|django__django-14752|django__django-14787|django__django-14855|django__django-15277|django__django-15368|django__django-15380|django__django-15467|django__django-15572|django__django-15741|django__django-15863|django__django-16139|django__django-16493|django__django-16527|django__django-16612|django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p NOP \
    -r 17:18 --redo-existing \
    --time-limit 02:00:00 \
    -t '^(django__django-11603|django__django-11749|django__django-11951|django__django-12050|django__django-12419|django__django-13516|django__django-13670|django__django-13741|django__django-14493|django__django-14752|django__django-14787|django__django-14855|django__django-15277|django__django-15368|django__django-15380|django__django-15467|django__django-15572|django__django-15741|django__django-15863|django__django-16139|django__django-16493|django__django-16527|django__django-16612|django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

./submit-experiment.sh -m devstral-small -p NOP \
    -r 19:20 --redo-existing \
    --time-limit 02:00:00 \
    -t '^(django__django-11603|django__django-11749|django__django-11951|django__django-12050|django__django-12419|django__django-13516|django__django-13670|django__django-13741|django__django-14493|django__django-14752|django__django-14787|django__django-14855|django__django-15277|django__django-15368|django__django-15380|django__django-15467|django__django-15572|django__django-15741|django__django-15863|django__django-16139|django__django-16493|django__django-16527|django__django-16612|django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'


# ==================================================
# gptoss-120b
# ==================================================

# --- LC-item-120 (1 rounds) ---
./submit-experiment.sh -m gptoss-120b -p LC-item-120 \
    -r 15:16 --redo-existing \
    --time-limit 01:00:00 \
    -t '^(django__django-16139|django__django-16493|django__django-16527|django__django-16612|django__django-16662|django__django-16901|django__django-17029|django__django-9296|matplotlib__matplotlib-24026|matplotlib__matplotlib-25122|pydata__xarray-4075|pytest-dev__pytest-7205|pytest-dev__pytest-7982|scikit-learn__scikit-learn-10844|scikit-learn__scikit-learn-13439|sphinx-doc__sphinx-9698|sympy__sympy-16450|sympy__sympy-16886|sympy__sympy-20154|sympy__sympy-22456|sympy__sympy-23534|sympy__sympy-24213)$'

