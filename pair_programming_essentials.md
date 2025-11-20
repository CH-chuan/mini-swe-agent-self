# Pair Programming Extension: Essential Code Blocks & Implementation Guide

**Date:** 2025-11-20
**Project:** mini-swe-agent
**Goal:** Extend single-agent SWE-bench task system to support pair programming with driver and navigator agents

---

## Table of Contents

1. [Overview](#overview)
2. [Requirements](#requirements)
3. [Current Architecture](#current-architecture)
4. [Essential Code Blocks by Requirement](#essential-code-blocks-by-requirement)
5. [Implementation Recommendations](#implementation-recommendations)
6. [Code Reference Summary](#code-reference-summary)

---

## Overview

This document identifies the essential code blocks and logic needed to extend the mini-swe-agent from a single-agent system to a pair programming system with two agents:
- **Driver:** Executes actions and writes code
- **Navigator:** Reviews, suggests, and guides strategy

The analysis is based on examining the single-agent trajectory in `test/matplotlib__matplotlib-24149/matplotlib__matplotlib-24149.traj.json` and the core codebase.

---

## Requirements

1. **Turn-by-turn communication:** Agents must alternate turns with no consecutive turns by the same agent
2. **Configurable first speaker:** Parameter to control whether driver or navigator speaks first
3. **Reasoning content visibility:** Dynamic control over whether reasoning content is shared between agents
4. **Tool execution/observation visibility:** Control over whether tool execution and observations are shared
5. **Dynamic logging:** Trajectory logging that captures agent roles and turn information

---

## Current Architecture

### Message Flow (Single Agent)

```
┌─────────────────────────────────────────────────────────────┐
│ DefaultAgent.run(task)                                      │
│                                                             │
│  1. Initialize messages:                                    │
│     - System message (role: "system")                       │
│     - User message with task (role: "user")                 │
│                                                             │
│  2. Loop: while True                                        │
│     ├─ step()                                               │
│     │  ├─ query()                                           │
│     │  │  ├─ Check limits                                   │
│     │  │  ├─ model.query(self.messages)                     │
│     │  │  └─ add_message("assistant", **response)           │
│     │  │                                                     │
│     │  └─ get_observation(response)                         │
│     │     ├─ parse_action()                                 │
│     │     ├─ execute_action()                               │
│     │     │  └─ env.execute(command)                        │
│     │     └─ add_message("user", observation)               │
│     │                                                        │
│     └─ Handle exceptions (format errors, timeouts, etc.)    │
│                                                             │
│  3. Return (exit_status, result)                            │
└─────────────────────────────────────────────────────────────┘
```

### Message Structure

Messages stored in `agent.messages` as dictionaries:

```python
{
    "role": "system" | "user" | "assistant",
    "content": str,
    **kwargs  # Additional fields (e.g., "extra")
}
```

For assistant messages with reasoning models:

```python
{
    "role": "assistant",
    "content": "THOUGHT: ...\n\n```bash\ncommand\n```",
    "extra": {
        "response": {
            "choices": [{
                "message": {
                    "content": "...",
                    "reasoning_content": "...",  # Internal reasoning
                    "provider_specific_fields": {
                        "reasoning_content": "..."
                    }
                }
            }],
            "usage": {...},
            ...
        }
    }
}
```

---

## Essential Code Blocks by Requirement

### 1. Turn-by-Turn Management (No Consecutive Turns)

#### Core Turn Logic

**File:** `src/minisweagent/agents/default.py:73-86`

```python
def run(self, task: str, **kwargs) -> tuple[str, str]:
    """Run step() until agent is finished. Return exit status & message"""
    self.extra_template_vars |= {"task": task, **kwargs}
    self.messages = []
    self.add_message("system", self.render_template(self.config.system_template))
    self.add_message("user", self.render_template(self.config.instance_template))
    while True:
        try:
            self.step()  # <- THIS IS WHERE TURNS HAPPEN
        except NonTerminatingException as e:
            self.add_message("user", str(e))
        except TerminatingException as e:
            self.add_message("user", str(e))
            return type(e).__name__, str(e)
```

**File:** `src/minisweagent/agents/default.py:88-90`

```python
def step(self) -> dict:
    """Query the LM, execute the action, return the observation."""
    return self.get_observation(self.query())
```

#### Key Insights

- The `run()` method contains the main loop that drives execution
- Each `step()` call represents one agent turn (query + observation)
- Currently, `step()` is called repeatedly by the same agent
- **For pair programming:** Need to alternate between driver.step() and navigator.step()

#### What to Modify

```python
# Pseudocode for pair programming turn management
def run(self, task: str, **kwargs) -> tuple[str, str]:
    # Initialize shared message history
    self.messages = []
    self.add_message("system", ...)
    self.add_message("user", task_message)

    # Track current speaker
    current_agent = self.config.first_speaker  # "driver" or "navigator"

    while True:
        # Get the appropriate agent
        agent = self.driver if current_agent == "driver" else self.navigator

        try:
            # Agent takes their turn
            agent.step()

            # Switch to the other agent
            current_agent = "navigator" if current_agent == "driver" else "driver"

        except NonTerminatingException as e:
            self.add_message("user", str(e))
        except TerminatingException as e:
            self.add_message("user", str(e))
            return type(e).__name__, str(e)
```

---

### 2. Message Distribution & Filtering

#### Message Addition

**File:** `src/minisweagent/agents/default.py:70-71`

```python
def add_message(self, role: str, content: str, **kwargs):
    self.messages.append({"role": role, "content": content, **kwargs})
```

#### Message Query

**File:** `src/minisweagent/agents/default.py:92-98`

```python
def query(self) -> dict:
    """Query the model and return the response."""
    if 0 < self.config.step_limit <= self.model.n_calls or 0 < self.config.cost_limit <= self.model.cost:
        raise LimitsExceeded()
    response = self.model.query(self.messages)  # <- SENDS ALL MESSAGES
    self.add_message("assistant", **response)  # <- ADDS RESPONSE TO MESSAGES
    return response
```

#### Key Insights

- `self.messages` is the shared conversation history
- `model.query(self.messages)` sends ALL messages to the LLM
- Both agents will need access to the shared message history
- **Critical:** Need to filter messages before sending to each agent based on visibility rules

#### What to Modify

```python
def query(self) -> dict:
    """Query the model with filtered messages based on agent role."""
    if 0 < self.config.step_limit <= self.model.n_calls or 0 < self.config.cost_limit <= self.model.cost:
        raise LimitsExceeded()

    # Filter messages based on visibility rules
    filtered_messages = self._filter_messages_for_agent(
        self.messages,
        agent_role=self.role  # "driver" or "navigator"
    )

    response = self.model.query(filtered_messages)
    self.add_message("assistant", agent_role=self.role, **response)
    return response

def _filter_messages_for_agent(self, messages: list[dict], agent_role: str) -> list[dict]:
    """Filter messages based on visibility configuration."""
    filtered = []
    for msg in messages:
        # Apply filtering logic based on config
        if self._should_agent_see_message(msg, agent_role):
            filtered_msg = self._process_message(msg, agent_role)
            filtered.append(filtered_msg)
    return filtered
```

---

### 3. Reasoning Content Control

#### Response Structure from Model

**File:** `src/minisweagent/models/litellm_model.py:66-98`

```python
def query(self, messages: list[dict[str, str]], **kwargs) -> dict:
    if self.config.set_cache_control:
        messages = set_cache_control(messages, mode=self.config.set_cache_control)
    print("messages", messages)
    response = self._query(messages, **kwargs)
    print("response", response)
    self.n_calls += 1
    # No need for cost tracking
    # [cost tracking code commented out]
    return {
        "content": response.choices[0].message.content or "",  # type: ignore
        "extra": {
            "response": response.model_dump(),  # <- FULL RESPONSE INCLUDING REASONING
        },
    }
```

#### Trajectory Example

From `test/matplotlib__matplotlib-24149/matplotlib__matplotlib-24149.traj.json`:

```json
{
  "role": "assistant",
  "content": "THOUGHT: The error originates from...\n\n```bash\nsed -i ...\n```",
  "extra": {
    "response": {
      "choices": [{
        "message": {
          "content": "THOUGHT: ...",
          "reasoning_content": "We need to modify matplotlib source...",
          "provider_specific_fields": {
            "reasoning_content": "We need to modify matplotlib source...",
            "refusal": null
          }
        }
      }]
    }
  }
}
```

#### Key Insights

- Reasoning models (like o1) include `reasoning_content` in the response
- Path: `response.choices[0].message.reasoning_content`
- This reasoning is stored in `extra.response` but NOT in the main `content` field
- The `content` field contains the user-facing response (THOUGHT + bash command)
- **For pair programming:** Need to decide if the other agent should see this internal reasoning

#### What to Modify

```python
def _process_message(self, msg: dict, target_agent_role: str) -> dict:
    """Process a message for visibility to target agent."""
    processed_msg = msg.copy()

    # Handle reasoning content visibility
    if not self.config.show_reasoning_to_other_agent:
        if "extra" in processed_msg and "response" in processed_msg["extra"]:
            # Remove reasoning content from the response
            response = processed_msg["extra"]["response"]
            if "choices" in response:
                for choice in response["choices"]:
                    if "message" in choice:
                        choice["message"].pop("reasoning_content", None)
                        if "provider_specific_fields" in choice["message"]:
                            choice["message"]["provider_specific_fields"].pop("reasoning_content", None)

    return processed_msg
```

---

### 4. Tool Execution and Observation Control

#### Action Execution

**File:** `src/minisweagent/agents/default.py:114-125`

```python
def execute_action(self, action: dict) -> dict:
    try:
        output = self.env.execute(action["action"])  # <- ACTUAL EXECUTION
    except subprocess.TimeoutExpired as e:
        output = e.output.decode("utf-8", errors="replace") if e.output else ""
        raise ExecutionTimeoutError(
            self.render_template(self.config.timeout_template, action=action, output=output)
        )
    except TimeoutError:
        raise ExecutionTimeoutError(self.render_template(self.config.timeout_template, action=action, output=""))
    self.has_finished(output)
    return output
```

#### Observation Generation

**File:** `src/minisweagent/agents/default.py:100-105`

```python
def get_observation(self, response: dict) -> dict:
    """Execute the action and return the observation."""
    output = self.execute_action(self.parse_action(response))  # <- EXECUTES TOOL
    observation = self.render_template(self.config.action_observation_template, output=output)
    self.add_message("user", observation)  # <- ADDS OBSERVATION AS USER MESSAGE
    return output
```

#### Observation Template

**File:** `gptoss_20b_try.yaml:94-118`

```yaml
action_observation_template: |
  <returncode>{{output.returncode}}</returncode>
  {% if output.output | length < 10000 -%}
  <output>
  {{ output.output -}}
  </output>
  {%- else -%}
  <warning>
  The output of your last command was too long.
  ...
  </warning>
  {%- endif -%}
```

#### Key Insights

- Tool execution happens in `execute_action()`
- Observation is formatted using a Jinja2 template
- Observation is added as a "user" role message
- **For pair programming:** Need to control:
  1. Who can execute tools (driver only, or both?)
  2. Who sees the execution action (both or just executor?)
  3. Who sees the observation (both or just executor?)

#### What to Modify

```python
def step(self) -> dict:
    """Query the LM, execute the action (if allowed), return the observation."""
    response = self.query()

    # Check if this agent can execute actions
    if self.role == "navigator" and not self.config.allow_navigator_execution:
        # Navigator doesn't execute, just comments
        # No observation to add
        return {"output": "", "returncode": -1}

    # Execute and observe
    return self.get_observation(response)

def get_observation(self, response: dict) -> dict:
    """Execute the action and return the observation."""
    output = self.execute_action(self.parse_action(response))
    observation = self.render_template(self.config.action_observation_template, output=output)

    # Add observation with metadata about who executed
    self.add_message(
        "user",
        observation,
        executed_by=self.role,
        visible_to=self._get_observation_visibility()
    )
    return output

def _get_observation_visibility(self) -> list[str]:
    """Determine which agents should see this observation."""
    if self.config.show_tool_observation_to_navigator:
        return ["driver", "navigator"]
    else:
        return ["driver"]  # Only executor sees result
```

---

### 5. Dynamic Logging & Trajectory Saving

#### Trajectory Save Function

**File:** `src/minisweagent/run/utils/save.py:22-79`

```python
def save_traj(
    agent: Agent | None,
    path: Path | None,
    *,
    print_path: bool = True,
    exit_status: str | None = None,
    result: str | None = None,
    extra_info: dict | None = None,
    print_fct: Callable = print,
    **kwargs,
):
    """Save the trajectory of the agent to a file."""
    if path is None:
        return
    data = {
        "info": {
            "exit_status": exit_status,
            "submission": result,
            "model_stats": {
                "instance_cost": 0.0,
                "api_calls": 0,
            },
            "mini_version": __version__,
        },
        "messages": [],  # <- ALL MESSAGES SAVED HERE
        "trajectory_format": "mini-swe-agent-1",
    } | kwargs
    if agent is not None:
        data["info"]["model_stats"]["instance_cost"] = agent.model.cost
        data["info"]["model_stats"]["api_calls"] = agent.model.n_calls
        data["messages"] = agent.messages  # <- DIRECT COPY OF ALL MESSAGES
        data["info"]["config"] = {
            "agent": _asdict(agent.config),
            "model": _asdict(agent.model.config),
            "environment": _asdict(agent.env.config),
            "agent_type": _get_class_name_with_module(agent),
            "model_type": _get_class_name_with_module(agent.model),
            "environment_type": _get_class_name_with_module(agent.env),
        }
    if extra_info:
        data["info"].update(extra_info)

    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2))
    if print_path:
        print_fct(f"Saved trajectory to '{path}'")
```

#### Current Trajectory Format

```json
{
  "info": {
    "exit_status": "Submitted",
    "submission": "",
    "model_stats": {
      "instance_cost": 0.0,
      "api_calls": 34
    },
    "mini_version": "1.15.0",
    "config": {
      "agent": {...},
      "model": {...},
      "environment": {...}
    }
  },
  "messages": [...],
  "trajectory_format": "mini-swe-agent-1"
}
```

#### Key Insights

- Trajectory saves the complete message history
- All config information is preserved
- Model stats (cost, API calls) are tracked
- **For pair programming:** Need to:
  1. Track which agent sent each message
  2. Save configurations for both agents
  3. Track stats for both models separately
  4. Add turn numbers or sequence information

#### What to Modify

```python
def add_message(self, role: str, content: str, **kwargs):
    """Add message with agent role metadata."""
    self.messages.append({
        "role": role,
        "content": content,
        "agent_role": kwargs.pop("agent_role", None),  # "driver" or "navigator"
        "turn_number": kwargs.pop("turn_number", None),
        "timestamp": kwargs.pop("timestamp", None),
        **kwargs
    })

def save_pair_programming_traj(
    driver_agent: Agent,
    navigator_agent: Agent,
    shared_messages: list[dict],
    path: Path,
    **kwargs
):
    """Save trajectory for pair programming session."""
    data = {
        "info": {
            "exit_status": kwargs.get("exit_status"),
            "submission": kwargs.get("result"),
            "model_stats": {
                "driver": {
                    "instance_cost": driver_agent.model.cost,
                    "api_calls": driver_agent.model.n_calls,
                },
                "navigator": {
                    "instance_cost": navigator_agent.model.cost,
                    "api_calls": navigator_agent.model.n_calls,
                },
                "total_cost": driver_agent.model.cost + navigator_agent.model.cost,
                "total_calls": driver_agent.model.n_calls + navigator_agent.model.n_calls,
            },
            "mini_version": __version__,
            "config": {
                "pair_programming": _asdict(kwargs.get("pair_config")),
                "driver_agent": _asdict(driver_agent.config),
                "driver_model": _asdict(driver_agent.model.config),
                "navigator_agent": _asdict(navigator_agent.config),
                "navigator_model": _asdict(navigator_agent.model.config),
                "environment": _asdict(driver_agent.env.config),
            }
        },
        "messages": shared_messages,  # Messages already have agent_role metadata
        "trajectory_format": "mini-swe-agent-pair-programming-1",
    }

    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2))
```

---

### 6. Configuration System

#### Current Agent Config

**File:** `src/minisweagent/agents/default.py:13-30`

```python
@dataclass
class AgentConfig:
    # The default settings are the bare minimum to run the agent
    system_template: str = "You are a helpful assistant that can do anything."
    instance_template: str = (
        "Your task: {{task}}. Please reply with a single shell command in triple backticks. "
        "To finish, the first line of the output of the shell command must be 'COMPLETE_TASK_AND_SUBMIT_FINAL_OUTPUT'."
    )
    timeout_template: str = (
        "The last command <command>{{action['action']}}</command> timed out and has been killed.\n"
        "The output of the command was:\n <output>\n{{output}}\n</output>\n"
        "Please try another command and make sure to avoid those requiring interactive input."
    )
    format_error_template: str = "Please always provide EXACTLY ONE action in triple backticks."
    action_observation_template: str = "Observation: {{output}}"
    step_limit: int = 0
    cost_limit: float = 3.0
```

#### What to Add

```python
from typing import Literal
from dataclasses import dataclass

@dataclass
class PairProgrammingConfig:
    """Configuration for pair programming mode."""

    # 1. Turn management
    first_speaker: Literal["driver", "navigator"] = "driver"
    """Which agent speaks first"""

    max_turns_per_agent: int = 0
    """Maximum consecutive turns per agent (0 = unlimited but must alternate)"""

    # 2. Reasoning content visibility
    show_reasoning_to_other_agent: bool = False
    """Whether to show reasoning_content field to the other agent"""

    # 3. Tool execution and observation
    allow_navigator_execution: bool = False
    """Whether navigator can execute tools (typically False)"""

    show_tool_action_to_navigator: bool = True
    """Whether navigator sees the tool/command being executed"""

    show_tool_observation_to_navigator: bool = True
    """Whether navigator sees the tool execution results"""

    # 4. Agent-specific configurations
    driver_config: AgentConfig = None
    """Configuration specific to driver agent"""

    navigator_config: AgentConfig = None
    """Configuration specific to navigator agent"""

    # 5. Shared settings
    shared_system_context: str = ""
    """Context shared by both agents (e.g., project goals)"""

    # 6. Termination conditions
    require_both_agents_agree_to_finish: bool = True
    """Whether both agents must agree before finishing"""

    max_total_turns: int = 100
    """Maximum total turns before forced termination"""

@dataclass
class DriverAgentConfig(AgentConfig):
    """Driver-specific configuration."""
    system_template: str = """You are the DRIVER in a pair programming session.
Your role is to:
- Write and execute code
- Implement solutions
- Run commands and tests

Your partner is the NAVIGATOR who will guide strategy and review your work.
Work collaboratively and explain your actions clearly."""

@dataclass
class NavigatorAgentConfig(AgentConfig):
    """Navigator-specific configuration."""
    system_template: str = """You are the NAVIGATOR in a pair programming session.
Your role is to:
- Review the driver's code and actions
- Suggest improvements and catch errors
- Guide overall strategy and approach
- Think ahead about edge cases

Your partner is the DRIVER who will execute the actual commands.
You CANNOT execute commands yourself - only comment and suggest."""

    # Navigator doesn't execute, so no action observation template needed
    action_observation_template: str = ""
```

---

## Implementation Recommendations

### Approach 1: Unified PairProgrammingAgent

Create a single agent class that manages both driver and navigator:

```python
class PairProgrammingAgent:
    def __init__(
        self,
        driver_model: Model,
        navigator_model: Model,
        env: Environment,
        *,
        config: PairProgrammingConfig,
    ):
        self.config = config
        self.env = env

        # Create driver and navigator sub-agents
        self.driver = DefaultAgent(
            model=driver_model,
            env=env,
            config_class=DriverAgentConfig,
            **(config.driver_config or {})
        )
        self.driver.role = "driver"

        self.navigator = DefaultAgent(
            model=navigator_model,
            env=env,
            config_class=NavigatorAgentConfig,
            **(config.navigator_config or {})
        )
        self.navigator.role = "navigator"

        # Shared message history
        self.messages = []
        self.turn_count = 0

    def run(self, task: str, **kwargs) -> tuple[str, str]:
        """Run pair programming session."""
        # Initialize
        self._initialize_session(task)

        # Determine first speaker
        current_agent = self.config.first_speaker

        # Main loop
        while self.turn_count < self.config.max_total_turns:
            agent = self.driver if current_agent == "driver" else self.navigator

            try:
                # Take turn
                self._take_turn(agent)

                # Alternate
                current_agent = "navigator" if current_agent == "driver" else "driver"
                self.turn_count += 1

            except TerminatingException as e:
                if self.config.require_both_agents_agree_to_finish:
                    # Ask other agent to confirm
                    if self._confirm_finish(other_agent):
                        return type(e).__name__, str(e)
                else:
                    return type(e).__name__, str(e)

        return "MaxTurnsExceeded", f"Reached maximum of {self.config.max_total_turns} turns"

    def _take_turn(self, agent):
        """Execute one turn for the given agent."""
        # Filter messages for this agent
        filtered_messages = self._filter_messages_for_agent(agent)

        # Agent queries model
        response = agent.model.query(filtered_messages)

        # Add message to shared history
        self.messages.append({
            "role": "assistant",
            "agent_role": agent.role,
            "turn_number": self.turn_count,
            **response
        })

        # Execute action if applicable
        if agent.role == "driver":
            # Driver executes
            output = agent.execute_action(agent.parse_action(response))
            observation = agent.render_template(
                agent.config.action_observation_template,
                output=output
            )
            self.messages.append({
                "role": "user",
                "content": observation,
                "executed_by": "driver",
                "turn_number": self.turn_count,
            })

    def _filter_messages_for_agent(self, agent) -> list[dict]:
        """Filter shared messages based on visibility rules."""
        filtered = []
        for msg in self.messages:
            # Apply visibility rules
            if self._should_see_message(agent, msg):
                processed_msg = self._process_message_for_agent(agent, msg)
                filtered.append(processed_msg)
        return filtered

    def _should_see_message(self, agent, msg: dict) -> bool:
        """Determine if agent should see this message."""
        # System and initial user messages: visible to all
        if msg["role"] in ["system", "user"] and "executed_by" not in msg:
            return True

        # Assistant messages: check agent_role
        if msg["role"] == "assistant":
            # Always see own messages
            if msg.get("agent_role") == agent.role:
                return True
            # See other agent's messages (content)
            return True

        # Observation messages
        if msg["role"] == "user" and "executed_by" in msg:
            if agent.role == "navigator":
                return self.config.show_tool_observation_to_navigator
            return True  # Driver always sees observations

        return True

    def _process_message_for_agent(self, agent, msg: dict) -> dict:
        """Process message based on visibility settings."""
        processed = msg.copy()

        # Handle reasoning content
        if not self.config.show_reasoning_to_other_agent:
            if msg.get("agent_role") != agent.role:
                # Remove reasoning from other agent's messages
                if "extra" in processed:
                    # Deep copy and remove reasoning
                    processed = self._remove_reasoning_content(processed)

        return processed

    def _remove_reasoning_content(self, msg: dict) -> dict:
        """Remove reasoning content from message."""
        import copy
        msg = copy.deepcopy(msg)
        if "extra" in msg and "response" in msg["extra"]:
            response = msg["extra"]["response"]
            if "choices" in response:
                for choice in response["choices"]:
                    if "message" in choice:
                        choice["message"].pop("reasoning_content", None)
                        if "provider_specific_fields" in choice["message"]:
                            choice["message"]["provider_specific_fields"].pop(
                                "reasoning_content", None
                            )
        return msg
```

### Approach 2: Separate Driver and Navigator Classes

Create separate specialized agent classes:

```python
class DriverAgent(DefaultAgent):
    """Driver agent that executes actions."""

    def __init__(self, *args, **kwargs):
        super().__init__(*args, config_class=DriverAgentConfig, **kwargs)
        self.role = "driver"
        self.can_execute = True

class NavigatorAgent(DefaultAgent):
    """Navigator agent that reviews and guides."""

    def __init__(self, *args, **kwargs):
        super().__init__(*args, config_class=NavigatorAgentConfig, **kwargs)
        self.role = "navigator"
        self.can_execute = False

    def execute_action(self, action: dict) -> dict:
        """Navigator cannot execute - raise error or return dummy."""
        return {"output": "[Navigator does not execute actions]", "returncode": -1}

    def get_observation(self, response: dict) -> dict:
        """Navigator doesn't get observations from execution."""
        # Just parse to validate format, but don't execute
        self.parse_action(response)
        return {"output": "", "returncode": -1}
```

### Recommended File Structure

```
src/minisweagent/
├── agents/
│   ├── default.py                    # Existing
│   ├── interactive.py                # Existing
│   ├── pair_programming.py           # NEW: PairProgrammingAgent
│   ├── driver.py                     # NEW: DriverAgent (optional)
│   └── navigator.py                  # NEW: NavigatorAgent (optional)
├── config/
│   └── pair_programming_default.yaml # NEW: Default pair config
└── run/
    └── utils/
        └── save_pair_programming.py  # NEW: Pair trajectory saving
```

---

## Code Reference Summary

### Critical Files to Understand

| File | Purpose | Key Components |
|------|---------|----------------|
| `src/minisweagent/agents/default.py` | Core agent logic | `run()`, `step()`, `query()`, `get_observation()`, `add_message()` |
| `src/minisweagent/models/litellm_model.py` | Model interface | `query()`, response structure with `reasoning_content` |
| `src/minisweagent/run/utils/save.py` | Trajectory logging | `save_traj()`, trajectory format |
| `src/minisweagent/__init__.py` | Core protocols | `Agent`, `Model`, `Environment` protocols |

### Key Line References

| Component | File:Lines | Description |
|-----------|------------|-------------|
| Main loop | `default.py:73-86` | Where turn management happens |
| Turn execution | `default.py:88-90` | Single step execution |
| Message query | `default.py:92-98` | LLM query with all messages |
| Message storage | `default.py:70-71` | How messages are added |
| Tool execution | `default.py:114-125` | Command execution logic |
| Observation | `default.py:100-105` | Observation generation |
| Model response | `litellm_model.py:66-98` | Response with reasoning_content |
| Trajectory save | `save.py:22-79` | How trajectories are saved |
| Agent config | `default.py:13-30` | Configuration structure |

### Message Flow Sequence

```
1. run() initializes:
   └─ add_message("system", system_template)
   └─ add_message("user", instance_template with task)

2. Loop begins:
   └─ step()
      ├─ query()
      │  ├─ model.query(self.messages)  # Send ALL messages
      │  └─ add_message("assistant", **response)  # Add LLM response
      │
      └─ get_observation()
         ├─ parse_action(response)  # Extract bash command
         ├─ execute_action()  # Run command
         └─ add_message("user", observation)  # Add result

3. Loop repeats until TerminatingException
```

### For Pair Programming

**Required modifications:**
1. ✅ Alternate between driver and navigator in main loop
2. ✅ Filter `self.messages` before calling `model.query()`
3. ✅ Add `agent_role` metadata to all messages
4. ✅ Control tool execution based on agent role
5. ✅ Handle reasoning content visibility
6. ✅ Save both agents' configs and stats in trajectory

---

## Next Steps

1. **Design decision:** Choose between Approach 1 (unified) or Approach 2 (separate classes)
2. **Create config:** Define `PairProgrammingConfig` with all parameters
3. **Implement filtering:** Write message filtering logic for visibility control
4. **Implement turn management:** Modify or create new `run()` method with alternation
5. **Extend logging:** Update `save_traj()` for pair programming metadata
6. **Test:** Create test cases with sample SWE-bench tasks
7. **Iterate:** Adjust based on real conversation patterns

---

**Document Version:** 1.0
**Last Updated:** 2025-11-20
