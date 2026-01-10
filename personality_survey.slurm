#!/bin/bash

#SBATCH --time=05:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --gres=gpu:a100:1
#SBATCH --constraint=a100_80gb
#SBATCH --partition=gpu
#SBATCH -J "personality-survey"
#SBATCH --mail-user=muh5jn@virginia.edu
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --account=jingjing_lab

# =============================================================================
# Configuration
# =============================================================================

# Load modules
module load miniforge apptainer

# SIF CACHE (Not used)
SIF_CACHE="/scratch/muh5jn/apptainer_sif_cache"
  
# set cache dir
export APPTAINER_CACHEDIR=/scratch/muh5jn/apptainer_cache


# Overwriteables from sbatch --export
: "${INPUT_DIR:?Required}"
: "${INVENTORY_PATH:?Required}"
: "${ITEM_TEMPLATE_PATH:?Required}"
: "${OUTPUT_DIR:?Required}"

: "${MODEL_NAME:=Qwen/Qwen3-Coder-30B-A3B-Instruct}"
: "${SERVED_MODEL_NAME:=Qwen3-Coder}"
: "${MODELS_DIR:=/scratch/muh5jn/models}"
: "${APPTAINER_IMAGE:=/project/jingjing_storage/persona_coder/ubuntu-25.04.sif}"

: "${RESUME:=true}"
: "${DIMENSIONS:=OCEAN}"
: "${MAX_WORKERS:=4}"

mkdir -p "$OUTPUT_DIR"

echo "=== Runtime configuration ==="
echo "INPUT_DIR        = ${INPUT_DIR}"
echo "INVENTORY_PATH   = ${INVENTORY_PATH}"
echo "ITEM_TEMPLATE_PATH = ${ITEM_TEMPLATE_PATH}"
echo "OUTPUT_DIR       = ${OUTPUT_DIR}"
echo "MODEL_NAME       = ${MODEL_NAME}"
echo "SERVED_MODEL_NAME= ${SERVED_MODEL_NAME}"
echo "MODELS_DIR       = ${MODELS_DIR}"
echo "RESUME           = ${RESUME}"
echo "DIMENSIONS       = ${DIMENSIONS}"
echo "MAX_WORKERS      = ${MAX_WORKERS}"
echo "============================="


# =============================================================================
# Step 1: Start vLLM Server
# =============================================================================
echo "=================================================="
echo "Step 1: Starting vLLM Server"
echo "=================================================="

# Activate vllm environment
source activate vllm_env

# Read HuggingFace token
HF_TOKEN=$(cat $HOME/.cache/huggingface/token)
echo "HF_TOKEN loaded: ${HF_TOKEN:0:10}...${HF_TOKEN: -10}"

# Create log file for vllm server
VLLM_LOG="$OUTPUT_DIR/vllm_server.log"


# Per-job vLLM port (use high range; avoid clashes)
: "${VLLM_PORT:=$((20000 + SLURM_JOB_ID % 30000))}"
VLLM_ENDPOINT="http://127.0.0.1:${VLLM_PORT}/v1"

echo "VLLM_PORT       = ${VLLM_PORT}"
echo "VLLM_ENDPOINT   = ${VLLM_ENDPOINT}"


# Start vLLM server in background - it will automatically find an available port
echo "Starting vLLM server with model: $MODEL_NAME"
apptainer run --nv \
    --bind "$MODELS_DIR:/models" \
    --env HF_HOME=/models \
    --env HF_TOKEN=$HF_TOKEN \
    --env PATH=$HOME/.conda/envs/vllm_env/bin:$PATH \
    --env CPATH=/usr/lib/gcc/x86_64-linux-gnu/14/include \
    "$APPTAINER_IMAGE" \
    vllm serve "$MODEL_NAME" \
      --served-model-name "$SERVED_MODEL_NAME" \
      --max-model-len 128000 \
      --port "$VLLM_PORT" \
    > "$VLLM_LOG" 2>&1 &

VLLM_PID=$!
echo "vLLM server started with PID: $VLLM_PID"
echo $VLLM_PID > "$OUTPUT_DIR/vllm_server.pid"



# =============================================================================
# Step 2: Wait for vLLM Server and Capture Port
# =============================================================================
echo ""
echo "=================================================="
echo "Step 2: Waiting for vLLM Server to be Ready"
echo "=================================================="

# Before the wait loop, after you know VLLM_PORT
VLLM_BASE_URL="http://0.0.0.0:${VLLM_PORT}"
echo "$VLLM_BASE_URL" > "$OUTPUT_DIR/vllm_base_url.txt"

MAX_WAIT=600
WAITED=0
SLEEP_INTERVAL=10

while [ $WAITED -lt $MAX_WAIT ]; do
    if ! kill -0 $VLLM_PID 2>/dev/null; then
        echo "ERROR: vLLM server process died!"
        echo "Last 100 lines of server log:"
        tail -100 "$VLLM_LOG"
        exit 1
    fi

    # Correct health / readiness checks
    if curl -s "${VLLM_BASE_URL}/health" >/dev/null 2>&1 || \
       curl -s "${VLLM_BASE_URL}/v1/models" >/dev/null 2>&1; then
        echo "vLLM server is ready! (waited ${WAITED}s)"
        echo ""
        break
    fi

    sleep $SLEEP_INTERVAL
    WAITED=$((WAITED + SLEEP_INTERVAL))
    echo "Still waiting for vLLM server... (${WAITED}s elapsed)"
done

if [ $WAITED -ge $MAX_WAIT ]; then
    echo "ERROR: Timed out waiting for vLLM server."
    tail -100 "$VLLM_LOG"
    exit 1
fi

# Now define the OpenAI-style endpoint (with /v1) for downstream code
export VLLM_ENDPOINT="${VLLM_BASE_URL}/v1"
echo "$VLLM_ENDPOINT" > "$OUTPUT_DIR/vllm_endpoint.txt"



# =============================================================================
# Step 3: Run Personality Survey
# =============================================================================
echo ""
echo "=================================================="
echo "Step 3: Running Personality Survey"
echo "=================================================="

conda deactivate
conda activate miniswe

# Ensure litellm is installed (if not already in miniswe)
# pip install litellm tqdm

echo "Running personality test..."

# Construct arguments
ARGS=""
if [ "$RESUME" = "true" ]; then
    ARGS="$ARGS --resume"
fi

# Use find to locate all .traj.json files recursively
# Structure example: .../instance_id/final.traj.json OR .../instance_id/instance_id.traj.json
find "$INPUT_DIR" -name "*.traj.json" | while read TRAJ_FILE; do
  [ -e "$TRAJ_FILE" ] || continue
  
  # Use parent directory name as instance ID (robust to filename variations)
  INSTANCE_ID=$(basename "$(dirname "$TRAJ_FILE")")
  
  INSTANCE_OUTPUT_DIR="${OUTPUT_DIR}/${INSTANCE_ID}"
  mkdir -p "$INSTANCE_OUTPUT_DIR"
  
  echo "Processing $INSTANCE_ID from $TRAJ_FILE..."
  python personality_survey/run_personality_test.py \
      --trajectory_path "$TRAJ_FILE" \
      --inventory_path "$INVENTORY_PATH" \
      --output_dir "$INSTANCE_OUTPUT_DIR" \
      --item_template_path "$ITEM_TEMPLATE_PATH" \
      --api_base "$VLLM_ENDPOINT" \
      --model_name "hosted_vllm/$SERVED_MODEL_NAME" \
      --dimensions "$DIMENSIONS" \
      --max_workers "$MAX_WORKERS" \
      $ARGS
done

echo "Job completed."
