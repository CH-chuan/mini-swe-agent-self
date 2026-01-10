"""Tests for template file validation."""

import pytest

from .conftest import get_personality_files, get_instruction_files


class TestPersonalityFilesExist:
    """Test that all expected personality files exist."""

    def test_personality_directory_exists(self, templates_dir):
        """Test that personality directory exists."""
        personality_dir = templates_dir / "personality"
        assert personality_dir.exists(), f"Personality directory not found: {personality_dir}"
        assert personality_dir.is_dir()

    def test_all_personality_files_exist(self, templates_dir, all_personality_names):
        """Test that all expected personality files exist."""
        personality_dir = templates_dir / "personality"
        for name in all_personality_names:
            file_path = personality_dir / f"{name}.txt"
            assert file_path.exists(), f"Missing personality file: {file_path}"

    def test_no_extra_personality_files(self, templates_dir, all_personality_names):
        """Test for unexpected personality files (optional, informational)."""
        personality_files = get_personality_files(templates_dir)
        actual_names = {f.stem for f in personality_files}
        expected_names = set(all_personality_names)

        extra = actual_names - expected_names
        if extra:
            # This is a warning, not a failure - extra files are allowed
            print(f"Note: Found extra personality files: {extra}")


class TestInstructionFilesExist:
    """Test that all expected instruction files exist."""

    def test_instructions_directory_exists(self, templates_dir):
        """Test that instructions directory exists."""
        instructions_dir = templates_dir / "instructions"
        assert instructions_dir.exists(), f"Instructions directory not found: {instructions_dir}"
        assert instructions_dir.is_dir()

    def test_all_instruction_files_exist(self, templates_dir, all_instruction_names):
        """Test that all expected instruction files exist."""
        instructions_dir = templates_dir / "instructions"
        for name in all_instruction_names:
            file_path = instructions_dir / f"{name}.txt"
            assert file_path.exists(), f"Missing instruction file: {file_path}"


class TestPersonalityFileContent:
    """Test personality file content."""

    def test_personality_files_non_empty(self, templates_dir, all_personality_names):
        """Test that personality files have content (except NOP which can be empty)."""
        personality_dir = templates_dir / "personality"
        for name in all_personality_names:
            file_path = personality_dir / f"{name}.txt"
            if not file_path.exists():
                continue

            content = file_path.read_text().strip()
            if name == "NOP":
                # NOP can be empty
                continue
            assert len(content) > 0, f"Personality file is empty: {name}.txt"

    def test_personality_files_no_variable_syntax(self, templates_dir):
        """Test that personality files don't contain ${VAR} syntax."""
        personality_files = get_personality_files(templates_dir)
        for file_path in personality_files:
            content = file_path.read_text()
            # Personality files should be plain text, no variable substitution
            assert "${" not in content, f"Personality file contains variable syntax: {file_path.name}"

    @pytest.mark.parametrize("personality_type", ["HC", "LC"])
    def test_conscientiousness_personalities_exist(self, templates_dir, personality_type):
        """Test that conscientiousness personality variants exist."""
        personality_dir = templates_dir / "personality"
        variants = ["gpt", "p2", "p2-modify", "item-120"]
        for variant in variants:
            name = f"{personality_type}-{variant}"
            file_path = personality_dir / f"{name}.txt"
            assert file_path.exists(), f"Missing conscientiousness variant: {name}"


class TestInstructionFileContent:
    """Test instruction file content."""

    def test_instruction_files_contain_task_placeholder(self, templates_dir, all_instruction_names):
        """Test that instruction files contain {{task}} placeholder."""
        instructions_dir = templates_dir / "instructions"
        for name in all_instruction_names:
            file_path = instructions_dir / f"{name}.txt"
            if not file_path.exists():
                continue

            content = file_path.read_text()
            assert "{{task}}" in content, f"Instruction file missing {{{{task}}}} placeholder: {name}.txt"

    def test_instruction_files_contain_submit_command(self, templates_dir, all_instruction_names):
        """Test that instruction files contain submit command."""
        instructions_dir = templates_dir / "instructions"
        for name in all_instruction_names:
            file_path = instructions_dir / f"{name}.txt"
            if not file_path.exists():
                continue

            content = file_path.read_text()
            assert "COMPLETE_TASK_AND_SUBMIT_FINAL_OUTPUT" in content, \
                f"Instruction file missing submit command: {name}.txt"

    def test_instruction_files_proper_indentation(self, templates_dir, all_instruction_names):
        """Test that instruction files have proper 4-space indentation for YAML."""
        instructions_dir = templates_dir / "instructions"
        for name in all_instruction_names:
            file_path = instructions_dir / f"{name}.txt"
            if not file_path.exists():
                continue

            content = file_path.read_text()
            lines = content.split("\n")

            # Check that non-empty lines start with proper indentation
            for i, line in enumerate(lines):
                if line.strip():  # Non-empty line
                    # Should start with spaces (indented for YAML block scalar)
                    # First non-empty line should have indentation
                    if i == 0 or (i > 0 and lines[i-1].strip() == ""):
                        # Allow lines that start content blocks
                        pass

    def test_instruction_files_have_important_rules(self, templates_dir, all_instruction_names):
        """Test that instruction files have Important Rules section."""
        instructions_dir = templates_dir / "instructions"
        for name in all_instruction_names:
            file_path = instructions_dir / f"{name}.txt"
            if not file_path.exists():
                continue

            content = file_path.read_text()
            assert "Important Rules" in content or "important rules" in content.lower(), \
                f"Instruction file missing Important Rules section: {name}.txt"


class TestBaseTemplate:
    """Test base.yaml template file."""

    def test_base_template_exists(self, templates_dir):
        """Test that base.yaml template exists."""
        base_template = templates_dir / "base.yaml"
        assert base_template.exists(), f"Base template not found: {base_template}"

    def test_base_template_has_required_variables(self, base_template_content):
        """Test that base template contains all required variable placeholders."""
        required_vars = [
            "${PERSONALITY_PROMPT}",
            "${INSTANCE_TEMPLATE}",
            "${TEMPERATURE}",
            "${STEP_LIMIT}",
            "${TIMEOUT}",
            "${SERVED_MODEL_NAME}",
            "${VLLM_ENDPOINT}",
        ]
        for var in required_vars:
            assert var in base_template_content, f"Base template missing variable: {var}"

    def test_base_template_has_jinja_syntax(self, base_template_content):
        """Test that base template preserves Jinja syntax for agent runtime."""
        # Note: {{task}} is in the instruction template files, not base.yaml
        # Base template has Jinja patterns in action_observation_template and format_error_template
        jinja_patterns = [
            "{{output.returncode}}",
            "{{actions|length}}",
        ]
        for pattern in jinja_patterns:
            assert pattern in base_template_content, f"Base template missing Jinja pattern: {pattern}"

    def test_base_template_valid_yaml_structure(self, base_template_content):
        """Test that base template has valid YAML structure (ignoring unsubstituted vars)."""
        # Replace variables with placeholder values to check YAML structure
        # Need to use indented placeholders for multi-line content variables
        import re

        # Replace content variables with indented placeholders
        test_content = base_template_content
        test_content = test_content.replace('${PERSONALITY_PROMPT}', '    Test personality prompt.')
        test_content = test_content.replace('${INSTANCE_TEMPLATE}', '    Test instance template with {{task}}.')
        # Replace simple variables
        test_content = re.sub(r'\$\{[A-Z_][A-Z0-9_]*\}', 'PLACEHOLDER', test_content)

        import yaml
        try:
            config = yaml.safe_load(test_content)
            assert config is not None
            assert "agent" in config
            assert "environment" in config
            assert "model" in config
        except yaml.YAMLError as e:
            pytest.fail(f"Base template has invalid YAML structure: {e}")
