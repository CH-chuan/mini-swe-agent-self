#!/bin/bash
# Submit personality survey jobs for completed experiments
# Usage: ./submit-personality-survey.sh -m MODEL -p PERSONALITY -r ROUNDS
#
# This script runs personality surveys on experiment results from submit-experiment.sh

set -euo pipefail

# =============================================================================
# Script paths
# =============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODELS_CONF_DIR="${SCRIPT_DIR}/exp_configs/models"
SLURM_SCRIPT="${SCRIPT_DIR}/personality_survey.slurm"

# =============================================================================
# Default values
# =============================================================================
MODEL="qwen3coder-30b"
PERSONALITY=""  # Empty means all personalities
INSTRUCTION="submit-in-rules"
ROUNDS="0:5"
INPUT_BASE=""   # Will be derived from experiments/{MODEL}/{INSTRUCTION}
OUTPUT_BASE=""  # Will be derived from personality_survey_results/{MODEL}/{INSTRUCTION}

# Inventory paths
INVENTORY_120="${SCRIPT_DIR}/personality_survey/inventories/mpi_120.csv"
INVENTORY_300="${SCRIPT_DIR}/personality_survey/inventories/mpi_300.csv"
ITEM_TEMPLATE="${SCRIPT_DIR}/personality_survey/item_template.txt"
INVENTORY_PATH="$INVENTORY_120"

# Survey configuration
RESUME="true"
DIMENSIONS="OCEAN"
MAX_WORKERS="4"

# All available personalities (hyphen-based naming)
ALL_PERSONALITIES=(
    "NOP"
    "HC-gpt"
    "LC-gpt"
    "HC-p2"
    "LC-p2"
    "HC-p2-modify"
    "LC-p2-modify"
    "HC-item-120"
    "LC-item-120"
    "HC-item-300"
    "LC-item-300"
)

# =============================================================================
# Help / Usage
# =============================================================================
usage() {
    cat <<EOF
Usage: $0 [OPTIONS]

Submit personality survey jobs for completed experiments.

OPTIONS:
  -m, --model NAME          Model config name (default: qwen3coder-30b)
  -p, --personality NAME    Personality to survey (default: all personalities)
                            Use NOP for baseline (no personality prompt)
  -i, --instruction NAME    Instruction template used in experiment (default: submit-in-rules)
  -r, --rounds RANGE        Round range START:END (default: 0:5)
  --input-base DIR          Override input base directory
                            (default: experiments/{MODEL}/{INSTRUCTION})
  --output-base DIR         Override output base directory
                            (default: personality_survey_results/{MODEL}/{INSTRUCTION})
  --inventory FILE          Inventory file path (default: mpi_120.csv)
  --no-resume               Don't resume from existing results
  --dry-run                 Show what would be submitted without submitting
  --list-personalities      List available personalities
  -h, --help                Show this help message

EXAMPLES:
  # Survey all personalities for gptoss-120b experiments
  $0 -m gptoss-120b -r 0:21

  # Survey specific personality
  $0 -m devstral-small -p HC-gpt -r 0:21

  # Use 300-item inventory
  $0 -m qwen3coder-30b --inventory personality_survey/inventories/mpi_300.csv

  # Dry run to preview
  $0 -m gptoss-120b --dry-run

EOF
    exit 0
}

list_personalities() {
    echo "Available personalities:"
    for p in "${ALL_PERSONALITIES[@]}"; do
        echo "  $p"
    done
    exit 0
}

# =============================================================================
# Parse command line arguments
# =============================================================================
DRY_RUN=false
SELECTED_PERSONALITIES=()

while [[ $# -gt 0 ]]; do
    case $1 in
        -m|--model)
            MODEL="$2"
            shift 2
            ;;
        -p|--personality)
            SELECTED_PERSONALITIES+=("$2")
            shift 2
            ;;
        -i|--instruction)
            INSTRUCTION="$2"
            shift 2
            ;;
        -r|--rounds)
            ROUNDS="$2"
            shift 2
            ;;
        --input-base)
            INPUT_BASE="$2"
            shift 2
            ;;
        --output-base)
            OUTPUT_BASE="$2"
            shift 2
            ;;
        --inventory)
            INVENTORY_PATH="$2"
            shift 2
            ;;
        --no-resume)
            RESUME="false"
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --list-personalities)
            list_personalities
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "ERROR: Unknown option: $1"
            echo "Use -h or --help for usage information."
            exit 1
            ;;
    esac
done

# If no personalities specified, use all
if [[ ${#SELECTED_PERSONALITIES[@]} -eq 0 ]]; then
    SELECTED_PERSONALITIES=("${ALL_PERSONALITIES[@]}")
fi

# =============================================================================
# Validate and load model configuration
# =============================================================================
MODEL_CONF="${MODELS_CONF_DIR}/${MODEL}.conf"
if [[ ! -f "$MODEL_CONF" ]]; then
    echo "ERROR: Model config not found: $MODEL_CONF"
    echo "Available models:"
    ls -1 "${MODELS_CONF_DIR}"/*.conf 2>/dev/null | xargs -n1 basename | sed 's/\.conf$//' | sed 's/^/  /' || echo "  (none found)"
    exit 1
fi

# Source model config
source "$MODEL_CONF"

# =============================================================================
# Set input/output directories
# =============================================================================
# Input: experiments/{MODEL}/{INSTRUCTION}/{PERSONALITY}/{round}
# Output: personality_survey_results/{MODEL}/{INSTRUCTION}/{PERSONALITY}/{round}

if [[ -z "$INPUT_BASE" ]]; then
    INPUT_BASE="experiments/${MODEL}/${INSTRUCTION}"
fi

if [[ -z "$OUTPUT_BASE" ]]; then
    OUTPUT_BASE="personality_survey_results/${MODEL}/${INSTRUCTION}"
fi

# =============================================================================
# Parse and validate rounds
# =============================================================================
IFS=":" read -r ROUND_START ROUND_END <<< "${ROUNDS}"

if ! [[ "$ROUND_START" =~ ^[0-9]+$ ]] || ! [[ "$ROUND_END" =~ ^[0-9]+$ ]]; then
    echo "ERROR: Invalid round range format. Expected START:END (e.g., 0:5)"
    exit 1
fi

if (( ROUND_END <= ROUND_START )); then
    echo "ERROR: ROUND_END ($ROUND_END) must be greater than ROUND_START ($ROUND_START)"
    exit 1
fi

TOTAL_ROUNDS=$((ROUND_END - ROUND_START))

# =============================================================================
# Display configuration summary
# =============================================================================
echo "=============================================="
echo "Personality Survey Configuration"
echo "=============================================="
echo "Model:          $MODEL"
echo "  Model Name:   $MODEL_NAME"
echo "  Served Name:  $SERVED_MODEL_NAME"
echo "Instruction:    $INSTRUCTION"
echo "Personalities:  ${SELECTED_PERSONALITIES[*]}"
echo "Rounds:         r$(printf '%02d' $ROUND_START) - r$(printf '%02d' $((ROUND_END-1))) ($TOTAL_ROUNDS rounds)"
echo "Input Base:     $INPUT_BASE"
echo "Output Base:    $OUTPUT_BASE"
echo "Inventory:      $INVENTORY_PATH"
echo "Resume:         $RESUME"
echo "=============================================="
echo ""

# =============================================================================
# Dry run mode
# =============================================================================
if [[ "$DRY_RUN" == "true" ]]; then
    echo "[DRY RUN MODE]"
    echo ""
    echo "Would submit jobs for:"
    for PERSONALITY in "${SELECTED_PERSONALITIES[@]}"; do
        for (( ROUND=ROUND_START; ROUND<ROUND_END; ROUND++ )); do
            ROUND_TAG=$(printf "r%02d" "${ROUND}")
            INPUT_DIR="${INPUT_BASE}/${PERSONALITY}/${ROUND_TAG}"
            OUTPUT_DIR="${OUTPUT_BASE}/${PERSONALITY}/${ROUND_TAG}"

            if [[ -d "$INPUT_DIR" ]]; then
                echo "  survey_${MODEL}_${PERSONALITY}_${ROUND_TAG}"
                echo "    Input:  $INPUT_DIR"
                echo "    Output: $OUTPUT_DIR"
            else
                echo "  [SKIP] survey_${MODEL}_${PERSONALITY}_${ROUND_TAG} - Input dir not found: $INPUT_DIR"
            fi
        done
    done
    echo ""
    exit 0
fi

# =============================================================================
# Submit jobs
# =============================================================================
SUBMITTED=0
SKIPPED=0

for PERSONALITY in "${SELECTED_PERSONALITIES[@]}"; do
    for (( ROUND=ROUND_START; ROUND<ROUND_END; ROUND++ )); do
        ROUND_TAG=$(printf "r%02d" "${ROUND}")

        INPUT_DIR="${INPUT_BASE}/${PERSONALITY}/${ROUND_TAG}"
        JOB_OUTPUT_DIR="${OUTPUT_BASE}/${PERSONALITY}/${ROUND_TAG}"
        JOB_NAME="survey_${MODEL}_${PERSONALITY}_${ROUND_TAG}"

        # Check if input dir exists
        if [[ ! -d "$INPUT_DIR" ]]; then
            echo "Warning: Input directory $INPUT_DIR does not exist. Skipping."
            ((SKIPPED++))
            continue
        fi

        echo "Submitting job: ${JOB_NAME}"
        echo "  INPUT_DIR       = ${INPUT_DIR}"
        echo "  OUTPUT_DIR      = ${JOB_OUTPUT_DIR}"
        echo ""

        sbatch \
            --job-name="${JOB_NAME}" \
            --export=ALL,\
INPUT_DIR="${INPUT_DIR}",\
OUTPUT_DIR="${JOB_OUTPUT_DIR}",\
INVENTORY_PATH="${INVENTORY_PATH}",\
ITEM_TEMPLATE_PATH="${ITEM_TEMPLATE}",\
MODEL_NAME="${MODEL_NAME}",\
SERVED_MODEL_NAME="${SERVED_MODEL_NAME}",\
MODELS_DIR="${MODELS_DIR}",\
APPTAINER_IMAGE="${APPTAINER_IMAGE}",\
RESUME="${RESUME}",\
DIMENSIONS="${DIMENSIONS}",\
MAX_WORKERS="${MAX_WORKERS}" \
            "${SLURM_SCRIPT}"

        ((SUBMITTED++))
    done
done

echo "=============================================="
echo "Summary: Submitted ${SUBMITTED} jobs, Skipped ${SKIPPED}"
echo "=============================================="
