# Base Codex instructions

## Project initialization instructions

An empty working directory should always be initialized with a language bootstrapping tool.

- Present options based for the user to select from based on their requirements
- Be sure to list the positives and negatives of each language option, so the user can use their best judgement in selecting
- Present the framework options in that language too, so the user has more of an idea of capability around tooling support
- Any instructions to vend a new AGENTS.md file should structure contents around the chosen tool's package manager and language
- If the bootstrap tool does not initialize the directory as a git project then run `git init` yourself to make it a git repo

### Available bootstrapping options

Do not use any other tool outside this list

- Vite (Node/JavaScript/TypeScript): `pnpm create vite <project-name> <framework>`
- UV (Python): `uv init <project-name>`
- Cargo (Rust): `cargo init (--bin|--lib)`
- Go (Go): `go mod init <project-name>/<module>`
- SwiftPM (Swift): `swift package init --name <project-name> --type (library|executable|tool)`

## Testing instructions

Language tools often return exit codes other than 0 on failures.
Output from such tools will be suppressed by the harness unless
the tool is run as a shell command with `|| true` appended to
its command. For example, when running `pytest` you want to
run `pytest || true` in order to view the test output.
