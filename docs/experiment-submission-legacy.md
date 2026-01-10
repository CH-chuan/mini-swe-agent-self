# Legacy Experiment Submission (Deprecated)

> **Note:** This method is deprecated. Use the new unified submission system documented in [experiment-submission.md](experiment-submission.md) instead.

This document describes the legacy method for submitting experiments using separate YAML config files for each personality variant.

## Overview

The legacy system uses two scripts:
1. `qwencoder_experiment_1gpu_with_personality.slurm` - SLURM job script that runs a single experiment
2. `submit-qwencoder-slurm-with-different-con-prompt-no-submit.sh` - Wrapper script that submits multiple jobs

## How It Works

### 1. SLURM Script (`qwencoder_experiment_1gpu_with_personality.slurm`)

The SLURM script handles:
- Loading modules (miniforge, apptainer)
- Starting vLLM server with the Qwen3-Coder model
- Waiting for server readiness
- Running `mini-extra swebench` with the provided config

**Key environment variables (passed from submit script):**

| Variable | Description |
|----------|-------------|
| `CONFIG_FILE` | Path to YAML config file |
| `OUTPUT_DIR` | Output directory for results |
| `MODEL_NAME` | HuggingFace model ID |
| `SERVED_MODEL_NAME` | Name for vLLM API |
| `MODELS_DIR` | Host path to models |
| `APPTAINER_IMAGE` | Path to container image |
| `INSTANCE_FILTER` | Regex to filter SWE-bench instances |
| `PERSONALITY` | Personality tag (for logging) |
| `ROUND_INDEX` | Current round number |
| `ROUNDS` | Total number of rounds |

### 2. Submit Script (`submit-qwencoder-slurm-with-different-con-prompt-no-submit.sh`)

The submit script:
1. Defines personality configs as `TAG:CONFIG_PATH` pairs
2. Loops over personalities and rounds
3. Submits SLURM jobs with appropriate environment variables

**Configuration in the script:**

```bash
# Base output directory
BASE_OUTPUT_DIR="qwen3coder-exp-gpu-withpp/no-submit-instruction-2"

# Config file directory
BASE_CFG_DIR="/project/jingjing_storage/persona_coder/mini-swe-agent-self/exp_configs/con-no-submit"

# Personality configs (TAG:CONFIG_PATH)
PERSONALITIES=(
  HC_p2:${CONFIG_HC_P2}
  LC_p2:${CONFIG_LC_P2}
  HC_gpt:${CONFIG_HC_GPT}
  LC_gpt:${CONFIG_LC_GPT}
  # ... more personalities
)

# Instance filter regex
INSTANCE_FILTER='^(django__django-11951|...)$'
```

## Usage

### Submit with default rounds (0:21)

```bash
./submit-qwencoder-slurm-with-different-con-prompt-no-submit.sh
```

### Submit specific round range

```bash
# Submit rounds r03 to r09
./submit-qwencoder-slurm-with-different-con-prompt-no-submit.sh 3:10
```

## Required YAML Config Files

Each personality requires a separate YAML config file. Example structure:

```
exp_configs/con-no-submit/
├── qwen3coder_30b_try_NOP.yaml
├── qwen3coder_30b_try_HC-p2.yaml
├── qwen3coder_30b_try_LC-p2.yaml
├── qwen3coder_30b_try_HC-gpt.yaml
├── qwen3coder_30b_try_LC-gpt.yaml
├── qwen3coder_30b_try_HC-p2-modify.yaml
├── qwen3coder_30b_try_LC-p2-modify.yaml
├── qwen3coder_30b_try_HC-item-120.yaml
├── qwen3coder_30b_try_LC-item-120.yaml
├── qwen3coder_30b_try_HC-item-300.yaml
└── qwen3coder_30b_try_LC-item-300.yaml
```

Each config file contains the full agent configuration including the personality prompt embedded in the `system_template`.

## Output Structure

```
{BASE_OUTPUT_DIR}/
├── HC_p2/
│   ├── r00/
│   ├── r01/
│   └── ...
├── LC_p2/
│   ├── r00/
│   └── ...
└── ...
```

## Limitations

1. **Config file proliferation** - Each personality/model/instruction combination requires a separate YAML file
2. **Hardcoded paths** - Model paths, container paths are hardcoded in scripts
3. **Single model support** - Only supports Qwen3-Coder-30B
4. **No CLI flexibility** - Must edit script to change personalities or settings

## Migration to New System

The new unified submission system addresses these limitations:

| Legacy | New System |
|--------|------------|
| Separate YAML per personality | Single base template + personality files |
| Edit script to change config | CLI arguments |
| Hardcoded model settings | Model config files |
| Single model | Multiple models supported |

**Equivalent command in new system:**

```bash
# Legacy: edit script, then run
./submit-qwencoder-slurm-with-different-con-prompt-no-submit.sh 0:21

# New: use CLI
for P in HC-p2 LC-p2 HC-gpt LC-gpt HC-p2-modify LC-p2-modify; do
    ./submit-experiment.sh -m qwen3coder-30b -p "$P" -r 0:21
done
```

See [experiment-submission.md](experiment-submission.md) for full documentation of the new system.
