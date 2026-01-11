---
description: Add a new model configuration for HPC experiments
argument-hint: [huggingface-model-name]
---

## Your Task

Add a new model configuration for the HuggingFace model: $ARGUMENTS

## Context

Existing model configs for reference:
@exp_configs/models/qwen3coder-30b.conf
@exp_configs/models/gptoss-120b.conf

## Process

1. **Gather Information** - Ask the user these questions using AskUserQuestion:
   - GPU count: 1x or 2x A100 80GB?
   - Snapshot hash: Do they have one, or should the model download from HuggingFace?
   - Config file name: Suggest a short name following conventions (e.g., "llama4-scout-17b")
   - HF token required: Does this model require authentication?

2. **Create Config File** - Create `exp_configs/models/{config-name}.conf` with:
   - MODEL_NAME: The full HuggingFace model path (from $ARGUMENTS)
   - SERVED_MODEL_NAME: A short display name for vLLM
   - SNAPSHOT_HASH: If provided, otherwise leave empty
   - GPU settings based on user's choice
   - TIME_LIMIT: 02:00:00 for 1 GPU, 04:00:00 for 2+ GPUs
   - Standard paths: MODELS_DIR="/scratch/muh5jn/models", APPTAINER_IMAGE="/project/jingjing_storage/persona_coder/ubuntu-25.04.sif"

3. **Verify** - Run these commands to validate:
   - `./submit-experiment.sh --list-models` - confirm model appears
   - `./submit-experiment.sh -m {config-name} -p NOP --dry-run` - validate config
   - `pytest tests/experiment/test_model_configs.py` - run tests

## Required Config Variables

```bash
# Model Identity
MODEL_NAME=""           # Full HuggingFace path
SERVED_MODEL_NAME=""    # Short name for vLLM API
SNAPSHOT_HASH=""        # Optional: cached model hash

# Paths (standard values)
MODELS_DIR="/scratch/muh5jn/models"
APPTAINER_IMAGE="/project/jingjing_storage/persona_coder/ubuntu-25.04.sif"

# GPU Requirements
GPU_COUNT=1             # 1 or 2
GPU_TYPE="a100"
GPU_CONSTRAINT="a100_80gb"

# Model Defaults
TEMPERATURE="0.0"
STEP_LIMIT="80"
TIMEOUT="30"
TIME_LIMIT="02:00:00"   # 04:00:00 for multi-GPU

# vLLM Serving
USE_SNAPSHOT_PATH="true"  # false if no snapshot hash
CONTAINER_HF_HOME="/models"
VLLM_ENV_VARS=""
VLLM_ARGS="--max-model-len 128000"
REQUIRES_HF_TOKEN="true"  # true for gated models
```
