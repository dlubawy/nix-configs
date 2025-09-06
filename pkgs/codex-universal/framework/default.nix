{ pkgs, ... }:
let
  inherit (pkgs) lib symlinkJoin writeTextFile;
  codexHome = "/root/.codex";
  agentFiles = (import ./agents { inherit pkgs codexHome; });
  commandFiles = (import ./commands { inherit pkgs codexHome; });
  frameworkBase = ''
    # Tool Guidelines

    ## browser

    You have access to a special tool called `browser`.
    It is ONLY for retrieving information from the internet in real time.
    It cannot open or read local files, documents, or code.
    Never interpret `browser.open` as opening a file. It strictly means opening a web page.

    The browser tool supports only three methods:
    - `search` → Perform a web search using a query string.
    - `open` → Open a specific web page by its link `id` or URL (http/https). This does not open local files or directories.
    - `find` → Search for text within the currently opened web page.

    Always use these methods only for online browsing.
    Do not try to use the browser tool for local file access, uploads, downloads, or code execution.

    If a request cannot be fulfilled with these three methods, respond without using the browser.


    # ═══════════════════════════════════════════════════
    # Framework
    # ═══════════════════════════════════════════════════
    <base_instructions>
    # Prompt commands
    When a user enters a command in the form `/sc:<command-name> [arguments]`, do the following:

    1. Locate the corresponding Markdown file `${codexHome}/commands/<command-name>.md` in the command library.
       - Example: `/sc:analyze src/` → read `${codexHome}/commands/analyze.md`.

    2. To read the file: you MUST use the shell tool with `cat ${codexHome}/commands/<command-name>.md`.
       - Do NOT attempt to fetch files using browser or web tools.
       - The ONLY valid way to retrieve these files is with the shell tool.

    3. Once the file is retrieved, read its entire contents and use it as the authoritative specification for how you must respond.
       - Follow the "Behavioral Flow," "Key Patterns," "Boundaries," and other defined sections.
       - Do not invent behavior outside the specification.

    4. When performing analysis tasks defined in the `.md` file:
       - You are authorized to use the shell tool to run real commands such as `ls`, `find`, `wc`, `grep`, or `cat` to perform the required task.
       - Use these commands to gather real data (file counts, line counts, pattern matches, etc.).
       - Base all findings and metrics on actual file contents.
       - Do NOT simulate or invent results.

    5. Apply the user’s arguments (`[arguments]`) to the usage and examples provided in the file.
       - Interpret flags, options, and targets exactly as documented.

    6. Generate outputs based on real data + the guidance in the `.md` file.
       - Summarize findings, provide severity ratings, or make recommendations, but always ground them in the data you collected.

    If a command is not defined in the library, reply with an error message:
    "Error: Command <command-name> not found in library."

    ## Available commands
    ${lib.strings.concatMapStringsSep "\n" (
      file: "- `/sc:${lib.strings.removeSuffix ".md" file.name}`"
    ) commandFiles}

    # Agents
    Specialized agents are available to delegate tasks when needed. Further
    instructions may help guide you to know when an agent would be better suited
    for a task. Agents may be explicitly called using '@' notation: `@agent-<agent-name> [prompt]`.
    When an agent is called or a task would be better suited for one, you may invoke
    the agent through the shell with timeout 1800000ms:
    ```bash
    codex exec --profile <agent-name> [prompt]
    ```
    Modify the complexity of the agent's thinking by adding a config parameter for `model_reasoning_effort`
    selecting from low, medium, or high as such:
    ```bash
    codex exec --profile <agent-name> --config model_reasoning_effort=[low,medium,high] [prompt]
    ```
    Always try to run the agent as described. If an agent fails to run. Give up your turn and report
    to the user.
    Example:
    - User prompt: `@agent-security-engineer "review auth flow"`
    - Codex actions:
      - shell tool with 1800000ms timeout: `codex exec --profile security-engineer "review auth flow"`
      - Forward the response from the agent to the user

    ## Available agents
    ${lib.strings.concatMapStringsSep "\n" (
      file: "- `@agent-${lib.strings.removeSuffix ".md" file.name}`"
    ) agentFiles}
    </base_instructions>

  '';
  codexConfig = writeTextFile {
    name = "codexConfig";
    text = lib.strings.concatLines [
      (builtins.readFile ./config.toml)
      (lib.strings.concatMapStringsSep "\n" (
        file:
        let
          agentName = (lib.strings.removeSuffix ".md" file.name);
        in
        ''
          [profiles.${agentName}]
          experimental_instructions_file = "${codexHome}/agents/${file.name}"
        ''
      ) agentFiles)
    ];
    destination = "${codexHome}/config.toml";
  };
  codexInstructions = writeTextFile {
    name = "codexInstructions";
    text = lib.strings.concatLines [
      frameworkBase
      "# ═══════════════════════════════════════════════════"
      "# Framework components"
      "# ═══════════════════════════════════════════════════"
      "# Core"
      "<core_instructions>"
      (import ./core { inherit pkgs; })
      "</core_instructions>"
      "# Modes"
      "<mode_instructions>"
      (import ./modes { inherit pkgs; })
      "</mode_instructions>"
      "# MCP Servers"
      "<mcp_instructions>"
      (import ./mcp { inherit pkgs; })
      "</mcp_instructions>"
    ];
    destination = "${codexHome}/framework-instructions.md";
  };
in
symlinkJoin {
  name = "codex-framework";
  paths = [
    codexConfig
    codexInstructions
  ]
  ++ agentFiles
  ++ commandFiles;
}
