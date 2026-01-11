# Experiment Templates

This directory contains templates used by `experiment.slurm` to generate YAML configuration files for experiments.

## Directory Structure

```
templates/
├── base.yaml           # Main YAML template with placeholders
├── personality/        # Personality trait templates
│   ├── HC.txt          # High Conscientiousness
│   ├── LC.txt          # Low Conscientiousness
│   ├── HC-item-120.txt # High Conscientiousness (120-item scale)
│   ├── LC-item-120.txt # Low Conscientiousness (120-item scale)
│   ├── HC-item-300.txt # High Conscientiousness (300-item scale)
│   ├── LC-item-300.txt # Low Conscientiousness (300-item scale)
│   ├── NOP.txt         # No personality (empty)
│   └── ...             # Other personality variants
└── instructions/       # Task instruction templates
    ├── submit-in-rules.txt
    └── submit-as-tool.txt
```

## Template Indentation Requirement

**IMPORTANT: All personality and instruction template files MUST have 4-space indentation on every line.**

### Why This Is Required

Templates are injected into `base.yaml` via the `${PERSONALITY_PROMPT}` and `${INSTANCE_TEMPLATE}` placeholders. These placeholders are inside YAML literal block scalars (`|`), which require consistent indentation to properly contain multi-line content.

Without proper indentation, lines containing colons (`:`) will be interpreted as YAML key-value mappings instead of literal text, causing parsing errors like:

```
ScannerError: mapping values are not allowed here
  in "<unicode string>", line 7, column 98:
     ... Orderliness – "Like to tidy up.": Very Inaccurate; ...
                                         ^
```

### Correct Format Example

```
    You are a person with a low level of Conscientiousness.
    Your personality test results on Conscientiousness items are:
    Self-Efficacy – "Complete tasks successfully.": Very Inaccurate; ...
```

Notice the 4-space indentation at the start of each line.

### Incorrect Format (Will Cause YAML Parsing Errors)

```
You are a person with a low level of Conscientiousness.
Your personality test results on Conscientiousness items are:
Self-Efficacy – "Complete tasks successfully.": Very Inaccurate; ...
```

Without indentation, any text containing `:` patterns (like personality item responses) will break YAML parsing.

## Template Substitution

The `experiment.slurm` script (lines 283-333) handles template substitution with the following logic:

1. Reads `base.yaml` template
2. Substitutes `${VAR}` patterns with environment variables
3. Uses `textwrap.dedent()` to normalize leading indentation
4. Applies the template's indentation to lines 2+ of multi-line values

The 4-space indentation in template files ensures consistent behavior with this substitution process.

## Adding New Templates

When creating new personality or instruction templates:

1. **Add 4-space indentation** to the beginning of every line
2. Avoid special YAML characters at the start of lines (like `-`, `*`, `&`, `!`)
3. Test the template by generating a config and validating YAML syntax:
   ```bash
   python3 -c "import yaml; yaml.safe_load(open('generated_config.yaml'))"
   ```
