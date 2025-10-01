{ ... }:
{
  plugins = {
    copilot-lua = {
      enable = true;
      settings = {
        panel.enabled = false;
        suggestion.enabled = false;
        filetypes = {
          "*" = false;
        };
      };
    };
    copilot-cmp.enable = true;
    copilot-chat = {
      enable = true;
      settings.model = "claude-3.5-sonnet";
    };
  };
}
