"""Comprehensive tests for all personality/instruction combinations."""

import re

import pytest
import yaml

from .conftest import (
    substitute_template,
    get_personality_files,
    get_instruction_files,
    get_model_configs,
    parse_model_config,
    PROJECT_ROOT,
)


# Get all available files for parametrization
def get_all_personalities(templates_dir):
    """Get list of personality names from files."""
    files = get_personality_files(templates_dir)
    return [f.stem for f in files]


def get_all_instructions(templates_dir):
    """Get list of instruction names from files."""
    files = get_instruction_files(templates_dir)
    return [f.stem for f in files]


def get_all_models(models_dir):
    """Get list of model names from files."""
    files = get_model_configs(models_dir)
    return [f.stem for f in files]


# Fixtures to get dynamic lists
@pytest.fixture
def personality_names(templates_dir):
    """Get all personality names."""
    return get_all_personalities(templates_dir)


@pytest.fixture
def instruction_names(templates_dir):
    """Get all instruction names."""
    return get_all_instructions(templates_dir)


@pytest.fixture
def model_names(models_conf_dir):
    """Get all model names."""
    return get_all_models(models_conf_dir)


class TestAllPersonalityInstructionCombinations:
    """Test all combinations of personality and instruction generate valid configs."""

    @pytest.mark.slow
    def test_all_combinations_generate_valid_yaml(self, templates_dir, base_template_content):
        """Test that all personality × instruction combinations produce valid YAML."""
        personalities = get_all_personalities(templates_dir)
        instructions = get_all_instructions(templates_dir)

        failures = []

        for personality in personalities:
            personality_file = templates_dir / "personality" / f"{personality}.txt"
            personality_content = personality_file.read_text()

            for instruction in instructions:
                instruction_file = templates_dir / "instructions" / f"{instruction}.txt"
                instruction_content = instruction_file.read_text()

                env_vars = {
                    "PERSONALITY_PROMPT": personality_content,
                    "INSTANCE_TEMPLATE": instruction_content,
                    "TEMPERATURE": "0.0",
                    "STEP_LIMIT": "80",
                    "TIMEOUT": "30",
                    "SERVED_MODEL_NAME": "Test-Model",
                    "VLLM_ENDPOINT": "http://localhost:8000/v1",
                }

                try:
                    result = substitute_template(base_template_content, env_vars)
                    config = yaml.safe_load(result)

                    # Basic validation
                    assert config is not None
                    assert "agent" in config
                    assert "environment" in config
                    assert "model" in config

                except Exception as e:
                    failures.append(f"{personality} + {instruction}: {e}")

        if failures:
            pytest.fail(f"Failed combinations:\n" + "\n".join(failures))

    @pytest.mark.slow
    def test_all_combinations_no_leftover_variables(self, templates_dir, base_template_content):
        """Test that all combinations have no leftover ${VAR} patterns."""
        personalities = get_all_personalities(templates_dir)
        instructions = get_all_instructions(templates_dir)

        failures = []

        for personality in personalities:
            personality_file = templates_dir / "personality" / f"{personality}.txt"
            personality_content = personality_file.read_text()

            for instruction in instructions:
                instruction_file = templates_dir / "instructions" / f"{instruction}.txt"
                instruction_content = instruction_file.read_text()

                env_vars = {
                    "PERSONALITY_PROMPT": personality_content,
                    "INSTANCE_TEMPLATE": instruction_content,
                    "TEMPERATURE": "0.0",
                    "STEP_LIMIT": "80",
                    "TIMEOUT": "30",
                    "SERVED_MODEL_NAME": "Test-Model",
                    "VLLM_ENDPOINT": "http://localhost:8000/v1",
                }

                result = substitute_template(base_template_content, env_vars)
                leftover = re.findall(r'\$\{[A-Z_][A-Z0-9_]*\}', result)

                if leftover:
                    failures.append(f"{personality} + {instruction}: leftover vars {leftover}")

        if failures:
            pytest.fail(f"Found leftover variables:\n" + "\n".join(failures))


class TestAllModelPersonalityCombinations:
    """Test all model × personality combinations."""

    @pytest.mark.slow
    def test_all_model_personality_combinations(self, templates_dir, models_conf_dir, base_template_content):
        """Test that all model × personality combinations produce valid configs."""
        personalities = get_all_personalities(templates_dir)
        models = get_all_models(models_conf_dir)

        failures = []
        # Use a default instruction for this test
        instruction_file = templates_dir / "instructions" / "submit-in-rules.txt"
        if not instruction_file.exists():
            instruction_files = list((templates_dir / "instructions").glob("*.txt"))
            if instruction_files:
                instruction_file = instruction_files[0]
            else:
                pytest.skip("No instruction files found")

        instruction_content = instruction_file.read_text()

        for model in models:
            model_file = models_conf_dir / f"{model}.conf"
            model_config = parse_model_config(model_file)

            for personality in personalities:
                personality_file = templates_dir / "personality" / f"{personality}.txt"
                personality_content = personality_file.read_text()

                env_vars = {
                    "PERSONALITY_PROMPT": personality_content,
                    "INSTANCE_TEMPLATE": instruction_content,
                    "TEMPERATURE": model_config.get("TEMPERATURE", "0.0"),
                    "STEP_LIMIT": "80",
                    "TIMEOUT": "30",
                    "SERVED_MODEL_NAME": model_config.get("SERVED_MODEL_NAME", "Test"),
                    "VLLM_ENDPOINT": "http://localhost:8000/v1",
                }

                try:
                    result = substitute_template(base_template_content, env_vars)
                    config = yaml.safe_load(result)

                    assert config is not None
                    assert config["model"]["model_name"] == model_config.get("SERVED_MODEL_NAME", "Test")

                except Exception as e:
                    failures.append(f"{model} + {personality}: {e}")

        if failures:
            pytest.fail(f"Failed model+personality combinations:\n" + "\n".join(failures))


class TestConscientiousnessVariants:
    """Test all conscientiousness personality variants specifically."""

    CONSCIENTIOUSNESS_VARIANTS = [
        "HC-gpt", "LC-gpt",
        "HC-p2", "LC-p2",
        "HC-p2-modify", "LC-p2-modify",
        "HC-item-120", "LC-item-120",
    ]

    @pytest.mark.parametrize("personality", CONSCIENTIOUSNESS_VARIANTS)
    def test_conscientiousness_variant_valid(self, personality, templates_dir, base_template_content):
        """Test each conscientiousness variant produces valid config."""
        personality_file = templates_dir / "personality" / f"{personality}.txt"
        if not personality_file.exists():
            pytest.skip(f"Personality file not found: {personality}")

        personality_content = personality_file.read_text()
        instruction_file = templates_dir / "instructions" / "submit-in-rules.txt"
        instruction_content = instruction_file.read_text() if instruction_file.exists() else "    Test: {{task}}"

        env_vars = {
            "PERSONALITY_PROMPT": personality_content,
            "INSTANCE_TEMPLATE": instruction_content,
            "TEMPERATURE": "0.0",
            "STEP_LIMIT": "80",
            "TIMEOUT": "30",
            "SERVED_MODEL_NAME": "Test-Model",
            "VLLM_ENDPOINT": "http://localhost:8000/v1",
        }

        result = substitute_template(base_template_content, env_vars)
        config = yaml.safe_load(result)

        assert config is not None
        system_template = config["agent"]["system_template"]

        # Verify personality content is in the system template
        if personality != "NOP" and personality_content.strip():
            # At least some part of the personality should be in the template
            first_line = personality_content.strip().split("\n")[0][:50]  # First 50 chars of first line
            assert first_line in system_template or personality_content[:20] in system_template


class TestBigFiveTraits:
    """Test Big Five personality trait variants."""

    BIG_FIVE_PAIRS = [
        ("HA", "LA"),  # Agreeableness
        ("HE", "LE"),  # Extraversion
        ("HO", "LO"),  # Openness
    ]

    @pytest.mark.parametrize("high_trait,low_trait", BIG_FIVE_PAIRS)
    def test_big_five_trait_pair(self, high_trait, low_trait, templates_dir, base_template_content):
        """Test that Big Five trait pairs produce valid configs."""
        for trait in [high_trait, low_trait]:
            personality_file = templates_dir / "personality" / f"{trait}.txt"
            if not personality_file.exists():
                pytest.skip(f"Personality file not found: {trait}")

            personality_content = personality_file.read_text()
            instruction_content = "    Please solve: {{task}}\n\n    Submit: COMPLETE_TASK_AND_SUBMIT_FINAL_OUTPUT"

            env_vars = {
                "PERSONALITY_PROMPT": personality_content,
                "INSTANCE_TEMPLATE": instruction_content,
                "TEMPERATURE": "0.0",
                "STEP_LIMIT": "80",
                "TIMEOUT": "30",
                "SERVED_MODEL_NAME": "Test-Model",
                "VLLM_ENDPOINT": "http://localhost:8000/v1",
            }

            result = substitute_template(base_template_content, env_vars)
            config = yaml.safe_load(result)

            assert config is not None
            assert "agent" in config


class TestInstructionVariants:
    """Test instruction template variants."""

    @pytest.mark.parametrize("instruction", ["submit-in-rules", "submit-as-tool"])
    def test_instruction_variant_valid(self, instruction, templates_dir, base_template_content):
        """Test each instruction variant produces valid config."""
        instruction_file = templates_dir / "instructions" / f"{instruction}.txt"
        if not instruction_file.exists():
            pytest.skip(f"Instruction file not found: {instruction}")

        instruction_content = instruction_file.read_text()

        env_vars = {
            "PERSONALITY_PROMPT": "Test personality.",
            "INSTANCE_TEMPLATE": instruction_content,
            "TEMPERATURE": "0.0",
            "STEP_LIMIT": "80",
            "TIMEOUT": "30",
            "SERVED_MODEL_NAME": "Test-Model",
            "VLLM_ENDPOINT": "http://localhost:8000/v1",
        }

        result = substitute_template(base_template_content, env_vars)
        config = yaml.safe_load(result)

        assert config is not None
        instance_template = config["agent"]["instance_template"]

        # Verify key elements are present
        assert "{{task}}" in instance_template
        assert "COMPLETE_TASK_AND_SUBMIT_FINAL_OUTPUT" in instance_template

    @pytest.mark.parametrize("instruction", ["submit-in-rules", "submit-as-tool"])
    def test_instruction_jinja_preserved(self, instruction, templates_dir, base_template_content):
        """Test that Jinja syntax in instruction templates is preserved."""
        instruction_file = templates_dir / "instructions" / f"{instruction}.txt"
        if not instruction_file.exists():
            pytest.skip(f"Instruction file not found: {instruction}")

        instruction_content = instruction_file.read_text()

        env_vars = {
            "PERSONALITY_PROMPT": "Test.",
            "INSTANCE_TEMPLATE": instruction_content,
            "TEMPERATURE": "0.0",
            "STEP_LIMIT": "80",
            "TIMEOUT": "30",
            "SERVED_MODEL_NAME": "Test-Model",
            "VLLM_ENDPOINT": "http://localhost:8000/v1",
        }

        result = substitute_template(base_template_content, env_vars)

        # Jinja patterns should remain
        assert "{{task}}" in result
        # action_observation_template Jinja should also remain
        assert "{{output.returncode}}" in result or "{{ output.returncode }}" in result
