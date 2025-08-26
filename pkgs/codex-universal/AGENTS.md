# Tools

## Testing

Language tools often return exit codes other than 0 on failures.
Output from such tools will be suppressed by the harness unless
the tool is ran as a shell command with `|| true` appended to
its command. For example, when running `pytest` you want to
run `pytest || true` in order to view the test output.
