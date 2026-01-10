"""Shared fixtures for experiment submission system tests."""

import os
import re
from pathlib import Path

import pytest


# Project root directory
PROJECT_ROOT = Path(__file__).parent.parent.parent


@pytest.fixture
def project_root() -> Path:
    """Return the project root directory."""
    return PROJECT_ROOT


@pytest.fixture
def templates_dir() -> Path:
    """Return the templates directory path."""
    return PROJECT_ROOT / "exp_configs" / "templates"


@pytest.fixture
def models_conf_dir() -> Path:
    """Return the models config directory path."""
    return PROJECT_ROOT / "exp_configs" / "models"


@pytest.fixture
def base_template_path(templates_dir) -> Path:
    """Return the base.yaml template path."""
    return templates_dir / "base.yaml"


@pytest.fixture
def base_template_content(base_template_path) -> str:
    """Return the content of base.yaml template."""
    return base_template_path.read_text()


@pytest.fixture
def sample_env_vars() -> dict:
    """Return sample environment variables for template substitution."""
    return {
        "PERSONALITY_PROMPT": "    You are a test personality.\n    This is a multi-line prompt.\n",
        "INSTANCE_TEMPLATE": "    Please solve this issue: {{task}}\n\n    This is the instruction template.",
        "TEMPERATURE": "0.0",
        "STEP_LIMIT": "80",
        "TIMEOUT": "30",
        "SERVED_MODEL_NAME": "Test-Model",
        "VLLM_ENDPOINT": "http://localhost:8000/v1",
    }


@pytest.fixture
def all_personality_names() -> list:
    """Return list of all expected personality file names (without .txt extension)."""
    return [
        "NOP",
        "HC-gpt",
        "LC-gpt",
        "HC-p2",
        "LC-p2",
        "HC-p2-modify",
        "LC-p2-modify",
        "HC-item-120",
        "LC-item-120",
        "HA",
        "LA",
        "HE",
        "LE",
        "HO",
        "LO",
    ]


@pytest.fixture
def all_instruction_names() -> list:
    """Return list of all expected instruction file names (without .txt extension)."""
    return [
        "submit-in-rules",
        "submit-as-tool",
    ]


@pytest.fixture
def all_model_names() -> list:
    """Return list of all expected model config names (without .conf extension)."""
    return [
        "qwen3coder-30b",
        "gptoss-120b",
    ]


def substitute_template(template_content: str, env_vars: dict) -> str:
    """
    Replicate the Python substitution logic from experiment.slurm.

    This is the same regex-based substitution used in the SLURM script
    to replace ${VAR} patterns with environment variable values.
    """
    def replace_var(match):
        var_name = match.group(1)
        return env_vars.get(var_name, match.group(0))

    return re.sub(r'\$\{([A-Z_][A-Z0-9_]*)\}', replace_var, template_content)


def get_personality_files(templates_dir: Path) -> list:
    """Return list of personality file paths."""
    personality_dir = templates_dir / "personality"
    if not personality_dir.exists():
        return []
    return list(personality_dir.glob("*.txt"))


def get_instruction_files(templates_dir: Path) -> list:
    """Return list of instruction file paths."""
    instruction_dir = templates_dir / "instructions"
    if not instruction_dir.exists():
        return []
    return list(instruction_dir.glob("*.txt"))


def get_model_configs(models_conf_dir: Path) -> list:
    """Return list of model config file paths."""
    if not models_conf_dir.exists():
        return []
    return list(models_conf_dir.glob("*.conf"))


def parse_model_config(config_path: Path) -> dict:
    """
    Parse a model config file and return variables as a dict.

    Model configs are shell-style KEY=VALUE files.
    """
    config = {}
    content = config_path.read_text()

    for line in content.splitlines():
        line = line.strip()
        # Skip comments and empty lines
        if not line or line.startswith("#"):
            continue

        # Parse KEY=VALUE or KEY="VALUE"
        if "=" in line:
            key, _, value = line.partition("=")
            key = key.strip()
            value = value.strip()
            # Remove quotes if present
            if value.startswith('"') and value.endswith('"'):
                value = value[1:-1]
            elif value.startswith("'") and value.endswith("'"):
                value = value[1:-1]
            config[key] = value

    return config
