# Environment Variables Documentation

This document explains the environment variables configured in the mini-swe-agent execution environment.

---

## Overview

These environment variables are set in the execution environment (Docker/Singularity containers or local shell) to ensure non-interactive, automated execution suitable for agent-based development.

**Location in config:** `environment.env` section

**Example from `gptoss_20b_try.yaml:139-144`:**
```yaml
environment:
  env:
    PAGER: cat
    MANPAGER: cat
    LESS: -R
    PIP_PROGRESS_BAR: 'off'
    TQDM_DISABLE: '1'
```

---

## Environment Variable Descriptions

### 1. `PAGER: cat`

**Purpose:** Controls the default paging program for displaying long text output

**Default behavior (without this setting):**
- Linux/Unix systems typically use `less` or `more` as the default pager
- These programs display output one screen at a time
- They wait for user input (spacebar to continue, 'q' to quit)
- **This creates an interactive prompt that blocks execution**

**Why set to `cat`:**
- `cat` displays all output immediately without pagination
- No interactive prompts or user input required
- Agent can see complete output in one go
- Prevents commands from hanging while waiting for user interaction

**Example impact:**
```bash
# Without PAGER=cat (problematic for agents)
git log  # Opens in 'less', waits for user to press 'q'

# With PAGER=cat (works for agents)
git log  # Prints all output immediately, no waiting
```

**Commands affected:**
- `git log`, `git diff`, `git show`
- Database CLI tools (`psql`, `mysql`)
- Various Linux commands that use pagers for long output

---

### 2. `MANPAGER: cat`

**Purpose:** Controls the paging program specifically for manual pages (`man` command)

**Default behavior (without this setting):**
- Manual pages open in `less` or `man`'s built-in pager
- Waits for user input to scroll through documentation
- Interactive navigation (arrow keys, page up/down, 'q' to quit)

**Why set to `cat`:**
- Displays entire manual page without pagination
- No interactive prompts
- Agent can read full documentation immediately
- Prevents `man` commands from blocking

**Example impact:**
```bash
# Without MANPAGER=cat (problematic)
man python  # Opens interactive pager, waits for user

# With MANPAGER=cat (works)
man python  # Prints entire manual, returns immediately
```

**Note:** `MANPAGER` takes precedence over `PAGER` for `man` commands specifically.

---

### 3. `LESS: -R`

**Purpose:** Configures options for the `less` pager program

**What `-R` means:**
- **R**aw color codes
- Allows ANSI color escape sequences to be displayed
- Without this, colored output would show escape codes like `^[[31m` instead of colors

**Why this matters:**
Even though we set `PAGER=cat`, some programs explicitly call `less`:
- `git diff` with colors
- Syntax highlighting in various tools
- Error messages with color formatting

**Impact:**
```bash
# Without LESS=-R
git diff  # Shows: ^[[31m-old line^[[0m ^[[32m+new line^[[0m

# With LESS=-R
git diff  # Shows: -old line +new line (with actual colors)
```

**Additional context:**
- If `less` is invoked, at least the output will be readable with colors
- Common alternative: `LESS=-FRX`
  - `-F`: Quit if output fits on one screen (no paging)
  - `-R`: Raw colors
  - `-X`: Don't clear screen on exit

**Why not used here:** Simpler to just use `PAGER=cat` and avoid `less` entirely

---

### 4. `PIP_PROGRESS_BAR: 'off'`

**Purpose:** Disables the progress bar displayed during pip package installation

**Default behavior (without this setting):**
```bash
$ pip install numpy
Collecting numpy
  Downloading numpy-1.24.0.tar.gz (10.9 MB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 10.9/10.9 MB 5.2 MB/s eta 0:00:00
```

**With `PIP_PROGRESS_BAR='off'`:**
```bash
$ pip install numpy
Collecting numpy
  Downloading numpy-1.24.0.tar.gz (10.9 MB)
Successfully installed numpy-1.24.0
```

**Why disable for agents:**

1. **Cleaner output:**
   - Progress bars use special characters and line rewrites
   - Can clutter logs and make parsing difficult
   - Agent doesn't need visual feedback on download progress

2. **Avoid terminal control sequences:**
   - Progress bars use ANSI escape codes to update in place
   - May not render correctly in non-interactive terminals
   - Can create messy output in log files

3. **Faster parsing:**
   - Agent can process text output more efficiently
   - No need to handle dynamic updating lines
   - Simpler pattern matching for success/failure

**Official pip documentation:**
- Environment variable: `PIP_PROGRESS_BAR`
- Valid values: `'on'`, `'off'`, `'ascii'`, `'pretty'`, `'emoji'`
- Command-line equivalent: `pip install --progress-bar off`

---

### 5. `TQDM_DISABLE: '1'`

**Purpose:** Disables tqdm progress bars in Python scripts

**What is tqdm:**
- Popular Python library for displaying progress bars
- Used by many data science and ML libraries (PyTorch, Transformers, pandas, etc.)
- Shows iteration progress with ETA and speed metrics

**Default behavior (without this setting):**
```python
from tqdm import tqdm
import time

for i in tqdm(range(100)):
    time.sleep(0.01)

# Output:
# 100%|██████████████████████████| 100/100 [00:01<00:00, 99.00it/s]
```

**With `TQDM_DISABLE='1'`:**
```python
from tqdm import tqdm
import time

for i in tqdm(range(100)):
    time.sleep(0.01)

# Output:
# (no progress bar, silent)
```

**Why disable for agents:**

1. **Reduces output noise:**
   - Training scripts often have nested progress bars
   - Can generate hundreds of lines of updates
   - Agent doesn't benefit from visual progress indication

2. **Prevents terminal issues:**
   - Progress bars use carriage returns (`\r`) to update in place
   - May not work correctly in non-TTY environments
   - Can cause formatting issues in logs

3. **Improves log readability:**
   - Log files remain clean and grep-friendly
   - Easier to parse output for success/failure
   - No confusing partial lines or overwritten text

**Examples of affected libraries:**
- **PyTorch/TensorFlow:** Training loop progress bars
- **Transformers (Hugging Face):** Model download and training progress
- **pandas:** `progress_apply()` operations
- **scikit-learn:** Some estimators with verbose output

**Alternative values:**
- `TQDM_DISABLE='0'` or unset: Progress bars enabled
- `TQDM_DISABLE='1'` or `'True'`: Progress bars disabled

**Programmatic equivalent:**
```python
from tqdm import tqdm
tqdm.pandas(disable=True)  # Disable for pandas
```

---

## Why These Settings Matter for SWE-Agent

### Problem: Interactive Prompts Block Execution

When an agent runs a command that expects user interaction:
1. Command starts executing
2. Waits for user input (keypress, scroll, etc.)
3. **Agent's execution hangs indefinitely**
4. Timeout occurs or system becomes unresponsive

### Solution: Non-Interactive Environment

These environment variables ensure:
- ✅ No commands wait for user input
- ✅ All output is immediately available
- ✅ Clean, parseable text output
- ✅ Logs are readable and searchable
- ✅ Automated execution flows smoothly

---

## Environment Variable Propagation

### How these variables are set:

**Local Environment:**
```python
# src/minisweagent/environments/local.py
def execute(self, command: str, cwd: str = "") -> dict[str, str]:
    env = os.environ.copy()
    env.update(self.config.env)  # Adds PAGER, MANPAGER, etc.
    result = subprocess.run(
        command,
        env=env,  # <- Environment variables applied here
        ...
    )
```

**Docker Environment:**
```python
# src/minisweagent/environments/docker.py
def __init__(self, ...):
    env_args = []
    for key, value in self.config.env.items():
        env_args.extend(["-e", f"{key}={value}"])

    # docker run -e PAGER=cat -e MANPAGER=cat ...
```

**Singularity Environment:**
```bash
# Environment variables are exported before container exec
export PAGER=cat
export MANPAGER=cat
export LESS=-R
export PIP_PROGRESS_BAR=off
export TQDM_DISABLE=1

singularity exec container.sif bash -c "command"
```

---

## Configuration Examples

### Minimal Configuration (Default)

```yaml
environment:
  env:
    PAGER: cat
    MANPAGER: cat
```

**Use case:** Basic non-interactive execution

---

### Full Configuration (Recommended for SWE-Bench)

```yaml
environment:
  env:
    # Pager settings
    PAGER: cat
    MANPAGER: cat
    LESS: -R

    # Progress bar disabling
    PIP_PROGRESS_BAR: 'off'
    TQDM_DISABLE: '1'

    # Optional: Additional non-interactive settings
    DEBIAN_FRONTEND: noninteractive  # For apt-get
    PYTHONUNBUFFERED: '1'            # Disable Python output buffering
```

**Use case:** Production SWE-bench runs, maximum reliability

---

### Development Configuration (Interactive)

```yaml
environment:
  env:
    # Allow some interactivity for debugging
    LESS: -FRX   # Quit if one screen, colors, no clear
    # PAGER and MANPAGER not set - use defaults
    PIP_PROGRESS_BAR: 'on'
    TQDM_DISABLE: '0'
```

**Use case:** Local development and debugging

---

## Related Environment Variables

Here are other common environment variables you might want to set for agent environments:

### Output Control

```yaml
PYTHONUNBUFFERED: '1'          # Disable Python stdout/stderr buffering
GIT_PAGER: cat                 # Git-specific pager (overrides PAGER)
SYSTEMD_PAGER: cat             # systemd command pager
```

### Non-Interactive Package Management

```yaml
DEBIAN_FRONTEND: noninteractive  # Debian/Ubuntu package installation
APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE: '1'  # Suppress apt warnings
```

### Display and Locale

```yaml
DISPLAY: ''                    # Disable X11 display (no GUI)
TERM: dumb                     # Minimal terminal capabilities
LC_ALL: C.UTF-8               # Set locale to avoid encoding issues
LANG: C.UTF-8                 # Language setting
```

### Python-Specific

```yaml
PYTHONDONTWRITEBYTECODE: '1'   # Don't create .pyc files
PYTHONIOENCODING: utf-8        # Force UTF-8 I/O encoding
PIP_NO_INPUT: '1'              # Never prompt for user input
PIP_DISABLE_PIP_VERSION_CHECK: '1'  # Skip pip version check
```

### Development Tools

```yaml
NPM_CONFIG_PROGRESS: 'false'   # Disable npm progress bar
NPM_CONFIG_LOGLEVEL: error     # Reduce npm verbosity
CARGO_TERM_PROGRESS_WHEN: never  # Disable Rust cargo progress
```

---

## Debugging Tips

### Check if environment variables are set:

```bash
# In the agent's execution environment
echo $PAGER          # Should output: cat
echo $TQDM_DISABLE   # Should output: 1
env | grep -E 'PAGER|TQDM|PIP'
```

### Test pager behavior:

```bash
# Should output immediately without waiting
git log --oneline | head -50
man ls
```

### Test progress bar suppression:

```bash
# Should install without progress bars
pip install requests

# Should run without tqdm output
python -c "from tqdm import tqdm; import time; [time.sleep(0.01) for _ in tqdm(range(10))]"
```

### If commands still hang:

1. **Check for other interactive prompts:**
   - SSH password prompts
   - sudo password requests
   - License agreement prompts

2. **Add timeout to commands:**
   ```yaml
   environment:
     timeout: 30  # Kill commands after 30 seconds
   ```

3. **Use stdin redirection:**
   ```bash
   command < /dev/null  # Provide empty stdin
   ```

---

## References

- **PAGER/MANPAGER:** `man 1 less`, `man 7 environ`
- **LESS options:** https://www.greenwoodsoftware.com/less/
- **PIP environment variables:** https://pip.pypa.io/en/stable/topics/configuration/
- **tqdm:** https://github.com/tqdm/tqdm#documentation
- **Linux environment variables:** `man 7 environ`

---

**Document Version:** 1.0
**Last Updated:** 2025-11-20
