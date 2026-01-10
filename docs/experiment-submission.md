# Experiment Submission System

This guide explains how to use the unified experiment submission system for running SWE-bench experiments on HPC clusters.

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
│   └── gptoss-120b.conf
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

| Option | Short | Description | Default |
|--------|-------|-------------|---------|
| `--model` | `-m` | Model config name | `qwen3coder-30b` |
| `--personality` | `-p` | Personality prompt | `NOP` |
| `--instruction` | `-i` | Instruction template | `submit-in-rules` |
| `--rounds` | `-r` | Round range (START:END) | `0:1` |
| `--tasks` | `-t` | Instance filter regex | Default 60-task set |
| `--output` | `-o` | Base output directory | Auto-generated |
| `--temperature` | | Override model temperature | Model default |
| `--step-limit` | | Max agent steps | `80` |
| `--timeout` | | Command timeout (seconds) | `30` |
| `--time-limit` | | SLURM time limit | `02:00:00` |
| `--dry-run` | | Preview without submitting | |
| `--list-models` | | List available models | |
| `--list-personalities` | | List available personalities | |
| `--list-instructions` | | List available instructions | |
| `--help` | `-h` | Show help message | |

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

## Adding New Components

### Adding a New Model

Create a file `exp_configs/models/your-model.conf`:

```bash
# Model identity
MODEL_NAME="your-model-name"
SERVED_MODEL_NAME="Your-Model"
SNAPSHOT_HASH="abc123..."

# Paths
MODELS_DIR="/path/to/models"
APPTAINER_IMAGE="/path/to/image.sif"

# GPU requirements
GPU_COUNT=1          # Number of GPUs needed
GPU_TYPE="a100"      # GPU type
GPU_CONSTRAINT="a100_80gb"

# Model defaults
TEMPERATURE="0.0"
```

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
