#!/bin/bash
# Unified experiment submission script
# Usage: ./submit-experiment.sh -m MODEL -p PERSONALITY -i INSTRUCTION -r ROUNDS

set -euo pipefail

# =============================================================================
# Script paths
# =============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="${SCRIPT_DIR}/exp_configs/templates"
MODELS_CONF_DIR="${SCRIPT_DIR}/exp_configs/models"
SLURM_SCRIPT="${SCRIPT_DIR}/experiment.slurm"

# =============================================================================
# Default values
# =============================================================================
MODEL="qwen3coder-30b"
PERSONALITY="NOP"
INSTRUCTION="submit-in-rules"
ROUNDS="0:1"
OUTPUT_DIR=""
INSTANCE_FILTER='^(django__django-11951|django__django-11603|astropy__astropy-14995|sphinx-doc__sphinx-9698|django__django-16527|sympy__sympy-22456|django__django-16901|django__django-9296|django__django-15277|astropy__astropy-14309|pytest-dev__pytest-7982|django__django-15863|django__django-14787|django__django-14493|scikit-learn__scikit-learn-10844|sympy__sympy-20154|django__django-15368|django__django-13741|django__django-16493|django__django-11163|django__django-14855|scikit-learn__scikit-learn-13439|django__django-16139|django__django-17029|django__django-11133|sympy__sympy-23534|django__django-16662|pydata__xarray-4075|django__django-11749|django__django-15572|django__django-14752|django__django-13516|django__django-12419|sympy__sympy-16886|django__django-10914|django__django-15467|matplotlib__matplotlib-25122|matplotlib__matplotlib-24026|sympy__sympy-24213|django__django-16612|django__django-13670|pytest-dev__pytest-7205|django__django-12050|sympy__sympy-16450|django__django-15741|django__django-15380|django__django-12708|django__django-13449|django__django-13837|django__django-16877|sphinx-doc__sphinx-10466|django__django-16454|sympy__sympy-20801|django__django-15814|scikit-learn__scikit-learn-11578|django__django-13315|django__django-14434|django__django-11848|django__django-16082|django__django-12713)$'

# CLI overrides (empty = use model default)
TEMPERATURE=""
STEP_LIMIT=""
TIMEOUT=""
TIME_LIMIT=""

# =============================================================================
# Help / Usage
# =============================================================================
usage() {
    cat <<EOF
Usage: $0 [OPTIONS]

Unified experiment submission script for HPC cluster.

OPTIONS:
  -m, --model NAME          Model config name (default: qwen3coder-30b)
  -p, --personality NAME    Personality prompt file (default: NOP)
  -i, --instruction NAME    Instruction template file (default: submit-in-rules)
  -r, --rounds RANGE        Round range START:END (default: 0:1)
  -t, --tasks REGEX         Instance filter regex (default: built-in 60-task set)
  -o, --output DIR          Base output directory (default: experiments)
                            Full path: DIR/MODEL/INSTRUCTION/PERSONALITY
  --temperature FLOAT       Override model temperature (default: model config)
  --step-limit INT          Max agent steps (default: model config)
  --timeout INT             Command timeout in seconds (default: model config)
  --time-limit HH:MM:SS     SLURM time limit (default: model config)
  --dry-run                 Show config and sbatch command without submitting
  --list-models             List available model configs
  --list-personalities      List available personality prompts
  --list-instructions       List available instruction templates
  -h, --help                Show this help message

EXAMPLES:
  # Basic usage with defaults
  $0 -m qwen3coder-30b -p HC-gpt -i submit-as-tool -r 0:5

  # Multi-GPU model with more time
  $0 -m gptoss-120b -p LC-p2 -r 0:10 --time-limit 04:00:00

  # Custom output directory
  $0 -m qwen3coder-30b -p HC-gpt -o my-experiment/run1 -r 0:3

  # Dry run to preview
  $0 -m qwen3coder-30b -p HC-gpt --dry-run

  # List available options
  $0 --list-models
  $0 --list-personalities
  $0 --list-instructions

EOF
    exit 0
}

list_available() {
    local dir="$1"
    local ext="$2"
    local name="$3"
    echo "Available ${name}:"
    if [[ -d "$dir" ]]; then
        ls -1 "${dir}"/*."${ext}" 2>/dev/null | xargs -n1 basename | sed "s/\.${ext}$//" | sed 's/^/  /' || echo "  (none found)"
    else
        echo "  Directory not found: $dir"
    fi
    exit 0
}

# =============================================================================
# Parse command line arguments
# =============================================================================
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -m|--model)
            MODEL="$2"
            shift 2
            ;;
        -p|--personality)
            PERSONALITY="$2"
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
        -t|--tasks)
            INSTANCE_FILTER="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        --temperature)
            TEMPERATURE="$2"
            shift 2
            ;;
        --step-limit)
            STEP_LIMIT="$2"
            shift 2
            ;;
        --timeout)
            TIMEOUT="$2"
            shift 2
            ;;
        --time-limit)
            TIME_LIMIT="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --list-models)
            list_available "$MODELS_CONF_DIR" "conf" "models"
            ;;
        --list-personalities)
            list_available "$TEMPLATES_DIR/personality" "txt" "personalities"
            ;;
        --list-instructions)
            list_available "$TEMPLATES_DIR/instructions" "txt" "instructions"
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

# =============================================================================
# Validate and load model configuration
# =============================================================================
MODEL_CONF="${MODELS_CONF_DIR}/${MODEL}.conf"
if [[ ! -f "$MODEL_CONF" ]]; then
    echo "ERROR: Model config not found: $MODEL_CONF"
    list_available "$MODELS_CONF_DIR" "conf" "models"
fi

# Save CLI overrides before sourcing model config
CLI_TEMPERATURE="$TEMPERATURE"
CLI_STEP_LIMIT="$STEP_LIMIT"
CLI_TIMEOUT="$TIMEOUT"
CLI_TIME_LIMIT="$TIME_LIMIT"

# Source model config to get defaults
source "$MODEL_CONF"

# Apply CLI overrides (if provided) or keep model defaults
[[ -n "$CLI_TEMPERATURE" ]] && TEMPERATURE="$CLI_TEMPERATURE"
[[ -n "$CLI_STEP_LIMIT" ]] && STEP_LIMIT="$CLI_STEP_LIMIT"
[[ -n "$CLI_TIMEOUT" ]] && TIMEOUT="$CLI_TIMEOUT"
[[ -n "$CLI_TIME_LIMIT" ]] && TIME_LIMIT="$CLI_TIME_LIMIT"

# Fallback defaults if model config didn't set them
: "${TEMPERATURE:=0.0}"
: "${STEP_LIMIT:=80}"
: "${TIMEOUT:=30}"
: "${TIME_LIMIT:=02:00:00}"

# =============================================================================
# Validate prompt and instruction files exist
# =============================================================================
PERSONALITY_FILE="${TEMPLATES_DIR}/personality/${PERSONALITY}.txt"
INSTRUCTION_FILE="${TEMPLATES_DIR}/instructions/${INSTRUCTION}.txt"
BASE_TEMPLATE="${TEMPLATES_DIR}/base.yaml"

if [[ ! -f "$PERSONALITY_FILE" ]]; then
    echo "ERROR: Personality file not found: $PERSONALITY_FILE"
    list_available "$TEMPLATES_DIR/personality" "txt" "personalities"
fi

if [[ ! -f "$INSTRUCTION_FILE" ]]; then
    echo "ERROR: Instruction file not found: $INSTRUCTION_FILE"
    list_available "$TEMPLATES_DIR/instructions" "txt" "instructions"
fi

if [[ ! -f "$BASE_TEMPLATE" ]]; then
    echo "ERROR: Base template not found: $BASE_TEMPLATE"
    exit 1
fi

if [[ ! -f "$SLURM_SCRIPT" ]]; then
    echo "ERROR: SLURM script not found: $SLURM_SCRIPT"
    exit 1
fi

# =============================================================================
# Set output directory
# =============================================================================
# OUTPUT_DIR is the base path; full path is base/${MODEL}/${INSTRUCTION}/${PERSONALITY}
OUTPUT_BASE="${OUTPUT_DIR:-experiments}"
OUTPUT_DIR="${OUTPUT_BASE}/${MODEL}/${INSTRUCTION}/${PERSONALITY}"

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
echo "Experiment Configuration"
echo "=============================================="
echo "Model:          $MODEL"
echo "  GPU:          ${GPU_COUNT}x ${GPU_TYPE} (${GPU_CONSTRAINT})"
echo "  Served Name:  $SERVED_MODEL_NAME"
echo "Personality:    $PERSONALITY"
echo "Instruction:    $INSTRUCTION"
echo "Rounds:         r$(printf '%02d' $ROUND_START) - r$(printf '%02d' $((ROUND_END-1))) ($TOTAL_ROUNDS jobs)"
echo "Output:         $OUTPUT_DIR"
echo "Temperature:    $TEMPERATURE"
echo "Step Limit:     $STEP_LIMIT"
echo "Timeout:        ${TIMEOUT}s"
echo "Time Limit:     $TIME_LIMIT"
echo "=============================================="
echo ""

# =============================================================================
# Dry run mode
# =============================================================================
if [[ "$DRY_RUN" == "true" ]]; then
    echo "[DRY RUN MODE]"
    echo ""
    echo "Would submit $TOTAL_ROUNDS jobs with the following sbatch command:"
    echo ""
    echo "  sbatch \\"
    echo "    --job-name=\"${MODEL}_${PERSONALITY}_r00\" \\"
    echo "    --time=${TIME_LIMIT} \\"
    echo "    --gres=gpu:${GPU_TYPE}:${GPU_COUNT} \\"
    echo "    --constraint=${GPU_CONSTRAINT} \\"
    echo "    --export=ALL,MODEL_CONF=${MODEL_CONF},... \\"
    echo "    ${SLURM_SCRIPT}"
    echo ""
    echo "Files that would be used:"
    echo "  Model config:    $MODEL_CONF"
    echo "  Personality:     $PERSONALITY_FILE"
    echo "  Instruction:     $INSTRUCTION_FILE"
    echo "  Base template:   $BASE_TEMPLATE"
    echo "  SLURM script:    $SLURM_SCRIPT"
    echo ""
    exit 0
fi

# =============================================================================
# Submit jobs
# =============================================================================
echo "Submitting $TOTAL_ROUNDS jobs..."
echo ""

for (( ROUND=ROUND_START; ROUND<ROUND_END; ROUND++ )); do
    ROUND_TAG=$(printf "r%02d" "${ROUND}")
    JOB_OUTPUT_DIR="${OUTPUT_DIR}/${ROUND_TAG}"
    JOB_NAME="${MODEL}_${PERSONALITY}_${ROUND_TAG}"

    echo "Submitting: ${JOB_NAME}"
    echo "  Output: ${JOB_OUTPUT_DIR}"

    sbatch \
        --job-name="${JOB_NAME}" \
        --time="${TIME_LIMIT}" \
        --gres="gpu:${GPU_TYPE}:${GPU_COUNT}" \
        --constraint="${GPU_CONSTRAINT}" \
        --export=ALL,\
MODEL_CONF="${MODEL_CONF}",\
BASE_TEMPLATE="${BASE_TEMPLATE}",\
PERSONALITY_FILE="${PERSONALITY_FILE}",\
INSTRUCTION_FILE="${INSTRUCTION_FILE}",\
OUTPUT_DIR="${JOB_OUTPUT_DIR}",\
INSTANCE_FILTER="${INSTANCE_FILTER}",\
TEMPERATURE="${TEMPERATURE}",\
STEP_LIMIT="${STEP_LIMIT}",\
TIMEOUT="${TIMEOUT}",\
PERSONALITY="${PERSONALITY}",\
ROUND_INDEX="$((ROUND - ROUND_START + 1))",\
ROUNDS="${TOTAL_ROUNDS}" \
        "${SLURM_SCRIPT}"

    echo ""
done

echo "=============================================="
echo "Submitted ${TOTAL_ROUNDS} jobs successfully."
echo "=============================================="
