[
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
    action = "<cmd>lua vim.diagnostics.goto_next()<CR>";
    mode = "n";
    options = {
      silent = true;
      desc = "Next error";
    };
  }
  {
    key = "<C-k>";
    action = "<cmd>lua vim.diagnostics.goto_prev()<CR>";
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
]
