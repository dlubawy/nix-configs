{ ... }:
{
  plugins.lsp = {
    enable = true;
    servers = {
      bashls.enable = true;
      clangd.enable = true;
      cssls.enable = true;
      dockerls.enable = true;
      gopls.enable = true;
      html.enable = true;
      ltex.enable = true;
      lua_ls = {
        enable = true;
        settings = {
          Lua = {
            runtime = {
              version = "LuaJIT";
            };
            diagnostics = {
              globals = [ "vim" ];
            };
            workspace = {
              library = ''vim.api.nvim_get_runtime_file(" ", true)'';
            };
            telemetry = {
              enable = false;
            };
          };
        };
      };
      marksman.enable = true;
      nil_ls.enable = true;
      ruff.enable = true;
      rust_analyzer = {
        enable = true;
        installCargo = false;
        installRustc = false;
        settings.files.excludeDirs = [ ".direnv" ];
      };
      sqls.enable = true;
      terraformls.enable = true;
      ts_ls.enable = true;
    };
  };
}
