# Contribution guidance

## Pre-commit

- Pre-commit hooks are configured directly in `./flake.nix` (under the `checks` section) using the `pre-commit-hooks` input from the git-hooks.nix repository
- Make sure all pre-commit checks pass before committing work

# Pull request guidance

## PR title template

- Format PR title like a commit message
- Follow conventional commit formatting for titles with a prefix for change type like chore, feat, fix, etc.

## PR reviewing

- Pull requests require the "Format 🔎" and "check-results" jobs pass
