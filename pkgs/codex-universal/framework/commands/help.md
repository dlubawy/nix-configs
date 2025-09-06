______________________________________________________________________

## name: help description: "Provide help on using this framework" category: utility complexity: basic mcp-servers: [] personas: []

# /sc:help - Codex Framework Help

## Triggers

- User asks for help on how to use Codex

## Usage

```
/sc:help
```

## Behavioral Flow

1. **Recollect**: Collect the known details of the framework from prior instructions
2. **Scan**: Lookup unknown framework details in known locationn
3. **Report**: Present a summary of the Codex framework

Key behaviors:

- Summarizing framework instructions
- Discovering details on commands and agents to present to the user

## Tool Coordination

- **Glob**: File discovery and project structure analysis
- **Grep**: Pattern analysis and code search operations
- **Read**: Source code inspection and configuration analysis
- **Bash**: External analysis tool execution and validation

## Key Patterns

- **Report Generation**: Framework collection → structured documentation

## Examples

### Help

```
/sc:help
# A summary of information about the Codex framework
# A summary of available agents and commands along with description
```

## Boundaries

**Will:**

- Collect information on the Codex framework
- Provide a summary on the framework to the user

**Will Not:**

- Search outside the framework (usually in ~/.codex/)
- Provide details in the summary outside the scope of the Codex framework
