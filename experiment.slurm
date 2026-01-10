#!/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --partition=gpu
#SBATCH --mail-user=muh5jn@virginia.edu
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --account=jingjing_lab

# NOTE: --time, --gres, --constraint are set dynamically by submit-experiment.sh

# =============================================================================
# Load modules
# =============================================================================
module load miniforge apptainer

# =============================================================================
# Apptainer setup
# =============================================================================
export APPTAINER_DOCKER_USERNAME="chuan000"
export APPTAINER_DOCKER_PASSWORD=""

echo "$APPTAINER_DOCKER_PASSWORD" | apptainer registry login \
    --username "$APPTAINER_DOCKER_USERNAME" \
    --password-stdin \
    docker://docker.io 2>/dev/null || true

SIF_CACHE="/scratch/muh5jn/apptainer_sif_cache"
export APPTAINER_CACHEDIR=/scratch/muh5jn/apptainer_cache
mkdir -p "$APPTAINER_CACHEDIR"

# =============================================================================
# Validate required environment variables
# =============================================================================
REQUIRED_VARS=(MODEL_CONF BASE_TEMPLATE PERSONALITY_FILE INSTRUCTION_FILE OUTPUT_DIR INSTANCE_FILTER)
for var in "${REQUIRED_VARS[@]}"; do
    if [[ -z "${!var:-}" ]]; then
        echo "ERROR: Required environment variable $var is not set"
        exit 1
    fi
done

# =============================================================================
# Load model configuration
# =============================================================================
if [[ ! -f "${MODEL_CONF}" ]]; then
    echo "ERROR: Model config file not found: ${MODEL_CONF}"
    exit 1
fi
source "$MODEL_CONF"

# =============================================================================
# Setup job results directory
# =============================================================================
JOB_RESULTS_DIR="/project/jingjing_storage/persona_coder/mini-swe-agent-self/slurm_outputs/job_results_${SLURM_JOB_ID}"
mkdir -p "$JOB_RESULTS_DIR"

# =============================================================================
# Print configuration
# =============================================================================
echo "=============================================="
echo "Job Configuration"
echo "=============================================="
echo "SLURM_JOB_ID:       ${SLURM_JOB_ID}"
echo "SLURM_JOB_NAME:     ${SLURM_JOB_NAME:-unknown}"
echo "MODEL_CONF:         ${MODEL_CONF}"
echo "MODEL_NAME:         ${MODEL_NAME}"
echo "SERVED_MODEL_NAME:  ${SERVED_MODEL_NAME}"
echo "GPU_COUNT:          ${GPU_COUNT}"
echo "OUTPUT_DIR:         ${OUTPUT_DIR}"
echo "PERSONALITY:        ${PERSONALITY:-unknown}"
echo "TEMPERATURE:        ${TEMPERATURE}"
echo "STEP_LIMIT:         ${STEP_LIMIT}"
echo "TIMEOUT:            ${TIMEOUT}"
echo "JOB_RESULTS_DIR:    ${JOB_RESULTS_DIR}"
echo "=============================================="
echo ""

# =============================================================================
# Step 1: Start vLLM Server
# =============================================================================
echo "=================================================="
echo "Step 1: Starting vLLM Server"
echo "=================================================="

source activate vllm_env

# Load HuggingFace token
HF_TOKEN=$(cat "$HOME/.cache/huggingface/token" 2>/dev/null || echo "")
if [[ -z "$HF_TOKEN" ]]; then
    echo "WARNING: HuggingFace token not found"
else
    echo "HF_TOKEN loaded: ${HF_TOKEN:0:10}...${HF_TOKEN: -10}"
fi

# Setup vLLM port and endpoint
VLLM_LOG="$JOB_RESULTS_DIR/vllm_server.log"
VLLM_PORT=$((20000 + SLURM_JOB_ID % 30000))
VLLM_BASE_URL="http://0.0.0.0:${VLLM_PORT}"

# Construct model path
if [[ -n "${SNAPSHOT_HASH:-}" ]]; then
    MODEL_PATH="/models/hub/models--${MODEL_NAME//\//--}/snapshots/${SNAPSHOT_HASH}"
else
    MODEL_PATH="/models/${MODEL_NAME}"
fi

echo "VLLM_PORT:          ${VLLM_PORT}"
echo "MODEL_PATH:         ${MODEL_PATH}"

# Build vLLM command
VLLM_CMD="vllm serve ${MODEL_PATH} --served-model-name ${SERVED_MODEL_NAME} --max-model-len 128000 --port ${VLLM_PORT}"

# Add tensor parallelism for multi-GPU
if (( GPU_COUNT > 1 )); then
    VLLM_CMD="${VLLM_CMD} --tensor-parallel-size ${GPU_COUNT}"
    echo "TENSOR_PARALLEL:    ${GPU_COUNT}"
fi

echo ""
echo "Starting vLLM server..."
echo "Command: ${VLLM_CMD}"

apptainer run --nv \
    --bind "$MODELS_DIR:/models" \
    --env HF_HOME=/models \
    --env HF_TOKEN="$HF_TOKEN" \
    --env PATH="$HOME/.conda/envs/vllm_env/bin:$PATH" \
    --env CPATH=/usr/lib/gcc/x86_64-linux-gnu/14/include \
    "$APPTAINER_IMAGE" \
    bash -c "${VLLM_CMD}" \
    > "$VLLM_LOG" 2>&1 &

VLLM_PID=$!
echo "$VLLM_PID" > "$JOB_RESULTS_DIR/vllm_server.pid"
echo "vLLM started with PID: $VLLM_PID"

# =============================================================================
# Step 2: Wait for vLLM Server
# =============================================================================
echo ""
echo "=================================================="
echo "Step 2: Waiting for vLLM Server"
echo "=================================================="

echo "$VLLM_BASE_URL" > "$JOB_RESULTS_DIR/vllm_base_url.txt"

MAX_WAIT=600
WAITED=0
SLEEP_INTERVAL=10

while (( WAITED < MAX_WAIT )); do
    # Check if process is still running
    if ! kill -0 "$VLLM_PID" 2>/dev/null; then
        echo "ERROR: vLLM server process died!"
        echo ""
        echo "=== Last 100 lines of vLLM log ==="
        tail -100 "$VLLM_LOG"
        exit 1
    fi

    # Check if server is ready
    if curl -s "${VLLM_BASE_URL}/health" >/dev/null 2>&1 || \
       curl -s "${VLLM_BASE_URL}/v1/models" >/dev/null 2>&1; then
        echo "vLLM server is ready! (waited ${WAITED}s)"
        break
    fi

    sleep "$SLEEP_INTERVAL"
    WAITED=$((WAITED + SLEEP_INTERVAL))
    echo "Waiting for vLLM server... (${WAITED}s elapsed)"
done

if (( WAITED >= MAX_WAIT )); then
    echo "ERROR: Timed out waiting for vLLM server after ${MAX_WAIT}s"
    echo ""
    echo "=== Last 100 lines of vLLM log ==="
    tail -100 "$VLLM_LOG"
    exit 1
fi

export VLLM_ENDPOINT="${VLLM_BASE_URL}/v1"
echo "$VLLM_ENDPOINT" > "$JOB_RESULTS_DIR/vllm_endpoint.txt"

# =============================================================================
# Step 3: Generate Config
# =============================================================================
echo ""
echo "=================================================="
echo "Step 3: Generating Config"
echo "=================================================="

conda deactivate
conda activate miniswe

# Read prompt files
PERSONALITY_PROMPT="$(cat "${PERSONALITY_FILE}")"
INSTANCE_TEMPLATE="$(cat "${INSTRUCTION_FILE}")"

# Export all variables needed for template substitution
export PERSONALITY_PROMPT
export INSTANCE_TEMPLATE
export TEMPERATURE
export STEP_LIMIT
export TIMEOUT
export SERVED_MODEL_NAME
export VLLM_ENDPOINT

# Generate config using Python for robust template substitution
JOB_CONFIG="$JOB_RESULTS_DIR/config.yaml"

python3 << 'PYTHON_SCRIPT'
import os
import re

# Read template
template_path = os.environ['BASE_TEMPLATE']
output_path = os.environ.get('JOB_CONFIG', '/tmp/config.yaml')

with open(template_path, 'r') as f:
    template = f.read()

# Substitute ${VAR} patterns with environment variables
def replace_var(match):
    var_name = match.group(1)
    value = os.environ.get(var_name, '')
    return value

result = re.sub(r'\$\{([A-Z_][A-Z0-9_]*)\}', replace_var, template)

# Write output
with open(output_path, 'w') as f:
    f.write(result)

print(f"Config generated: {output_path}")
PYTHON_SCRIPT

export JOB_CONFIG

echo "Generated config saved to: $JOB_CONFIG"

# Save copies of input files for reproducibility
cp "$MODEL_CONF" "$JOB_RESULTS_DIR/model.conf"
cp "$PERSONALITY_FILE" "$JOB_RESULTS_DIR/personality.txt"
cp "$INSTRUCTION_FILE" "$JOB_RESULTS_DIR/instruction.txt"
cp "$BASE_TEMPLATE" "$JOB_RESULTS_DIR/base_template.yaml"

echo "Input files copied to job results directory"

# =============================================================================
# Step 4: Run Experiment
# =============================================================================
echo ""
echo "=================================================="
echo "Step 4: Running Experiment"
echo "=================================================="

echo "Running mini-extra swebench..."
echo "  Config:   $JOB_CONFIG"
echo "  Output:   $OUTPUT_DIR"
echo "  Filter:   ${INSTANCE_FILTER:0:50}..."
echo ""

mini-extra swebench \
    --config "$JOB_CONFIG" \
    --subset verified \
    --split test \
    --filter "${INSTANCE_FILTER}" \
    --output "${OUTPUT_DIR}" \
    --sif-cache "${SIF_CACHE}"

EXIT_CODE=$?

# =============================================================================
# Cleanup
# =============================================================================
echo ""
echo "=================================================="
echo "Job Complete"
echo "=================================================="
echo "Exit code: $EXIT_CODE"
echo "Results:   $OUTPUT_DIR"
echo "Job logs:  $JOB_RESULTS_DIR"

# Gracefully stop vLLM server
if [[ -f "$JOB_RESULTS_DIR/vllm_server.pid" ]]; then
    VLLM_PID=$(cat "$JOB_RESULTS_DIR/vllm_server.pid")
    if kill -0 "$VLLM_PID" 2>/dev/null; then
        echo "Stopping vLLM server (PID: $VLLM_PID)..."
        kill "$VLLM_PID" 2>/dev/null || true
    fi
fi

exit $EXIT_CODE
