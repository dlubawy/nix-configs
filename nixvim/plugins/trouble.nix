{ ... }:
{
  plugins.trouble = {
    enable = true;
    settings.modes.__raw = ''
      {
        diagnostics_document = {
          mode = "diagnostics", -- inherit from diagnostics mode
          filter = { buf = 0 }, -- filter diagnostics to the current buffer
        },
        diagnostics_workspace = {
          mode = "diagnostics", -- inherit from diagnostics mode
          filter = {
            any = {
              buf = 0, -- current buffer
              {
                severity = vim.diagnostic.severity.ERROR, -- errors only
                -- limit to files in the current project
                function(item)
                  return item.filename:find((vim.loop or vim.uv).cwd(), 1, true)
                end,
              },
            },
          },
        },
      }
    '';
  };
}
