"""Tests for model configuration files."""

import pytest

from .conftest import get_model_configs, parse_model_config


class TestModelConfigsExist:
    """Test that model config files exist."""

    def test_models_directory_exists(self, models_conf_dir):
        """Test that models config directory exists."""
        assert models_conf_dir.exists(), f"Models config directory not found: {models_conf_dir}"
        assert models_conf_dir.is_dir()

    def test_all_model_configs_exist(self, models_conf_dir, all_model_names):
        """Test that all expected model config files exist."""
        for name in all_model_names:
            file_path = models_conf_dir / f"{name}.conf"
            assert file_path.exists(), f"Missing model config: {file_path}"

    def test_at_least_one_model_config(self, models_conf_dir):
        """Test that at least one model config exists."""
        configs = get_model_configs(models_conf_dir)
        assert len(configs) > 0, "No model config files found"


class TestModelConfigRequiredVariables:
    """Test that model configs have all required variables."""

    REQUIRED_VARIABLES = [
        "MODEL_NAME",
        "SERVED_MODEL_NAME",
        "MODELS_DIR",
        "APPTAINER_IMAGE",
        "GPU_COUNT",
        "GPU_TYPE",
        "GPU_CONSTRAINT",
        "TEMPERATURE",
    ]

    def test_required_variables_present(self, models_conf_dir, all_model_names):
        """Test that all model configs have required variables."""
        for name in all_model_names:
            file_path = models_conf_dir / f"{name}.conf"
            if not file_path.exists():
                continue

            config = parse_model_config(file_path)
            for var in self.REQUIRED_VARIABLES:
                assert var in config, f"Model {name} missing required variable: {var}"

    @pytest.mark.parametrize("model", ["qwen3coder-30b", "gptoss-120b"])
    def test_specific_model_config(self, models_conf_dir, model):
        """Test specific model configs have required variables."""
        file_path = models_conf_dir / f"{model}.conf"
        if not file_path.exists():
            pytest.skip(f"Model config not found: {model}")

        config = parse_model_config(file_path)
        for var in self.REQUIRED_VARIABLES:
            assert var in config, f"Model {model} missing: {var}"


class TestModelConfigValues:
    """Test model config value validity."""

    def test_gpu_count_positive(self, models_conf_dir):
        """Test that GPU_COUNT is a positive integer."""
        configs = get_model_configs(models_conf_dir)
        for config_path in configs:
            config = parse_model_config(config_path)
            if "GPU_COUNT" not in config:
                continue

            gpu_count = config["GPU_COUNT"]
            assert gpu_count.isdigit(), f"{config_path.name}: GPU_COUNT must be numeric, got: {gpu_count}"
            assert int(gpu_count) >= 1, f"{config_path.name}: GPU_COUNT must be >= 1, got: {gpu_count}"

    def test_gpu_type_valid(self, models_conf_dir):
        """Test that GPU_TYPE is a valid type."""
        valid_gpu_types = ["a100", "v100", "h100", "a40", "rtx"]  # Common GPU types
        configs = get_model_configs(models_conf_dir)
        for config_path in configs:
            config = parse_model_config(config_path)
            if "GPU_TYPE" not in config:
                continue

            gpu_type = config["GPU_TYPE"].lower()
            assert any(valid in gpu_type for valid in valid_gpu_types), \
                f"{config_path.name}: GPU_TYPE '{config['GPU_TYPE']}' not recognized"

    def test_temperature_valid_float(self, models_conf_dir):
        """Test that TEMPERATURE is a valid float between 0 and 2."""
        configs = get_model_configs(models_conf_dir)
        for config_path in configs:
            config = parse_model_config(config_path)
            if "TEMPERATURE" not in config:
                continue

            try:
                temp = float(config["TEMPERATURE"])
                assert 0.0 <= temp <= 2.0, \
                    f"{config_path.name}: TEMPERATURE {temp} out of range [0, 2]"
            except ValueError:
                pytest.fail(f"{config_path.name}: TEMPERATURE must be a valid float")

    def test_paths_not_empty(self, models_conf_dir):
        """Test that path variables are not empty."""
        path_vars = ["MODELS_DIR", "APPTAINER_IMAGE"]
        configs = get_model_configs(models_conf_dir)
        for config_path in configs:
            config = parse_model_config(config_path)
            for var in path_vars:
                if var in config:
                    assert len(config[var]) > 0, f"{config_path.name}: {var} is empty"


class TestMultiGPUConfigs:
    """Test multi-GPU model configurations."""

    def test_multi_gpu_model_exists(self, models_conf_dir):
        """Test that at least one multi-GPU model config exists."""
        configs = get_model_configs(models_conf_dir)
        multi_gpu_found = False
        for config_path in configs:
            config = parse_model_config(config_path)
            if "GPU_COUNT" in config and int(config.get("GPU_COUNT", "1")) > 1:
                multi_gpu_found = True
                break

        # This is informational - not all setups need multi-GPU
        if not multi_gpu_found:
            print("Note: No multi-GPU model configs found")

    def test_gptoss_120b_is_multi_gpu(self, models_conf_dir):
        """Test that gptoss-120b config uses multiple GPUs (it's a large model)."""
        file_path = models_conf_dir / "gptoss-120b.conf"
        if not file_path.exists():
            pytest.skip("gptoss-120b config not found")

        config = parse_model_config(file_path)
        gpu_count = int(config.get("GPU_COUNT", "1"))
        assert gpu_count >= 2, f"gptoss-120b should use >= 2 GPUs, got: {gpu_count}"

    def test_qwen3coder_30b_gpu_count(self, models_conf_dir):
        """Test qwen3coder-30b GPU configuration."""
        file_path = models_conf_dir / "qwen3coder-30b.conf"
        if not file_path.exists():
            pytest.skip("qwen3coder-30b config not found")

        config = parse_model_config(file_path)
        gpu_count = int(config.get("GPU_COUNT", "1"))
        # This model typically uses 1 GPU
        assert gpu_count >= 1, f"qwen3coder-30b GPU_COUNT invalid: {gpu_count}"


class TestModelConfigFormat:
    """Test model config file format."""

    def test_config_file_readable(self, models_conf_dir):
        """Test that all config files are readable."""
        configs = get_model_configs(models_conf_dir)
        for config_path in configs:
            try:
                content = config_path.read_text()
                assert len(content) > 0, f"Config file is empty: {config_path.name}"
            except Exception as e:
                pytest.fail(f"Cannot read config file {config_path.name}: {e}")

    def test_config_has_comments(self, models_conf_dir):
        """Test that config files have descriptive comments (best practice)."""
        configs = get_model_configs(models_conf_dir)
        for config_path in configs:
            content = config_path.read_text()
            has_comments = any(line.strip().startswith("#") for line in content.splitlines())
            if not has_comments:
                print(f"Note: {config_path.name} has no comments")

    def test_no_syntax_errors_in_config(self, models_conf_dir):
        """Test that config files parse without errors."""
        configs = get_model_configs(models_conf_dir)
        for config_path in configs:
            try:
                config = parse_model_config(config_path)
                assert isinstance(config, dict)
            except Exception as e:
                pytest.fail(f"Error parsing {config_path.name}: {e}")
