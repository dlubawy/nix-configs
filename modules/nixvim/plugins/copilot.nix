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
      settings.model = "gpt-5-mini";
    };
  };
}
