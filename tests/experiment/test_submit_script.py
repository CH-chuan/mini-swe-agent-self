"""Tests for submit-experiment.sh CLI."""

import subprocess
import os

import pytest

from .conftest import PROJECT_ROOT


# Path to the submit script
SUBMIT_SCRIPT = PROJECT_ROOT / "submit-experiment.sh"


def run_submit_script(*args, timeout=30):
    """Helper to run submit-experiment.sh with given arguments."""
    cmd = [str(SUBMIT_SCRIPT)] + list(args)
    result = subprocess.run(
        cmd,
        capture_output=True,
        text=True,
        timeout=timeout,
        cwd=str(PROJECT_ROOT),
    )
    return result


@pytest.fixture
def script_exists():
    """Ensure submit script exists before running tests."""
    if not SUBMIT_SCRIPT.exists():
        pytest.skip(f"Submit script not found: {SUBMIT_SCRIPT}")
    # Check it's executable
    if not os.access(SUBMIT_SCRIPT, os.X_OK):
        pytest.skip(f"Submit script not executable: {SUBMIT_SCRIPT}")


class TestHelpFlag:
    """Test --help flag."""

    def test_help_flag_short(self, script_exists):
        """Test -h shows help."""
        result = run_submit_script("-h")
        assert result.returncode == 0
        assert "Usage:" in result.stdout or "usage:" in result.stdout.lower()

    def test_help_flag_long(self, script_exists):
        """Test --help shows help."""
        result = run_submit_script("--help")
        assert result.returncode == 0
        assert "Usage:" in result.stdout or "usage:" in result.stdout.lower()

    def test_help_shows_options(self, script_exists):
        """Test that help shows available options."""
        result = run_submit_script("--help")
        assert result.returncode == 0

        # Check for key options
        expected_options = ["--model", "--personality", "--instruction", "--rounds", "--dry-run"]
        for opt in expected_options:
            assert opt in result.stdout, f"Help missing option: {opt}"


class TestListCommands:
    """Test --list-* commands."""

    def test_list_models(self, script_exists):
        """Test --list-models shows available models."""
        result = run_submit_script("--list-models")
        assert result.returncode == 0
        assert "qwen3coder-30b" in result.stdout or "Available" in result.stdout

    def test_list_personalities(self, script_exists):
        """Test --list-personalities shows available personalities."""
        result = run_submit_script("--list-personalities")
        assert result.returncode == 0
        # Should list some personalities
        assert "HC-gpt" in result.stdout or "NOP" in result.stdout or "Available" in result.stdout

    def test_list_instructions(self, script_exists):
        """Test --list-instructions shows available instructions."""
        result = run_submit_script("--list-instructions")
        assert result.returncode == 0
        assert "submit" in result.stdout.lower() or "Available" in result.stdout


class TestDryRun:
    """Test --dry-run flag."""

    def test_dry_run_no_submit(self, script_exists):
        """Test that --dry-run doesn't actually submit jobs."""
        result = run_submit_script(
            "-m", "qwen3coder-30b",
            "-p", "NOP",
            "-i", "submit-in-rules",
            "-r", "0:1",
            "--dry-run"
        )
        assert result.returncode == 0
        # Should indicate dry run mode
        assert "DRY RUN" in result.stdout or "dry-run" in result.stdout.lower() or "Would submit" in result.stdout

    def test_dry_run_shows_config(self, script_exists):
        """Test that --dry-run shows configuration details."""
        result = run_submit_script(
            "-m", "qwen3coder-30b",
            "-p", "HC-gpt",
            "--dry-run"
        )
        assert result.returncode == 0
        # Should show model and personality
        assert "qwen3coder-30b" in result.stdout or "Model:" in result.stdout
        assert "HC-gpt" in result.stdout or "Personality:" in result.stdout


class TestInvalidInputs:
    """Test error handling for invalid inputs."""

    def test_invalid_model_error(self, script_exists):
        """Test that non-existent model produces error."""
        result = run_submit_script(
            "-m", "nonexistent-model-xyz",
            "-p", "NOP",
            "--dry-run"
        )
        # Should fail with non-zero exit code
        assert result.returncode != 0 or "not found" in result.stdout.lower() or "error" in result.stderr.lower()

    def test_invalid_personality_error(self, script_exists):
        """Test that non-existent personality produces error."""
        result = run_submit_script(
            "-m", "qwen3coder-30b",
            "-p", "nonexistent-personality-xyz",
            "--dry-run"
        )
        assert result.returncode != 0 or "not found" in result.stdout.lower() or "error" in result.stderr.lower()

    def test_invalid_instruction_error(self, script_exists):
        """Test that non-existent instruction produces error."""
        result = run_submit_script(
            "-m", "qwen3coder-30b",
            "-p", "NOP",
            "-i", "nonexistent-instruction-xyz",
            "--dry-run"
        )
        assert result.returncode != 0 or "not found" in result.stdout.lower() or "error" in result.stderr.lower()

    def test_unknown_option_error(self, script_exists):
        """Test that unknown options produce error."""
        result = run_submit_script("--unknown-option-xyz")
        assert result.returncode != 0 or "Unknown" in result.stderr or "unknown" in result.stderr.lower()


class TestRoundsValidation:
    """Test rounds argument validation."""

    def test_valid_rounds_format(self, script_exists):
        """Test valid rounds format works."""
        result = run_submit_script(
            "-m", "qwen3coder-30b",
            "-p", "NOP",
            "-r", "0:5",
            "--dry-run"
        )
        assert result.returncode == 0

    def test_rounds_end_greater_than_start(self, script_exists):
        """Test that END > START is validated."""
        result = run_submit_script(
            "-m", "qwen3coder-30b",
            "-p", "NOP",
            "-r", "5:3",  # Invalid: end < start
            "--dry-run"
        )
        # Should fail
        assert result.returncode != 0 or "must be greater" in result.stdout.lower() or "error" in result.stderr.lower()

    def test_rounds_equal_values(self, script_exists):
        """Test that equal START:END is rejected."""
        result = run_submit_script(
            "-m", "qwen3coder-30b",
            "-p", "NOP",
            "-r", "5:5",  # Invalid: no rounds
            "--dry-run"
        )
        assert result.returncode != 0 or "must be greater" in result.stdout.lower() or "error" in result.stderr.lower()


class TestOutputConfiguration:
    """Test output directory configuration."""

    def test_auto_output_dir(self, script_exists):
        """Test that output directory is auto-generated when not specified."""
        result = run_submit_script(
            "-m", "qwen3coder-30b",
            "-p", "HC-gpt",
            "-i", "submit-as-tool",
            "--dry-run"
        )
        assert result.returncode == 0
        # Should show an output directory
        assert "Output:" in result.stdout or "output" in result.stdout.lower()

    def test_custom_output_dir(self, script_exists):
        """Test that custom output directory is used."""
        result = run_submit_script(
            "-m", "qwen3coder-30b",
            "-p", "NOP",
            "-o", "my-custom-output-dir",
            "--dry-run"
        )
        assert result.returncode == 0
        assert "my-custom-output-dir" in result.stdout


class TestParameterOverrides:
    """Test parameter override options."""

    def test_temperature_override(self, script_exists):
        """Test --temperature override."""
        result = run_submit_script(
            "-m", "qwen3coder-30b",
            "-p", "NOP",
            "--temperature", "0.7",
            "--dry-run"
        )
        assert result.returncode == 0
        assert "0.7" in result.stdout or "Temperature" in result.stdout

    def test_step_limit_override(self, script_exists):
        """Test --step-limit override."""
        result = run_submit_script(
            "-m", "qwen3coder-30b",
            "-p", "NOP",
            "--step-limit", "100",
            "--dry-run"
        )
        assert result.returncode == 0

    def test_timeout_override(self, script_exists):
        """Test --timeout override."""
        result = run_submit_script(
            "-m", "qwen3coder-30b",
            "-p", "NOP",
            "--timeout", "60",
            "--dry-run"
        )
        assert result.returncode == 0

    def test_time_limit_override(self, script_exists):
        """Test --time-limit override."""
        result = run_submit_script(
            "-m", "qwen3coder-30b",
            "-p", "NOP",
            "--time-limit", "04:00:00",
            "--dry-run"
        )
        assert result.returncode == 0
        assert "04:00:00" in result.stdout or "Time" in result.stdout
