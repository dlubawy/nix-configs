{
  enable = false;
  modules = {
    "core.defaults" = { };
    "core.concealer" = { };
    "core.dirman" = {
      config = {
        default_workspace = "desktop";
        workspaces = {
          desktop = "~/Desktop";
          notes = "~/Documents/00-09 System/02 Notes";
        };
      };
    };
    "core.completion" = {
      config = {
        engine = "nvim-cmp";
      };
    };
    "core.export" = { };
    "core.presenter" = {
      config = {
        zen_mode = "zen_mode";
      };
    };
    "core.summary" = { };
    "external.integrations.figlet" = {
      config = {
        font = "slant";
        wrapInCodeTags = true;
      };
    };
    "external.templates" = { };
    "external.capture" = {
      config = {
        templates = {
          __raw = ''
            {
            	description = "Todo",
            	name = "todo",
            	file = "todo",
            },
            {
            	description = "Note",
            	name = "note",
            	file = function()
            		vim.api.nvim_buf_get_name({ buffer = 0 })
            	end,
            },
          '';
        };
      };
    };
  };
}
