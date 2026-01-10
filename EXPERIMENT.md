# Experiment Submission Quick Start

Submit SWE-bench experiments to HPC with different models and personality prompts.

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

```bash
# Using default base path (experiments/)
for P in HC-gpt LC-gpt HC-p2 LC-p2 HC-p2-modify LC-p2-modify HC-item-120 LC-item-120; do
    ./submit-experiment.sh -m qwen3coder-30b -p "$P" -r 0:21
done
# Output: experiments/qwen3coder-30b/submit-in-rules/{HC-gpt,LC-gpt,...}/r00-r20/
```

This submits 8 personalities × 21 rounds = **168 SLURM jobs**.

## Basic Usage

```bash
./submit-experiment.sh -m MODEL -p PERSONALITY -r START:END
```

## CLI Options & Defaults

**Experiment settings (pass via CLI):**

| Option | Short | Default | Description |
|--------|-------|---------|-------------|
| `--model` | `-m` | `qwen3coder-30b` | Model config name |
| `--personality` | `-p` | `NOP` | Personality prompt |
| `--instruction` | `-i` | `submit-in-rules` | Instruction template |
| `--rounds` | `-r` | `0:1` | Round range (START:END, exclusive) |
| `--tasks` | `-t` | 60-task set | Instance filter regex |
| `--output` | `-o` | `experiments` | Base output dir (full: base/MODEL/INSTRUCTION/PERSONALITY) |
| `--dry-run` | | | Preview without submitting |

**Model-specific settings (from model config, can override):**

| Option | Description |
|--------|-------------|
| `--temperature` | Override model temperature |
| `--step-limit` | Override max agent steps |
| `--timeout` | Override command timeout (seconds) |
| `--time-limit` | Override SLURM time limit |

These defaults are set in model config files (`exp_configs/models/*.conf`):

| Model | Temperature | Step Limit | Timeout | Time Limit |
|-------|-------------|------------|---------|------------|
| `qwen3coder-30b` | 0.0 | 80 | 30s | 02:00:00 |
| `gptoss-120b` | 0.0 | 80 | 30s | 04:00:00 |
| `devstral-small` | 0.0 | 80 | 30s | 02:00:00 |

## Available Options

```bash
./submit-experiment.sh --list-models        # qwen3coder-30b, gptoss-120b, devstral-small
./submit-experiment.sh --list-personalities # NOP, HC-gpt, LC-gpt, HC-p2, LC-p2, ...
./submit-experiment.sh --list-instructions  # submit-in-rules, submit-as-tool
```

## Examples

### Single experiment (1 round)
```bash
./submit-experiment.sh -m qwen3coder-30b -p HC-gpt
```

### Multiple rounds
```bash
./submit-experiment.sh -m qwen3coder-30b -p HC-gpt -r 0:21   # 21 runs (r00-r20)
```

### Batch submission: All conscientiousness prompts
```bash
for P in HC-gpt LC-gpt HC-p2 LC-p2 HC-p2-modify LC-p2-modify HC-item-120 LC-item-120; do
    ./submit-experiment.sh -m qwen3coder-30b -p "$P" -r 0:21 \
        -o "experiments/qwen3coder-30b/${P}"
done
```

### Custom task filter
```bash
./submit-experiment.sh -m qwen3coder-30b -p HC-gpt \
    -t '^(django__django-11951|django__django-11603)$' -r 0:5
```

### Multi-GPU model
```bash
./submit-experiment.sh -m gptoss-120b -p HC-gpt -r 0:5 --time-limit 04:00:00
```

### Preview without submitting
```bash
./submit-experiment.sh -m qwen3coder-30b -p HC-gpt -r 0:21 --dry-run
```

## Personalities

| Trait | High | Low |
|-------|------|-----|
| Conscientiousness (GPT) | `HC-gpt` | `LC-gpt` |
| Conscientiousness (P2) | `HC-p2` | `LC-p2` |
| Conscientiousness (P2 modified) | `HC-p2-modify` | `LC-p2-modify` |
| Conscientiousness (Item-120) | `HC-item-120` | `LC-item-120` |
| Agreeableness | `HA` | `LA` |
| Extraversion | `HE` | `LE` |
| Openness | `HO` | `LO` |
| Baseline (no personality) | `NOP` | - |

## Output Structure

```
experiments/{model}/{personality}/{instruction}/r{NN}/
    instance_1/
    instance_2/
    ...

slurm_outputs/job_results_{SLURM_JOB_ID}/
    config.yaml          # Generated config
    vllm_server.log      # vLLM logs
    vllm_endpoint.txt    # Endpoint URL
```

## Full Documentation

See [docs/experiment-submission.md](docs/experiment-submission.md) for detailed documentation on:
- Adding new models
- Adding new personalities
- Adding new instruction templates
- Troubleshooting
