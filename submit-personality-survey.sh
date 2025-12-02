#!/bin/bash
# Submit multiple personality_survey.slurm jobs
# for different personality configs and multiple rounds.
# Matches the structure of submit-qwencoder-slurm-with-different-con-prompt.sh

set -euo pipefail

# -------------------------------------------------------------------
# Slurm script to submit
# -------------------------------------------------------------------
SLURM_SCRIPT="personality_survey.slurm"

echo "Submitting jobs using slurm script: ${SLURM_SCRIPT}"

# -------------------------------------------------------------------
# Personality list: "TAG"
#   TAG is what will appear in OUTPUT_DIR and job name
# -------------------------------------------------------------------
PERSONALITIES=(

  # "HC_p2"
  # "HC_gpt"
  # "HC_p2_modify"
  HC_ITEM_120
  HC_ITEM_300

  # "LC_p2"
  # "LC_gpt"
  # "LC_p2_modify"
  LC_ITEM_120
  LC_ITEM_300

)

# -------------------------------------------------------------------
# Paths
# -------------------------------------------------------------------
# Input base dir (from experiment)
INPUT_BASE_DIR="qwen3coder-exp-gpu-withpp"

# Output base dir for survey
OUTPUT_BASE_DIR="personality_survey_results"

# Inventory paths
INVENTORY_120="personality_survey/inventories/mpi_120.csv"
INVENTORY_300="personality_survey/inventories/mpi_300.csv"
ITEM_TEMPLATE="personality_survey/item_template.txt"

# Model info (should match experiment or be consistent)
MODEL_NAME="Qwen/Qwen3-Coder-30B-A3B-Instruct"
SERVED_MODEL_NAME="Qwen3-Coder"
MODELS_DIR="/project/jingjing_storage/persona_coder/models"
APPTAINER_IMAGE="/project/jingjing_storage/persona_coder/ubuntu-25.04.sif"


# -------------------------------------------------------------------
# Number of rounds per personality
# - Default range: 0:21   (i.e., rounds r00..r20)
# - Override with:
#     ./submit-personality-survey.sh 3:10
#   → rounds r03..r09
# -------------------------------------------------------------------
ROUND_RANGE="${1:-0:21}"

IFS=":" read -r ROUND_START ROUND_END <<< "${ROUND_RANGE}"

if (( ROUND_END <= ROUND_START )); then
  echo "ERROR: ROUND_END (${ROUND_END}) must be > ROUND_START (${ROUND_START})"
  exit 1
fi

# Total number of rounds in this range
ROUNDS=$(( ROUND_END - ROUND_START ))

# -------------------------------------------------------------------
# Main submission loops
# -------------------------------------------------------------------
for PERSONALITY in "${PERSONALITIES[@]}"; do
  # IFS=":" read -r PERSONALITY CONFIG_FILE <<< "${ENTRY}"

  # Determine inventory based on personality tag
  if [[ "$PERSONALITY" == *"300"* ]]; then
    INVENTORY_PATH="$INVENTORY_300"
    echo "Selected 300-item inventory for $PERSONALITY"
  else
    INVENTORY_PATH="$INVENTORY_120"
    echo "Selected 120-item inventory for $PERSONALITY"
  fi

  # ROUND_INDEX is 1..ROUNDS (for logging / job env),
  # ROUND is the actual numeric label in [ROUND_START, ROUND_END)
  ROUND_INDEX=1
  for (( ROUND=ROUND_START; ROUND<ROUND_END; ROUND++ )); do
    ROUND_TAG=$(printf "r%02d" "${ROUND}")
    
    INPUT_DIR="${INPUT_BASE_DIR}/${PERSONALITY}/${ROUND_TAG}"
    JOB_OUTPUT_DIR="${OUTPUT_BASE_DIR}/${PERSONALITY}/${ROUND_TAG}"

    JOB_NAME="survey_${PERSONALITY}_${ROUND_TAG}"

    # Check if input dir exists
    if [ ! -d "$INPUT_DIR" ]; then
        echo "Warning: Input directory $INPUT_DIR does not exist. Skipping."
        continue
    fi

    echo "Submitting job: ${JOB_NAME}"
    echo "  INPUT_DIR       = ${INPUT_DIR}"
    echo "  OUTPUT_DIR      = ${JOB_OUTPUT_DIR}"
    echo "  INVENTORY_PATH  = ${INVENTORY_PATH}"
    echo "  ROUND_LABEL     = ${ROUND}  (range ${ROUND_START}:${ROUND_END})"
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
APPTAINER_IMAGE="${APPTAINER_IMAGE}" \
      "${SLURM_SCRIPT}"

    ROUND_INDEX=$((ROUND_INDEX + 1))
  done
done
