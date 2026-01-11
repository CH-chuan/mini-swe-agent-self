---
description: Add a new model configuration for HPC experiments
argument-hint: [huggingface-model-name]
---

## Your Task

Add a new model configuration for the HuggingFace model: $ARGUMENTS

## Context

Existing model configs for reference:
@exp_configs/models/qwen3coder-30b.conf
@exp_configs/models/devstral-small.conf

## Container Types

There are two container patterns:

| Container | Use Case | Config |
|-----------|----------|--------|
| **vllm-openai.sif** | Most models (recommended) | `VLLM_DIRECT_ARGS="true"`, `CONTAINER_HF_HOME="/hf_home"` |
| **ubuntu-25.04.sif** | Models needing conda vllm_env | `VLLM_DIRECT_ARGS` not set, `CONTAINER_HF_HOME="/models"` |

## Process

1. **Gather Information** - Ask the user these questions using AskUserQuestion:
   - Container type: vllm-openai.sif (recommended) or ubuntu-25.04.sif?
   - GPU count: 1x or 2x A100 80GB?
   - Snapshot hash: Do they have one, or should the model download from HuggingFace?
   - Config file name: Suggest a short name following conventions (e.g., "llama4-scout-17b")
   - HF token required: Does this model require authentication?

2. **Create Config File** - Create `exp_configs/models/{config-name}.conf` based on container choice:

   **For vllm-openai.sif:**
   - APPTAINER_IMAGE="/project/jingjing_storage/persona_coder/vllm-openai.sif"
   - CONTAINER_HF_HOME="/hf_home"
   - VLLM_DIRECT_ARGS="true"

   **For ubuntu-25.04.sif:**
   - APPTAINER_IMAGE="/project/jingjing_storage/persona_coder/ubuntu-25.04.sif"
   - CONTAINER_HF_HOME="/models"
   - Do NOT set VLLM_DIRECT_ARGS

3. **Verify** - Run these commands to validate:
   - `./submit-experiment.sh --list-models` - confirm model appears
   - `./submit-experiment.sh -m {config-name} -p NOP --dry-run` - validate config
   - `pytest tests/experiment/test_model_configs.py` - run tests

## Config Template (vllm-openai.sif - recommended)

```bash
# Model: {model-name}
# GPU: {N}x A100 80GB

# =============================================================================
# Model Identity
# =============================================================================
MODEL_NAME=""           # Full HuggingFace path
SERVED_MODEL_NAME=""    # Short name for vLLM API
SNAPSHOT_HASH=""        # Model snapshot hash

# =============================================================================
# Paths
# =============================================================================
MODELS_DIR="/scratch/muh5jn/models"
APPTAINER_IMAGE="/project/jingjing_storage/persona_coder/vllm-openai.sif"

# =============================================================================
# GPU Requirements
# =============================================================================
GPU_COUNT=1             # 1 or 2
GPU_TYPE="a100"
GPU_CONSTRAINT="a100_80gb"

# =============================================================================
# Model Defaults
# =============================================================================
TEMPERATURE="0.0"
STEP_LIMIT="80"
TIMEOUT="30"
TIME_LIMIT="02:00:00"   # 04:00:00 for multi-GPU

# =============================================================================
# vLLM Serving Configuration
# =============================================================================
USE_SNAPSHOT_PATH="true"
CONTAINER_HF_HOME="/hf_home"
VLLM_ENV_VARS=""
VLLM_ARGS="--max-model-len 128000"
REQUIRES_HF_TOKEN="true"  # true for gated models

# =============================================================================
# Special Configuration
# =============================================================================
# vllm-openai.sif has vllm pre-installed, args passed directly to container
VLLM_DIRECT_ARGS="true"
```
