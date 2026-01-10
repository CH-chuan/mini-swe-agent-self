# Experiment Submission System

This guide explains how to use the unified experiment submission system for running SWE-bench experiments on HPC clusters.

## Full Command Reference

```bash
./submit-experiment.sh \
    -m qwen3coder-30b \                    # Model config (qwen3coder-30b, gptoss-120b, devstral-small)
    -p NOP \                               # Personality prompt (NOP, HC-gpt, LC-gpt, HC-p2, ...)
    -i submit-in-rules \                   # Instruction template (submit-in-rules, submit-as-tool)
    -r 0:1 \                               # Round range START:END, exclusive (0:5 = r00-r04)
    -t '^(django__django-11951|...)$' \    # Task filter regex (default: 60-task set)
    -o experiments \                       # Base output dir (full path: base/MODEL/INSTRUCTION/PERSONALITY)
    --temperature 0.0 \                    # Model temperature (default: from model config)
    --step-limit 80 \                      # Max agent steps (default: from model config)
    --timeout 30 \                         # Command timeout in seconds (default: from model config)
    --time-limit 02:00:00 \                # SLURM time limit (default: from model config)
    --redo-existing \                      # Redo all instances (default: skip existing, resume mode)
    --dry-run                              # Preview config without submitting (remove to submit)
```

### Batch Submission Example

Submit all conscientiousness personality variants with 21 rounds each:

```bash
# Using default base path (experiments/)
for P in HC-gpt LC-gpt HC-p2 LC-p2 HC-p2-modify LC-p2-modify HC-item-120 LC-item-120; do
    ./submit-experiment.sh -m qwen3coder-30b -p "$P" -r 0:21
done
# Output: experiments/qwen3coder-30b/submit-in-rules/{HC-gpt,LC-gpt,...}/r00-r20/

# Using custom base path
for P in HC-gpt LC-gpt HC-p2 LC-p2 HC-p2-modify LC-p2-modify HC-item-120 LC-item-120; do
    ./submit-experiment.sh -m qwen3coder-30b -p "$P" -r 0:21 -o my-experiment
done
# Output: my-experiment/qwen3coder-30b/submit-in-rules/{HC-gpt,LC-gpt,...}/r00-r20/
```

This submits 8 personalities × 21 rounds = **168 SLURM jobs**.

## Overview

The experiment submission system provides a flexible way to run experiments with different combinations of:

- **Models** - Different LLM models (e.g., Qwen3-Coder, GPToss-120B)
- **Personalities** - Big Five personality trait prompts (Conscientiousness, Agreeableness, etc.)
- **Instructions** - Different instruction template styles
- **Tasks** - SWE-bench instance filters

## Quick Start

```bash
# Basic experiment with defaults
./submit-experiment.sh -m qwen3coder-30b -p HC-gpt -i submit-in-rules -r 0:5

# Dry run to preview without submitting
./submit-experiment.sh -m qwen3coder-30b -p HC-gpt --dry-run

# List available options
./submit-experiment.sh --list-models
./submit-experiment.sh --list-personalities
./submit-experiment.sh --list-instructions
```

## Directory Structure

```
exp_configs/
├── models/                     # Model configuration files
│   ├── qwen3coder-30b.conf
│   ├── gptoss-120b.conf
│   └── devstral-small.conf
└── templates/
    ├── base.yaml               # Base config template
    ├── personality/            # Personality prompt files
    │   ├── NOP.txt            # No personality (baseline)
    │   ├── HC-gpt.txt         # High Conscientiousness (GPT style)
    │   ├── LC-gpt.txt         # Low Conscientiousness (GPT style)
    │   ├── HC-p2.txt          # High Conscientiousness (P2 style)
    │   └── ...
    └── instructions/           # Instruction template files
        ├── submit-in-rules.txt
        └── submit-as-tool.txt
```

## Command Line Options

**Experiment settings:**

| Option | Short | Description | Default |
|--------|-------|-------------|---------|
| `--model` | `-m` | Model config name | `qwen3coder-30b` |
| `--personality` | `-p` | Personality prompt | `NOP` |
| `--instruction` | `-i` | Instruction template | `submit-in-rules` |
| `--rounds` | `-r` | Round range (START:END) | `0:1` |
| `--tasks` | `-t` | Instance filter regex | Default 60-task set |
| `--output` | `-o` | Base output directory | `experiments` |
| `--dry-run` | | Preview without submitting | |
| `--list-models` | | List available models | |
| `--list-personalities` | | List available personalities | |
| `--list-instructions` | | List available instructions | |
| `--help` | `-h` | Show help message | |

**Model-specific settings (defaults from model config, can override):**

| Option | Description |
|--------|-------------|
| `--temperature` | Override model temperature |
| `--step-limit` | Override max agent steps |
| `--timeout` | Override command timeout (seconds) |
| `--time-limit` | Override SLURM time limit |

## Usage Examples

### Running Multiple Rounds

```bash
# Run 5 rounds (r00 to r04)
./submit-experiment.sh -m qwen3coder-30b -p HC-gpt -r 0:5

# Run rounds 5-10
./submit-experiment.sh -m qwen3coder-30b -p HC-gpt -r 5:10
```

### Different Personality Experiments

```bash
# High Conscientiousness with GPT-style prompt
./submit-experiment.sh -m qwen3coder-30b -p HC-gpt -r 0:5

# Low Conscientiousness with P2-style prompt
./submit-experiment.sh -m qwen3coder-30b -p LC-p2 -r 0:5

# No personality (baseline)
./submit-experiment.sh -m qwen3coder-30b -p NOP -r 0:5
```

### Multi-GPU Models

```bash
# GPToss-120B requires 2 GPUs (configured in model file)
./submit-experiment.sh -m gptoss-120b -p HC-gpt -r 0:3 --time-limit 04:00:00
```

### Custom Output Directory

```bash
./submit-experiment.sh -m qwen3coder-30b -p HC-gpt -o my-experiment/run1 -r 0:5
```

### Custom Task Filter

```bash
# Run on specific Django issues only
./submit-experiment.sh -m qwen3coder-30b -p HC-gpt \
    -t '^(django__django-11951|django__django-11603)$' -r 0:3
```

### Override Parameters

```bash
# Higher temperature for more diverse outputs
./submit-experiment.sh -m qwen3coder-30b -p HC-gpt --temperature 0.7 -r 0:5

# More steps for complex tasks
./submit-experiment.sh -m qwen3coder-30b -p HC-gpt --step-limit 120 -r 0:5
```

## Available Personalities

### Conscientiousness (C)

| Name | Description |
|------|-------------|
| `HC-gpt` | High Conscientiousness - GPT-generated prompt |
| `LC-gpt` | Low Conscientiousness - GPT-generated prompt |
| `HC-p2` | High Conscientiousness - P2 style |
| `LC-p2` | Low Conscientiousness - P2 style |
| `HC-p2-modify` | High Conscientiousness - Modified P2 |
| `LC-p2-modify` | Low Conscientiousness - Modified P2 |
| `HC-item-120` | High Conscientiousness - Item-based (120 items) |
| `LC-item-120` | Low Conscientiousness - Item-based (120 items) |

### Other Big Five Traits

| Name | Trait | Level |
|------|-------|-------|
| `HA` / `LA` | Agreeableness | High / Low |
| `HE` / `LE` | Extraversion | High / Low |
| `HO` / `LO` | Openness | High / Low |

### Baseline

| Name | Description |
|------|-------------|
| `NOP` | No personality prompt (baseline) |

## Instruction Templates

| Name | Description |
|------|-------------|
| `submit-in-rules` | Submit command in "Important Rules" section |
| `submit-as-tool` | Submit command as a tool example |

## Available Models

| Model | GPUs | Container | Notes |
|-------|------|-----------|-------|
| `qwen3coder-30b` | 1x A100 | ubuntu-25.04.sif | Requires HF token, uses snapshot path |
| `gptoss-120b` | 2x A100 | ubuntu-25.04.sif | Uses TRITON_ATTN backend |
| `devstral-small` | 1x A100 | vllm-openai.sif | Direct args mode |

### Model-Specific vLLM Configurations

**Qwen3-Coder-30B:**
- Uses HuggingFace token for authentication
- Uses snapshot-based model path
- Args: `--max-model-len 128000`

**GPToss-120B:**
- Requires 2 GPUs with tensor parallelism
- Env: `VLLM_ATTENTION_BACKEND=TRITON_ATTN`
- Args: `--async-scheduling --disable-custom-all-reduce`

**Devstral-Small:**
- Uses different container (vllm-openai.sif)
- Uses direct args mode (no "vllm serve" prefix)
- Different HF_HOME path (`/hf_home`)

## Adding New Components

### Adding a New Model

Create a file `exp_configs/models/your-model.conf`:

```bash
# =============================================================================
# Model Identity
# =============================================================================
MODEL_NAME="your-org/your-model-name"    # HuggingFace model ID or local path
SERVED_MODEL_NAME="Your-Model"           # Name exposed via vLLM API
SNAPSHOT_HASH=""                         # Optional: specific model snapshot

# =============================================================================
# Paths
# =============================================================================
MODELS_DIR="/project/jingjing_storage/persona_coder/models"
APPTAINER_IMAGE="/project/jingjing_storage/persona_coder/ubuntu-25.04.sif"

# =============================================================================
# GPU Requirements
# =============================================================================
GPU_COUNT=1                              # Number of GPUs needed
GPU_TYPE="a100"                          # GPU type for SLURM
GPU_CONSTRAINT="a100_80gb"               # SLURM constraint

# =============================================================================
# Model Defaults
# =============================================================================
TEMPERATURE="0.0"
STEP_LIMIT="80"                          # Max agent steps
TIMEOUT="30"                             # Command timeout (seconds)
TIME_LIMIT="02:00:00"                    # SLURM time limit

# =============================================================================
# vLLM Serving Configuration
# =============================================================================
# Whether to use snapshot hash in model path (true/false)
USE_SNAPSHOT_PATH="false"

# HF_HOME bind path inside container
CONTAINER_HF_HOME="/models"

# Additional environment variables for apptainer (space-separated KEY=VALUE)
# Example: VLLM_ENV_VARS="VLLM_ATTENTION_BACKEND=TRITON_ATTN"
VLLM_ENV_VARS=""

# vLLM command-line arguments (appended to vllm serve command)
# Note: --tensor-parallel-size is added automatically based on GPU_COUNT
VLLM_ARGS="--max-model-len 128000"

# Whether HuggingFace token is required
REQUIRES_HF_TOKEN="false"

# For containers that run vllm directly (like vllm-openai.sif)
# Set to "true" to pass args directly instead of "vllm serve ..."
VLLM_DIRECT_ARGS="false"
```

#### Model Config Variables Reference

| Variable | Required | Description |
|----------|----------|-------------|
| `MODEL_NAME` | Yes | HuggingFace model ID or local path |
| `SERVED_MODEL_NAME` | Yes | Name exposed via vLLM API |
| `SNAPSHOT_HASH` | No | Specific model snapshot hash |
| `MODELS_DIR` | Yes | Host path to models directory |
| `APPTAINER_IMAGE` | Yes | Path to Apptainer/Singularity image |
| `GPU_COUNT` | Yes | Number of GPUs needed |
| `GPU_TYPE` | Yes | GPU type (a100, v100, h100) |
| `GPU_CONSTRAINT` | Yes | SLURM constraint string |
| `TEMPERATURE` | Yes | Default temperature |
| `STEP_LIMIT` | Yes | Max agent steps |
| `TIMEOUT` | Yes | Command timeout (seconds) |
| `TIME_LIMIT` | Yes | SLURM time limit (HH:MM:SS) |
| `USE_SNAPSHOT_PATH` | No | Use snapshot hash in model path |
| `CONTAINER_HF_HOME` | No | Bind path for HF_HOME in container |
| `VLLM_ENV_VARS` | No | Additional environment variables |
| `VLLM_ARGS` | No | Additional vLLM arguments |
| `REQUIRES_HF_TOKEN` | No | Whether HF token is needed |
| `VLLM_DIRECT_ARGS` | No | For containers that run vllm directly |

### Adding a New Personality

Create a file `exp_configs/templates/personality/your-personality.txt`:

```
    Your personality description here.
    Each line should have 4-space indentation.
    This content will be inserted into the system prompt.
```

**Important**: Personality files must have 4-space indentation on each line for proper YAML formatting.

### Adding a New Instruction Template

Create a file `exp_configs/templates/instructions/your-instruction.txt`:

```
    Please solve this issue: {{task}}

    Your custom instructions here...

    ## Important Rules

    1. Every response must contain exactly one action
    2. The action must be enclosed in triple backticks
    ...

    ### Submit your changes

    ```bash
    echo COMPLETE_TASK_AND_SUBMIT_FINAL_OUTPUT
    ```
```

**Important**: Instruction files must have 4-space indentation and include `{{task}}` and the submit command.

## Output Structure

When jobs complete, results are stored in:

```
{output_dir}/
└── r00/                        # Round 00
    ├── instance_1/
    ├── instance_2/
    └── ...

slurm_outputs/
└── job_results_{SLURM_JOB_ID}/
    ├── config.yaml             # Generated config used
    ├── model.conf              # Copy of model config
    ├── personality.txt         # Copy of personality file
    ├── instruction.txt         # Copy of instruction file
    ├── vllm_server.log         # vLLM server logs
    └── vllm_endpoint.txt       # vLLM endpoint URL
```

## Troubleshooting

### Job fails immediately

1. Check if model config exists: `./submit-experiment.sh --list-models`
2. Check if personality exists: `./submit-experiment.sh --list-personalities`
3. Use `--dry-run` to preview the configuration

### vLLM server timeout

- Increase SLURM time limit: `--time-limit 04:00:00`
- Check GPU availability in the cluster
- Review `slurm_outputs/job_results_*/vllm_server.log`

### YAML parsing errors

- Ensure personality files have 4-space indentation
- Ensure instruction files have 4-space indentation
- Check for special characters (colons, quotes) in personality content

### GPU allocation issues

- Verify `GPU_COUNT` in model config matches model requirements
- Check cluster GPU availability
- Multi-GPU models need `GPU_COUNT=2` or higher

## Running Tests

```bash
# Run all experiment tests
pytest tests/experiment/ -v

# Run specific test file
pytest tests/experiment/test_submit_script.py -v

# Run with coverage
pytest tests/experiment/ --cov=. --cov-report=term-missing
```
