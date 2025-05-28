{ ... }:
{
  keymaps = [
    {
      key = "<C-n>";
      action = "<cmd>Neotree toggle<CR>";
      options.desc = "Neotree";
    }
    {
      key = "jk";
      action = "<esc>";
      mode = "i";
      options = {
        silent = true;
        desc = "Escape";
      };
    }
    {
      key = "<C-j>";
      action = "<cmd>lua vim.diagnostic.goto_next()<CR>";
      mode = "n";
      options = {
        silent = true;
        desc = "Next error";
      };
    }
    {
      key = "<C-k>";
      action = "<cmd>lua vim.diagnostic.goto_prev()<CR>";
      mode = "n";
      options = {
        silent = true;
        desc = "Prev error";
      };
    }
    {
      key = "<space>";
      action = "za";
      mode = "n";
      options = {
        silent = true;
        desc = "Toggle fold";
      };
    }
    {
      key = "B";
      action = "^";
      mode = "n";
      options.silent = true;
    }
    {
      key = "E";
      action = "$";
      mode = "n";
      options.silent = true;
    }
    {
      key = "$";
      action = "<nop>";
      mode = "n";
      options.silent = true;
    }
    {
      key = "^";
      action = "<nop>";
      mode = "n";
      options.silent = true;
    }
    {
      key = "<leader><space>";
      action = "<cmd>nohlsearch<CR>";
      mode = "n";
      options = {
        silent = true;
      };
    }
    {
      key = "<leader>ccq";
      action = {
        __raw = ''
          function()
            local input = vim.fn.input("Quick Chat: ")
            if input ~= "" then
              require("CopilotChat").ask(input, { selection = require("CopilotChat.select").buffer })
            end
          end
        '';
      };
      options.desc = "Quick chat";
    }
    {
      key = "<leader>ccp";
      action = {
        __raw = ''
          function()
            local actions = require("CopilotChat.actions")
            require("CopilotChat.integrations.fzflua").pick(actions.prompt_actions())
          end
        '';
      };
      options.desc = "Prompt actions";
    }
  ];
}
