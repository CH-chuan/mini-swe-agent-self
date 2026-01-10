"""Tests for template substitution logic used in experiment config generation."""

import pytest

from .conftest import substitute_template


class TestSimpleSubstitution:
    """Test basic variable substitution."""

    def test_simple_variable_substitution(self):
        """Test that basic ${VAR} patterns are replaced."""
        template = "Hello ${NAME}!"
        env_vars = {"NAME": "World"}
        result = substitute_template(template, env_vars)
        assert result == "Hello World!"

    def test_multiple_variables(self):
        """Test multiple variable substitutions in one template."""
        template = "Model: ${MODEL_NAME}, Temp: ${TEMPERATURE}"
        env_vars = {"MODEL_NAME": "TestModel", "TEMPERATURE": "0.5"}
        result = substitute_template(template, env_vars)
        assert result == "Model: TestModel, Temp: 0.5"

    def test_same_variable_multiple_times(self):
        """Test same variable appearing multiple times."""
        template = "${VAR} and ${VAR} again"
        env_vars = {"VAR": "value"}
        result = substitute_template(template, env_vars)
        assert result == "value and value again"

    def test_empty_value(self):
        """Test substitution with empty string value."""
        template = "Before${VAR}After"
        env_vars = {"VAR": ""}
        result = substitute_template(template, env_vars)
        assert result == "BeforeAfter"


class TestMissingVariables:
    """Test handling of missing/undefined variables."""

    def test_missing_variable_unchanged(self):
        """Test that undefined variables remain as ${VAR}."""
        template = "Hello ${UNDEFINED_VAR}!"
        env_vars = {}
        result = substitute_template(template, env_vars)
        assert result == "Hello ${UNDEFINED_VAR}!"

    def test_partial_substitution(self):
        """Test mix of defined and undefined variables."""
        template = "${DEFINED} and ${UNDEFINED}"
        env_vars = {"DEFINED": "yes"}
        result = substitute_template(template, env_vars)
        assert result == "yes and ${UNDEFINED}"


class TestMultilineContent:
    """Test multi-line content preservation."""

    def test_multiline_personality_prompt(self):
        """Test that multi-line PERSONALITY_PROMPT is preserved correctly."""
        template = """system_template: |
    You are a helpful assistant.

    ${PERSONALITY_PROMPT}
    Your response must contain exactly ONE bash code block."""

        personality = """You are very organized and methodical.
You always double-check your work.
You are thorough in your analysis."""

        env_vars = {"PERSONALITY_PROMPT": personality}
        result = substitute_template(template, env_vars)

        assert "You are very organized and methodical." in result
        assert "You always double-check your work." in result
        assert "You are thorough in your analysis." in result
        # Verify newlines are preserved
        assert result.count("\n") >= template.count("\n") + personality.count("\n") - 1

    def test_multiline_instance_template(self):
        """Test that multi-line INSTANCE_TEMPLATE with indentation is preserved."""
        template = """  instance_template: |
${INSTANCE_TEMPLATE}
  action_observation_template: |"""

        instance = """    Please solve this issue: {{task}}

    ## Important Rules

    1. Every response must contain exactly one action
    2. The action must be enclosed in triple backticks"""

        env_vars = {"INSTANCE_TEMPLATE": instance}
        result = substitute_template(template, env_vars)

        # Verify indentation is preserved
        assert "    Please solve this issue" in result
        assert "    ## Important Rules" in result
        assert "    1. Every response" in result

    def test_content_with_special_characters(self):
        """Test content with quotes, backslashes, etc."""
        template = "Content: ${CONTENT}"
        content = '''He said "Hello" and then 'goodbye'.
Path: C:\\Users\\test
Dollar sign: $50'''
        env_vars = {"CONTENT": content}
        result = substitute_template(template, env_vars)

        assert '"Hello"' in result
        assert "'goodbye'" in result
        assert "C:\\Users\\test" in result
        assert "$50" in result


class TestJinjaSyntaxPreservation:
    """Test that Jinja2 syntax is not modified."""

    def test_jinja_double_braces_preserved(self):
        """Test that {{task}} and similar Jinja syntax is preserved."""
        template = "Issue: {{task}} - Output: {{output.returncode}}"
        env_vars = {}
        result = substitute_template(template, env_vars)
        assert result == "Issue: {{task}} - Output: {{output.returncode}}"

    def test_jinja_control_structures_preserved(self):
        """Test that Jinja control structures are preserved."""
        template = """{% if output.output | length < 10000 -%}
<output>
{{ output.output -}}
</output>
{%- endif -%}"""
        env_vars = {}
        result = substitute_template(template, env_vars)
        assert "{% if output.output" in result
        assert "{{ output.output" in result
        assert "{%- endif -%}" in result

    def test_mixed_shell_and_jinja(self):
        """Test template with both ${VAR} and {{jinja}} syntax."""
        template = "Model: ${MODEL_NAME}, Task: {{task}}"
        env_vars = {"MODEL_NAME": "TestModel"}
        result = substitute_template(template, env_vars)
        assert result == "Model: TestModel, Task: {{task}}"


class TestVariableNamePatterns:
    """Test different variable name patterns."""

    def test_uppercase_with_underscore(self):
        """Test standard UPPER_CASE variable names."""
        template = "${MY_VAR_NAME}"
        env_vars = {"MY_VAR_NAME": "value"}
        result = substitute_template(template, env_vars)
        assert result == "value"

    def test_variable_with_numbers(self):
        """Test variable names containing numbers."""
        template = "${VAR123} and ${VAR_2}"
        env_vars = {"VAR123": "a", "VAR_2": "b"}
        result = substitute_template(template, env_vars)
        assert result == "a and b"

    def test_lowercase_not_matched(self):
        """Test that lowercase ${var} is not matched by our pattern."""
        template = "${lowercase}"
        env_vars = {"lowercase": "value"}
        result = substitute_template(template, env_vars)
        # Our pattern only matches uppercase, so this should remain unchanged
        assert result == "${lowercase}"

    def test_single_letter_variable(self):
        """Test single letter variable names."""
        template = "${A}"
        env_vars = {"A": "value"}
        result = substitute_template(template, env_vars)
        assert result == "value"


class TestEdgeCases:
    """Test edge cases and boundary conditions."""

    def test_empty_template(self):
        """Test empty template string."""
        result = substitute_template("", {"VAR": "value"})
        assert result == ""

    def test_no_variables_in_template(self):
        """Test template with no variables."""
        template = "Just plain text"
        result = substitute_template(template, {"VAR": "value"})
        assert result == "Just plain text"

    def test_adjacent_variables(self):
        """Test variables directly adjacent to each other."""
        template = "${A}${B}${C}"
        env_vars = {"A": "1", "B": "2", "C": "3"}
        result = substitute_template(template, env_vars)
        assert result == "123"

    def test_nested_braces_not_matched(self):
        """Test that nested braces like ${{VAR}} are not matched."""
        template = "${{VAR}}"
        env_vars = {"VAR": "value"}
        result = substitute_template(template, env_vars)
        # Should not be substituted
        assert result == "${{VAR}}"

    def test_incomplete_pattern(self):
        """Test incomplete patterns like ${VAR or $VAR}."""
        template = "${INCOMPLETE and $ALSO}"
        env_vars = {"INCOMPLETE": "val1", "ALSO": "val2"}
        result = substitute_template(template, env_vars)
        # Neither should be substituted
        assert result == "${INCOMPLETE and $ALSO}"

    def test_value_containing_variable_pattern(self):
        """Test value that itself contains ${VAR} pattern."""
        template = "${OUTER}"
        env_vars = {"OUTER": "contains ${INNER} pattern"}
        result = substitute_template(template, env_vars)
        # Should only do one level of substitution
        assert result == "contains ${INNER} pattern"
