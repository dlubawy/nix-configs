# LaTeX Development Environment Template

A comprehensive Nix flake template for LaTeX document creation with modern tooling and pre-commit hooks.

## Overview

This template provides a complete LaTeX development environment with:

- **TeX Live Distribution**: Curated collection of LaTeX packages
- **Modern CV Support**: moderncv package with FontAwesome 5 icons
- **Document Quality**: chktex for linting LaTeX files
- **Pre-commit Hooks**: Extensive quality checks
- **Cross-platform**: Supports Linux and macOS

## Quick Start

Initialize a new LaTeX project:

```bash
nix flake init --template github:dlubawy/nix-configs/main#latex
```

Enter the development environment:

```bash
nix develop
```

Create your LaTeX document (e.g., `main.tex`) and compile:

```bash
pdflatex main.tex
# or
latexmk -pdf main.tex
```

## Project Structure

The template provides:

- `flake.nix` - Nix flake configuration with TeX Live packages
- `.envrc` - direnv configuration for automatic environment activation
- `.gitignore` - Pre-configured for LaTeX projects (ignores build artifacts)

## How It Works

### TeX Live Packages

The template includes a curated set of LaTeX packages:

```nix
tex = (pkgs.texlive.combine {
  inherit (pkgs.texlive)
    scheme-small     # Base LaTeX distribution
    moderncv         # Modern CV/resume templates
    fontawesome5     # FontAwesome 5 icon font
    multirow         # Tables with multirow cells
    arydshln         # Dashed lines in arrays/tables
    ;
});
```

This provides:

- **scheme-small**: Core LaTeX functionality (smaller than full distribution)
- **moderncv**: Professional CV/resume templates
- **fontawesome5**: Modern icon font for CVs and documents
- **multirow**: Enhanced table features
- **arydshln**: Dashed lines in tables and arrays

### Development Workflow

#### Creating Documents

Create a basic LaTeX document:

```latex
\documentclass{article}
\usepackage[utf8]{inputenc}

\title{My Document}
\author{Your Name}
\date{\today}

\begin{document}
\maketitle

\section{Introduction}
Your content here.

\end{document}
```

#### Compiling Documents

```bash
# Basic compilation
pdflatex main.tex

# With automatic bibliography and references
latexmk -pdf main.tex

# Clean build artifacts
latexmk -c
```

#### Creating a Modern CV

Using the moderncv package:

```latex
\documentclass[11pt,a4paper]{moderncv}
\moderncvstyle{classic}
\moderncvcolor{blue}

\usepackage[utf8]{inputenc}
\usepackage[scale=0.75]{geometry}

\name{John}{Doe}
\title{Software Engineer}
\email{john@example.com}
\phone[mobile]{+1~(234)~567~890}

\begin{document}
\makecvtitle

\section{Education}
\cventry{2015--2019}{Bachelor of Science}{University}{City}{}{Computer Science}

\section{Experience}
\cventry{2019--Present}{Software Engineer}{Company}{City}{}{%
Description of your role and achievements.
}

\end{document}
```

#### Using FontAwesome Icons

```latex
\documentclass{article}
\usepackage{fontawesome5}

\begin{document}
Email: \faEnvelope{} email@example.com \\
GitHub: \faGithub{} username \\
LinkedIn: \faLinkedin{} profile
\end{document}
```

### Pre-commit Hooks

The template includes comprehensive quality checks that run automatically on commit:

- **Security**: `trufflehog` - Detect hardcoded secrets
- **LaTeX Quality**: `chktex` - Lint LaTeX files for common errors
- **Nix Quality**: `nixfmt-rfc-style` - Format Nix files
- **Documentation**: `mdformat` - Format Markdown files
- **Validation**:
  - `flake-checker` - Validate flake structure
  - `check-yaml` - Lint YAML files
- **Git Quality**:
  - `commitizen` - Validate commit messages
  - `check-merge-conflicts` - Detect conflict markers
  - `check-added-large-files` - Block large files (>5MB)
  - `no-commit-to-branch` - Protect main branch

The `.gitignore` file excludes common LaTeX build artifacts like `.aux`, `.log`, `.pdf`, etc.

## Customization

### Adding More LaTeX Packages

To add additional packages, modify the `tex` definition in `flake.nix`:

```nix
tex = (pkgs.texlive.combine {
  inherit (pkgs.texlive)
    scheme-small
    moderncv
    fontawesome5
    multirow
    arydshln
    # Add more packages:
    amsmath        # Advanced math
    graphicx       # Include graphics
    hyperref       # Hyperlinks in PDFs
    biblatex       # Bibliography management
    tikz           # Drawing diagrams
    listings       # Code listings
    ;
});
```

Browse available packages:

```bash
# Search for LaTeX packages in nixpkgs
nix search nixpkgs texlive. | grep "texlive."

# Or online
# https://search.nixos.org/packages?query=texlive
```

### Using a Larger TeX Scheme

For a more complete distribution, change `scheme-small`:

```nix
inherit (pkgs.texlive)
  scheme-medium  # More packages than small
  # or
  scheme-full    # Complete TeX Live (large download)
  # or
  scheme-basic   # Minimal TeX Live
```

**Note**: Larger schemes significantly increase download size and build time.

### Configuring chktex

Create a `.chktexrc` file in your project to customize linting:

```
# Disable specific warnings
CmdLine {
  -n 1  # Disable "Command terminated with space"
  -n 8  # Disable "Wrong length of dash"
}
```

### Modifying Pre-commit Hooks

Edit the `checks.pre-commit-check.hooks` section in `flake.nix` to enable, disable, or configure hooks.

## Platform Support

This template supports:

- `x86_64-linux`
- `aarch64-linux`
- `x86_64-darwin` (macOS Intel)
- `aarch64-darwin` (macOS Apple Silicon)

## Common Tasks

### Bibliography Management

Using BibTeX:

```latex
\documentclass{article}
\begin{document}
\cite{lamport94}
\bibliographystyle{plain}
\bibliography{references}
\end{document}
```

Compile with:

```bash
pdflatex main.tex
bibtex main
pdflatex main.tex
pdflatex main.tex

# Or use latexmk
latexmk -pdf main.tex
```

### Creating Presentations (Beamer)

Add `beamer` to your TeX packages and create:

```latex
\documentclass{beamer}
\usetheme{Madrid}

\title{My Presentation}
\author{Your Name}

\begin{document}
\frame{\titlepage}

\begin{frame}
\frametitle{Introduction}
Your content here.
\end{frame}
\end{document}
```

### Including Graphics

Add `graphicx` package and use:

```latex
\usepackage{graphicx}
\begin{document}
\includegraphics[width=0.5\textwidth]{image.png}
\end{document}
```

### Multi-file Projects

Split large documents:

```latex
% main.tex
\documentclass{article}
\begin{document}
\include{chapter1}
\include{chapter2}
\end{document}
```

### Clean Build Artifacts

```bash
# Remove auxiliary files
latexmk -c

# Remove all generated files including PDFs
latexmk -C

# Manual cleanup
rm *.aux *.log *.out *.toc *.bbl *.blg
```

## Troubleshooting

### LaTeX command not found

Ensure you're in the development shell:

```bash
nix develop
# or with direnv:
direnv allow
```

### Package not found

The package might not be in `scheme-small`. Either:

1. Add the specific package to the `tex` combine block
1. Switch to `scheme-medium` or `scheme-full`

### Compilation errors

Check the `.log` file for detailed error messages:

```bash
less main.log
```

Common issues:

- Missing `\end{document}`
- Unmatched braces `{}`
- Missing packages
- Special characters not escaped (`&`, `%`, `$`, etc.)

### chktex warnings

Some warnings are style preferences and can be disabled. Create a `.chktexrc` file to configure.

### Font issues with moderncv

Ensure `fontawesome5` is included in your TeX packages. The template includes it by default.

### Pre-commit hooks fail

Run hooks manually to see detailed error messages:

```bash
git commit  # hooks run automatically
# OR
pre-commit run --all-files  # run all hooks manually
```

## References

- [LaTeX Documentation](https://www.latex-project.org/help/documentation/)
- [Overleaf Learn LaTeX](https://www.overleaf.com/learn)
- [moderncv Documentation](https://ctan.org/pkg/moderncv)
- [FontAwesome 5 Icons](https://fontawesome.com/v5/search)
- [chktex Manual](https://www.nongnu.org/chktex/)
- [TeX Live Packages](https://tug.org/texlive/)
- [latexmk Documentation](https://www.ctan.org/pkg/latexmk)
