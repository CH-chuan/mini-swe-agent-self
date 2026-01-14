"""Tests for generated config validation."""

import re
from pathlib import Path

import pytest
import yaml

from .conftest import substitute_template, get_personality_files, get_instruction_files


class TestGeneratedConfigValidity:
    """Test that generated configs are valid YAML."""

    def test_generated_config_valid_yaml(self, base_template_content, sample_env_vars):
        """Test that substituted template produces valid YAML."""
        result = substitute_template(base_template_content, sample_env_vars)

        # Should not raise any exceptions
        config = yaml.safe_load(result)
        assert config is not None
        assert isinstance(config, dict)

    def test_generated_config_has_required_sections(self, base_template_content, sample_env_vars):
        """Test that generated config has all required top-level sections."""
        result = substitute_template(base_template_content, sample_env_vars)
        config = yaml.safe_load(result)

        required_sections = ["agent", "environment", "model"]
        for section in required_sections:
            assert section in config, f"Missing required section: {section}"

    def test_agent_section_structure(self, base_template_content, sample_env_vars):
        """Test that agent section has required keys."""
        result = substitute_template(base_template_content, sample_env_vars)
        config = yaml.safe_load(result)

        agent = config["agent"]
        required_keys = [
            "system_template",
            "instance_template",
            "action_observation_template",
            "format_error_template",
            "step_limit",
            "cost_limit",
        ]
        for key in required_keys:
            assert key in agent, f"Missing agent key: {key}"

    def test_environment_section_structure(self, base_template_content, sample_env_vars):
        """Test that environment section has required keys."""
        result = substitute_template(base_template_content, sample_env_vars)
        config = yaml.safe_load(result)

        env = config["environment"]
        assert "environment_class" in env
        assert "cwd" in env
        assert "timeout" in env
        assert env["environment_class"] == "singularity"

    def test_model_section_structure(self, base_template_content, sample_env_vars):
        """Test that model section has required keys."""
        result = substitute_template(base_template_content, sample_env_vars)
        config = yaml.safe_load(result)

        model = config["model"]
        assert "model_name" in model
        assert "model_kwargs" in model
        assert "api_base" in model["model_kwargs"]


class TestConfigValues:
    """Test that config values are correctly substituted."""

    def test_temperature_value(self, base_template_content, sample_env_vars):
        """Test that TEMPERATURE is correctly substituted."""
        result = substitute_template(base_template_content, sample_env_vars)
        config = yaml.safe_load(result)

        # YAML should parse "0.0" as float 0.0
        temp = config["model"]["model_kwargs"]["temperature"]
        assert temp == 0.0 or temp == "0.0"

    def test_step_limit_value(self, base_template_content, sample_env_vars):
        """Test that STEP_LIMIT is correctly substituted."""
        result = substitute_template(base_template_content, sample_env_vars)
        config = yaml.safe_load(result)

        step_limit = config["agent"]["step_limit"]
        assert step_limit == 80 or step_limit == "80"

    def test_timeout_value(self, base_template_content, sample_env_vars):
        """Test that TIMEOUT is correctly substituted."""
        result = substitute_template(base_template_content, sample_env_vars)
        config = yaml.safe_load(result)

        timeout = config["environment"]["timeout"]
        assert timeout == 30 or timeout == "30"

    def test_model_name_value(self, base_template_content, sample_env_vars):
        """Test that SERVED_MODEL_NAME is correctly substituted."""
        result = substitute_template(base_template_content, sample_env_vars)
        config = yaml.safe_load(result)

        model_name = config["model"]["model_name"]
        assert model_name == "Test-Model"

    def test_vllm_endpoint_value(self, base_template_content, sample_env_vars):
        """Test that VLLM_ENDPOINT is correctly substituted."""
        result = substitute_template(base_template_content, sample_env_vars)
        config = yaml.safe_load(result)

        api_base = config["model"]["model_kwargs"]["api_base"]
        assert api_base == "http://localhost:8000/v1"


class TestPersonalityPromptIntegration:
    """Test personality prompt integration in generated config."""

    def test_personality_prompt_in_system_template(self, base_template_content, sample_env_vars):
        """Test that personality prompt appears in system_template."""
        result = substitute_template(base_template_content, sample_env_vars)
        config = yaml.safe_load(result)

        system_template = config["agent"]["system_template"]
        assert "You are a test personality" in system_template
        assert "multi-line prompt" in system_template

    def test_empty_personality_prompt(self, base_template_content):
        """Test config with empty personality prompt (NOP)."""
        env_vars = {
            "PERSONALITY_PROMPT": "",
            "INSTANCE_TEMPLATE": "    Please solve: {{task}}",
            "TEMPERATURE": "0.0",
            "STEP_LIMIT": "80",
            "TIMEOUT": "30",
            "SERVED_MODEL_NAME": "Test-Model",
            "VLLM_ENDPOINT": "http://localhost:8000/v1",
        }
        result = substitute_template(base_template_content, env_vars)
        config = yaml.safe_load(result)

        # Should still be valid YAML
        assert config is not None
        system_template = config["agent"]["system_template"]
        # Base template content should still be present
        assert "You are a helpful assistant" in system_template

    def test_multiline_personality_preserved(self, base_template_content):
        """Test that multi-line personality prompt preserves all lines."""
        # Personality content needs 4-space indentation for YAML literal block
        personality = """    Line 1 of personality.
    Line 2 of personality.
    Line 3 of personality."""

        env_vars = {
            "PERSONALITY_PROMPT": personality,
            "INSTANCE_TEMPLATE": "    Please solve: {{task}}",
            "TEMPERATURE": "0.0",
            "STEP_LIMIT": "80",
            "TIMEOUT": "30",
            "SERVED_MODEL_NAME": "Test-Model",
            "VLLM_ENDPOINT": "http://localhost:8000/v1",
        }
        result = substitute_template(base_template_content, env_vars)
        config = yaml.safe_load(result)

        system_template = config["agent"]["system_template"]
        assert "Line 1 of personality" in system_template
        assert "Line 2 of personality" in system_template
        assert "Line 3 of personality" in system_template


class TestInstanceTemplateIntegration:
    """Test instance template integration in generated config."""

    def test_instance_template_preserved(self, base_template_content, sample_env_vars):
        """Test that instance template content is preserved."""
        result = substitute_template(base_template_content, sample_env_vars)
        config = yaml.safe_load(result)

        instance_template = config["agent"]["instance_template"]
        assert "{{task}}" in instance_template
        assert "instruction template" in instance_template

    def test_jinja_syntax_in_instance_template(self, base_template_content):
        """Test that Jinja syntax in instance_template is preserved."""
        env_vars = {
            "PERSONALITY_PROMPT": "Test personality",
            "INSTANCE_TEMPLATE": "    Please solve this issue: {{task}}\n\n    More content here.",
            "TEMPERATURE": "0.0",
            "STEP_LIMIT": "80",
            "TIMEOUT": "30",
            "SERVED_MODEL_NAME": "Test-Model",
            "VLLM_ENDPOINT": "http://localhost:8000/v1",
        }
        result = substitute_template(base_template_content, env_vars)
        config = yaml.safe_load(result)

        instance_template = config["agent"]["instance_template"]
        assert "{{task}}" in instance_template


class TestNoLeftoverVariables:
    """Test that all required variables are substituted."""

    def test_no_leftover_variable_patterns(self, base_template_content, sample_env_vars):
        """Test that no ${VAR} patterns remain in the generated config."""
        result = substitute_template(base_template_content, sample_env_vars)

        # Find any remaining ${VAR} patterns (uppercase only, as per our regex)
        leftover = re.findall(r'\$\{[A-Z_][A-Z0-9_]*\}', result)
        assert len(leftover) == 0, f"Found leftover variables: {leftover}"

    def test_jinja_patterns_remain(self, base_template_content, sample_env_vars):
        """Test that Jinja {{var}} patterns correctly remain."""
        result = substitute_template(base_template_content, sample_env_vars)

        # These should still be present
        assert "{{task}}" in result or "{{ task }}" in result or "Please solve this issue" in result
        # action_observation_template should have Jinja patterns
        assert "{{output.returncode}}" in result or "{{ output.returncode }}" in result


class TestDifferentTemperatures:
    """Test config generation with different temperature values."""

    @pytest.mark.parametrize("temp", ["0.0", "0.5", "0.7", "1.0"])
    def test_various_temperatures(self, base_template_content, temp):
        """Test that different temperature values produce valid configs."""
        env_vars = {
            "PERSONALITY_PROMPT": "Test",
            "INSTANCE_TEMPLATE": "    Test: {{task}}",
            "TEMPERATURE": temp,
            "STEP_LIMIT": "80",
            "TIMEOUT": "30",
            "SERVED_MODEL_NAME": "Test-Model",
            "VLLM_ENDPOINT": "http://localhost:8000/v1",
        }
        result = substitute_template(base_template_content, env_vars)
        config = yaml.safe_load(result)

        assert config is not None
        model_temp = config["model"]["model_kwargs"]["temperature"]
        # May be parsed as float or string
        assert str(model_temp) == temp or float(model_temp) == float(temp)


class TestRealPersonalityFiles:
    """Test config generation with actual personality template files."""

    @pytest.fixture
    def personality_files(self, templates_dir):
        """Return all personality template files."""
        return get_personality_files(templates_dir)

    @pytest.fixture
    def instruction_files(self, templates_dir):
        """Return all instruction template files."""
        return get_instruction_files(templates_dir)

    def test_all_personalities_produce_valid_yaml(
        self, base_template_content, templates_dir
    ):
        """Test that all personality files produce valid YAML configs."""
        personality_files = get_personality_files(templates_dir)
        instruction_files = get_instruction_files(templates_dir)

        assert len(personality_files) > 0, "No personality files found"
        assert len(instruction_files) > 0, "No instruction files found"

        # Use first instruction file for testing
        instruction_content = instruction_files[0].read_text()

        for personality_file in personality_files:
            personality_content = personality_file.read_text()

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

            # This should not raise any exceptions
            try:
                config = yaml.safe_load(result)
                assert config is not None, f"Config is None for {personality_file.name}"
                assert "agent" in config, f"Missing 'agent' section for {personality_file.name}"
            except yaml.YAMLError as e:
                pytest.fail(f"Invalid YAML for personality '{personality_file.name}': {e}")

    def test_all_instructions_produce_valid_yaml(
        self, base_template_content, templates_dir
    ):
        """Test that all instruction files produce valid YAML configs."""
        personality_files = get_personality_files(templates_dir)
        instruction_files = get_instruction_files(templates_dir)

        assert len(instruction_files) > 0, "No instruction files found"

        # Use first personality file (or empty for NOP)
        personality_content = ""
        for pf in personality_files:
            if pf.stem == "NOP":
                personality_content = pf.read_text()
                break

        for instruction_file in instruction_files:
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

            try:
                config = yaml.safe_load(result)
                assert config is not None, f"Config is None for {instruction_file.name}"
                assert "agent" in config, f"Missing 'agent' section for {instruction_file.name}"
            except yaml.YAMLError as e:
                pytest.fail(f"Invalid YAML for instruction '{instruction_file.name}': {e}")

    @pytest.mark.parametrize("personality_name", [
        "NOP", "HC-gpt", "LC-gpt", "HC-p2", "LC-p2",
        "HC-p2-modify", "LC-p2-modify", "HC-item-120", "LC-item-120",
        "HC-item-300", "LC-item-300",
    ])
    def test_specific_personality_valid_yaml(
        self, base_template_content, templates_dir, personality_name
    ):
        """Test specific personality files produce valid YAML."""
        personality_file = templates_dir / "personality" / f"{personality_name}.txt"
        instruction_file = templates_dir / "instructions" / "submit-in-rules.txt"

        if not personality_file.exists():
            pytest.skip(f"Personality file {personality_name}.txt not found")
        if not instruction_file.exists():
            pytest.skip("Instruction file submit-in-rules.txt not found")

        personality_content = personality_file.read_text()
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

        config = yaml.safe_load(result)
        assert config is not None
        assert "agent" in config
        assert "system_template" in config["agent"]
        assert "instance_template" in config["agent"]

    def test_item_300_personality_content_preserved(
        self, base_template_content, templates_dir
    ):
        """Test that HC-item-300 long content is fully preserved in config."""
        personality_file = templates_dir / "personality" / "HC-item-300.txt"
        instruction_file = templates_dir / "instructions" / "submit-in-rules.txt"

        if not personality_file.exists():
            pytest.skip("HC-item-300.txt not found")

        personality_content = personality_file.read_text()
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
        config = yaml.safe_load(result)

        system_template = config["agent"]["system_template"]
        # Check that key phrases from HC-item-300 are present
        assert "Conscientiousness" in system_template
        assert "Self-Efficacy" in system_template
        assert "Very Accurate" in system_template
