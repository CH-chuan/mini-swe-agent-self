"""Tests for generated config validation."""

import re

import pytest
import yaml

from .conftest import substitute_template


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
